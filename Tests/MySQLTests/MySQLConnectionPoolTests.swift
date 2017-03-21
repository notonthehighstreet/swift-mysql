import Foundation
import XCTest
import Dispatch

@testable import MySQL

public class MySQLConnectionPoolTests: XCTestCase {

  var mockConnection = MockMySQLConnection()
  var queue: DispatchQueue?

  public override func setUp() {
    queue = DispatchQueue.init(label: "statsd_queue." + String(NSDate().timeIntervalSince1970), attributes: .concurrent)

    mockConnection = MockMySQLConnection()
    MySQLConnectionPool.setConnectionProvider() {
      return self.mockConnection
    }

    MySQLConnectionPool.activeConnections = [String: [MySQLConnectionProtocol]]()
    MySQLConnectionPool.inactiveConnections = [String: [MySQLConnectionProtocol]]()
  }

  public func testSetsPoolSize() {
    MySQLConnectionPool.setPoolSize(size: 10)

    XCTAssertEqual(10, MySQLConnectionPool.poolSize)
  }

  public func testConnectionConnectCalled() {
    var _ = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "")!

    XCTAssertTrue(mockConnection.connectCalled, "Connect should have been called")
  }

  public func testGetConnectionWithNoInactiveConnectionsCreatesANewConnection() {
    let connection = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "")!

    XCTAssertTrue(connection.equals(otherObject: mockConnection), "Should have used connection from pool")
  }

  public func testGetConnectionWithNoInactiveConnectionsAddsAnActivePoolItem() {
    var _ = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "")!

    XCTAssertEqual(1, MySQLConnectionPool.activeConnections.values.first?.count, "Active connections should contain 1 item")
  }

  public func testGetConnectionWithInactivePoolItemUsesExistingConnection() {
    var inactiveConnections = [MySQLConnectionProtocol]()
    let tempConnection = MockMySQLConnection()
    inactiveConnections.append(tempConnection)

    MySQLConnectionPool.inactiveConnections["192.168.99.100_root_my-secret-pw_test"] = inactiveConnections

    let connection = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!

    XCTAssertTrue(connection.equals(otherObject: tempConnection), "Should have used connection from pool")
    XCTAssertEqual(1, MySQLConnectionPool.activeConnections.values.first?.count, "There should be one active connections")
    XCTAssertEqual(0, MySQLConnectionPool.inactiveConnections.values.first?.count, "There should be no inactive connections")
  }

  public func testGetConnectionWithInactivePoolItemChecksIfConnectionActive() {
    var inactiveConnections = [MySQLConnectionProtocol]()
    let tempConnection = MockMySQLConnection()
    inactiveConnections.append(tempConnection)

    MySQLConnectionPool.inactiveConnections["192.168.99.100_root_my-secret-pw_test"] = inactiveConnections

    let _ = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!

    XCTAssertTrue(tempConnection.isConnectedCalled, "Should have checked if connection active")
  }

  public func testGetConnectionWithInactivePoolWhenNotConnectedCreateNewConnection() {
    var inactiveConnections = [MySQLConnectionProtocol]()
    let tempConnection = MockMySQLConnection()
    inactiveConnections.append(tempConnection)

    MySQLConnectionPool.inactiveConnections["192.168.99.100_root_my-secret-pw_test"] = inactiveConnections

    var connection = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!
    MySQLConnectionPool.releaseConnection(connection: connection)

    tempConnection.connectCalled = false
    tempConnection.isConnectedReturn = false

    connection = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!

    XCTAssertTrue(mockConnection.connectCalled, "Should have created a new connection")
    XCTAssertEqual(1, MySQLConnectionPool.activeConnections.values.first?.count, "There should be one active connections")
  }

  public func testGetConnectionNoInactiveConnectionsAddsAnActivePoolItemWithAValidKey() {
    var _ = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!

    XCTAssertEqual("192.168.99.100_root_my-secret-pw_test", MySQLConnectionPool.activeConnections.keys.first!, "Key should have correct value")
  }

  public func testGetConnectionWithClosureReleasesConnectionAfterUse() {
    var _ = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test") {
      (connection: MySQLConnectionProtocol) in
        XCTAssertEqual(1, MySQLConnectionPool.activeConnections.values.first?.count, "There should be one active connections")
    }

    XCTAssertEqual(1, MySQLConnectionPool.inactiveConnections.values.first?.count, "There should be one inactive connections")
  }

  public func testGetConnectionWithClosureExecutesClosurePassingConnection() {
    var closureCalled = false

    var _ = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test") {
      (connection: MySQLConnectionProtocol) in
        closureCalled = true
    }

    XCTAssertTrue(closureCalled, "Closure should have been called")
  }

  public func testReleaseConnectionReturnsConnectionToThePool() {
    let connection = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!
    MySQLConnectionPool.releaseConnection(connection: connection)

    XCTAssertEqual(0, MySQLConnectionPool.activeConnections.values.first?.count, "There should be no active connections")
    XCTAssertEqual(1, MySQLConnectionPool.inactiveConnections.values.first?.count, "There should be one inactive connections")
  }

  // Async tests are not currently implemented for Swift mac 24_03 release
  //#if os(Linux)
  var timer = 0.0

  public func testGetConnectionBlocksWhenPoolIsExhausted() {
    let ex = expectation(description: "Should have blocked when no pool connections are available")

    MySQLConnectionPool.poolSize = 1
    let connection = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!

    queue!.async(execute: {
      let startTime = NSDate().timeIntervalSince1970
      let _ = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!

      let endTime = NSDate().timeIntervalSince1970
      self.timer = endTime - startTime

      ex.fulfill()
    })

    sleep(1)

    MySQLConnectionPool.releaseConnection(connection: connection)

    waitForExpectations(timeout: 3) { error in
      if let error = error {
        XCTFail("Error: \(error.localizedDescription)")
      }
    }

    //test equal elapsed time + delay interval
    XCTAssertTrue((timer >= 1), "getConnection should have blocked for 1 second")
  }

  public func testGetConnectionTimesoutWhenPoolIsExhausted() {
    let ex = expectation(description: "MySQLConnectionPool getConnection should have timedout")

    MySQLConnectionPool.poolSize = 1
    MySQLConnectionPool.poolTimeout = 1
    let _ = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!

    queue!.async(execute: {
      do {
        let _ = try MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!
      } catch {
        ex.fulfill()
      }
    })

    waitForExpectations(timeout: 3) { error in
      if let error = error {
        XCTFail("Error: \(error.localizedDescription)")
      }
    }
  }

  public func testBroadcastsEventWhenConnectionCreated() {
    var dispatchedMessage:MySQLConnectionPoolMessage?

    MySQLConnectionPool.setLogger {
      (message: MySQLConnectionPoolMessage) in
        dispatchedMessage = message
    }
    let _ = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!

    XCTAssertEqual(MySQLConnectionPoolMessage.CreatedNewConnection, dispatchedMessage)
  }

  public func testBroadcastsEventWhenConnectionFailed() {
    mockConnection.connectError = MySQLError.UnableToCreateConnection

    var dispatchedMessage:MySQLConnectionPoolMessage?
    MySQLConnectionPool.setLogger {
      (message: MySQLConnectionPoolMessage) in
        dispatchedMessage = message
    }

    do {
      let _ = try MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!
    } catch {
      
    }

    XCTAssertEqual(MySQLConnectionPoolMessage.FailedToCreateConnection, dispatchedMessage)
  }

  public func testBroadcastsEventWhenConnectionReused() {
    var dispatchedMessage:MySQLConnectionPoolMessage?

    MySQLConnectionPool.setLogger {
      (message: MySQLConnectionPoolMessage) in
        dispatchedMessage = message
    }
    let connection = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!
    MySQLConnectionPool.releaseConnection(connection: connection)

    let _ = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!

    XCTAssertEqual(MySQLConnectionPoolMessage.RetrievedConnectionFromPool, dispatchedMessage)
  }

  public func testBroadcastsEventWhenConnectionReconnected() {
    var dispatchedMessage = [MySQLConnectionPoolMessage]()

    MySQLConnectionPool.setLogger {
      (message: MySQLConnectionPoolMessage) in
        dispatchedMessage.append(message) // the event we are looking for will be the 2nd
    }
    let connection = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!
    MySQLConnectionPool.releaseConnection(connection: connection)
    mockConnection.isConnectedReturn = false

    let _ = try! MySQLConnectionPool.getConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", port: 3306, database: "test")!

    XCTAssertEqual(MySQLConnectionPoolMessage.ConnectionDisconnected, dispatchedMessage[1])
  }
}

extension MySQLConnectionPoolTests {
  static var allTests: [(String, (MySQLConnectionPoolTests) -> () throws -> Void)] {
    return [
      ("testSetsPoolSize", testSetsPoolSize),
      ("testConnectionConnectCalled", testConnectionConnectCalled),
      ("testGetConnectionWithNoInactiveConnectionsCreatesANewConnection", testGetConnectionWithNoInactiveConnectionsCreatesANewConnection),
      ("testGetConnectionWithNoInactiveConnectionsAddsAnActivePoolItem", testGetConnectionWithNoInactiveConnectionsAddsAnActivePoolItem),
      ("testGetConnectionWithInactivePoolItemUsesExistingConnection", testGetConnectionWithInactivePoolItemUsesExistingConnection),
      ("testGetConnectionWithInactivePoolItemChecksIfConnectionActive", testGetConnectionWithInactivePoolItemChecksIfConnectionActive),
      ("testGetConnectionWithInactivePoolWhenNotConnectedCreateNewConnection", testGetConnectionWithInactivePoolWhenNotConnectedCreateNewConnection),
      ("testGetConnectionNoInactiveConnectionsAddsAnActivePoolItemWithAValidKey", testGetConnectionNoInactiveConnectionsAddsAnActivePoolItemWithAValidKey),
      ("testGetConnectionWithClosureReleasesConnectionAfterUse", testGetConnectionWithClosureReleasesConnectionAfterUse),
      ("testGetConnectionWithClosureExecutesClosurePassingConnection", testGetConnectionWithClosureExecutesClosurePassingConnection),
      ("testReleaseConnectionReturnsConnectionToThePool", testReleaseConnectionReturnsConnectionToThePool),
      ("testGetConnectionBlocksWhenPoolIsExhausted", testGetConnectionBlocksWhenPoolIsExhausted),
      ("testGetConnectionTimesoutWhenPoolIsExhausted", testGetConnectionTimesoutWhenPoolIsExhausted),
      ("testBroadcastsEventWhenConnectionCreated", testBroadcastsEventWhenConnectionCreated),
      ("testBroadcastsEventWhenConnectionReused", testBroadcastsEventWhenConnectionReused),
      ("testBroadcastsEventWhenConnectionReconnected", testBroadcastsEventWhenConnectionReconnected)
    ]
  }
}
