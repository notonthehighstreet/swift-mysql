import Foundation
import XCTest
import Dispatch

@testable import MySQL

public class MySQLConnectionPoolTests: XCTestCase {

  var connectionPool: MySQLConnectionPool?
  var mockConnection = MockMySQLConnection()
  var queue: DispatchQueue?

  public override func setUp() {
    queue = DispatchQueue.init(label: "statsd_queue." + String(NSDate().timeIntervalSince1970), attributes: .concurrent)

    mockConnection = MockMySQLConnection()
    connectionPool = MySQLConnectionPool(
                    connectionString: MySQLConnectionString(host: "192.168.99.100",
                                                            user: "root",
                                                            password: "my-secret-pw",
                                                            database: "test"),
                                                            poolSize: 10,
                                                            defaultCharset: "utf8") {
      return self.mockConnection
    }

    connectionPool!.activeConnections = [String: [MySQLConnectionProtocol]]()
    connectionPool!.inactiveConnections = [String: [MySQLConnectionProtocol]]()
  }

  public func testConnectionConnectCalled() {
    let _ = try! connectionPool!.getConnection()!

    XCTAssertTrue(mockConnection.connectCalled, "Connect should have been called")
  }

  public func testGetConnectionWithDefaultCharset() {
    let connection = try! connectionPool!.getConnection()!
    let charset = connection.charset()

    XCTAssertNotNil(charset)
    XCTAssertEqual(charset!, "utf8")
  }

  public func testSetConnectionCharset() {
    let connection = try! connectionPool!.getConnection()!
    let _ = connection.setCharset(charset: "utf8mb4")

    XCTAssertNotEqual(connection.charset()!, "utf8")
    XCTAssertEqual(connection.charset()!, "utf8mb4")
  }

  public func testGetConnectionWithNoInactiveConnectionsCreatesANewConnection() {
    let connection = try! connectionPool!.getConnection()!

    XCTAssertTrue(connection.equals(otherObject: mockConnection), "Should have used connection from pool")
  }

  public func testGetConnectionWithNoInactiveConnectionsAddsAnActivePoolItem() {
    let _ = try! connectionPool!.getConnection()!

    XCTAssertEqual(1, connectionPool!.activeConnections.values.first?.count, "Active connections should contain 1 item")
  }

  public func testGetConnectionWithInactivePoolItemUsesExistingConnection() {
    var inactiveConnections = [MySQLConnectionProtocol]()
    let tempConnection = MockMySQLConnection()
    inactiveConnections.append(tempConnection)

    connectionPool!.inactiveConnections["192.168.99.100_root_my-secret-pw_test"] = inactiveConnections

    let connection = try! connectionPool!.getConnection()!

    XCTAssertTrue(connection.equals(otherObject: tempConnection), "Should have used connection from pool")
    XCTAssertEqual(1, connectionPool!.activeConnections.values.first?.count, "There should be one active connections")
    XCTAssertEqual(0, connectionPool!.inactiveConnections.values.first?.count, "There should be no inactive connections")
  }

  public func testGetConnectionWithInactivePoolItemChecksIfConnectionActive() {
    var inactiveConnections = [MySQLConnectionProtocol]()
    let tempConnection = MockMySQLConnection()
    inactiveConnections.append(tempConnection)

    connectionPool!.inactiveConnections["192.168.99.100_root_my-secret-pw_test"] = inactiveConnections

    let _ = try! connectionPool!.getConnection()!

    XCTAssertTrue(tempConnection.isConnectedCalled, "Should have checked if connection active")
  }

  public func testGetConnectionWithInactivePoolWhenNotConnectedCreateNewConnection() {
    var inactiveConnections = [MySQLConnectionProtocol]()
    let tempConnection = MockMySQLConnection()
    tempConnection.connectCalled = false
    tempConnection.isConnectedReturn = false

    inactiveConnections.append(tempConnection)

    connectionPool!.inactiveConnections["192.168.99.100_root_my-secret-pw_test"] = inactiveConnections

    let _ = try! connectionPool!.getConnection()!

    XCTAssertTrue(mockConnection.connectCalled, "Should have created a new connection")
    XCTAssertEqual(1, connectionPool!.activeConnections.values.first?.count, "There should be one active connections")
  }

  public func testGetConnectionNoInactiveConnectionsAddsAnActivePoolItemWithAValidKey() {
    let _ = try! connectionPool!.getConnection()!

    XCTAssertEqual("192.168.99.100_root_my-secret-pw_test", connectionPool!.activeConnections.keys.first!, "Key should have correct value")
  }

  public func testGetConnectionWithClosureReleasesConnectionAfterUse() {
    let _ = try! connectionPool!.getConnection() {
      (connection: MySQLConnectionProtocol) in
        XCTAssertEqual(1, connectionPool!.activeConnections.values.first?.count, "There should be one active connections")
    }

    XCTAssertEqual(1, connectionPool!.inactiveConnections.values.first?.count, "There should be one inactive connections")
  }

  public func testGetConnectionWithClosureExecutesClosurePassingConnection() {
    var closureCalled = false

    let _ = try! connectionPool!.getConnection() {
      (connection: MySQLConnectionProtocol) in
        closureCalled = true
    }

    XCTAssertTrue(closureCalled, "Closure should have been called")
  }

  public func testReleaseConnectionReturnsConnectionToThePool() {
    let connection = try! connectionPool!.getConnection()
    connectionPool!.releaseConnection(connection!)

    XCTAssertEqual(0, connectionPool!.activeConnections.values.first?.count, "There should be no active connections")
    XCTAssertEqual(1, connectionPool!.inactiveConnections.values.first?.count, "There should be one inactive connections")
  }

  // Async tests are not currently implemented for Swift mac 24_03 release
  //#if os(Linux)
  var timer = 0.0

  public func testGetConnectionBlocksWhenPoolIsExhausted() {
    let ex = expectation(description: "Should have blocked when no pool connections are available")

    connectionPool!.poolSize = 1
    let connection = try! connectionPool!.getConnection()

    queue!.async(execute: {
      let startTime = NSDate().timeIntervalSince1970
      let _ = try! self.connectionPool!.getConnection()

      let endTime = NSDate().timeIntervalSince1970
      self.timer = endTime - startTime

      ex.fulfill()
    })

    sleep(1)

    connectionPool!.releaseConnection(connection!)

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

    connectionPool!.poolSize = 1
    connectionPool!.poolTimeout = 1
    let _ = try! connectionPool!.getConnection()

    queue!.async(execute: {
      do {
        let _ = try self.connectionPool!.getConnection()
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

    connectionPool!.setLogger {
      (message: MySQLConnectionPoolMessage) in
        dispatchedMessage = message
    }

    let _ = try! connectionPool!.getConnection()

    XCTAssertEqual(MySQLConnectionPoolMessage.CreatedNewConnection, dispatchedMessage)
  }

  public func testBroadcastsEventWhenConnectionFailed() {
    mockConnection.connectError = MySQLError.UnableToCreateConnection

    var dispatchedMessage:MySQLConnectionPoolMessage?
    connectionPool!.setLogger {
      (message: MySQLConnectionPoolMessage) in
        dispatchedMessage = message
    }

    do {
      let _ = try connectionPool!.getConnection()
    } catch {}

    XCTAssertEqual(MySQLConnectionPoolMessage.FailedToCreateConnection, dispatchedMessage)
  }

  public func testBroadcastsEventWhenConnectionReused() {
    var dispatchedMessage:MySQLConnectionPoolMessage?

    connectionPool!.setLogger {
      (message: MySQLConnectionPoolMessage) in
        dispatchedMessage = message
    }

    let connection = try! connectionPool!.getConnection()
    connectionPool!.releaseConnection(connection!)

    let _ = try! connectionPool!.getConnection()

    XCTAssertEqual(MySQLConnectionPoolMessage.RetrievedConnectionFromPool, dispatchedMessage)
  }

  public func testBroadcastsEventWhenConnectionReconnected() {
    var dispatchedMessage = [MySQLConnectionPoolMessage]()

    connectionPool!.setLogger {
      (message: MySQLConnectionPoolMessage) in
        dispatchedMessage.append(message) // the event we are looking for will be the 2nd
    }
    let connection = try! connectionPool!.getConnection()
    connectionPool!.releaseConnection(connection!)
    mockConnection.isConnectedReturn = false

    let _ = try! connectionPool!.getConnection()

    XCTAssertEqual(MySQLConnectionPoolMessage.ConnectionDisconnected, dispatchedMessage[1])
  }
}

extension MySQLConnectionPoolTests {
  static var allTests: [(String, (MySQLConnectionPoolTests) -> () throws -> Void)] {
    return [
      ("testConnectionConnectCalled", testConnectionConnectCalled),
      ("testGetConnectionWithDefaultCharset", testGetConnectionWithDefaultCharset),
      ("testSetConnectionCharset", testSetConnectionCharset),
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
