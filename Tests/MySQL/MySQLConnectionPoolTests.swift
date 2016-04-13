import Foundation
import XCTest

@testable import MySQL

public class MySQLConnectionPoolTests: XCTestCase {

  var mockConnection = MockMySQLConnection()

  private func setupPool() {
    mockConnection = MockMySQLConnection()
    MySQLConnectionPool.setConnectionProvider() {
      return self.mockConnection
    }

    MySQLConnectionPool.activeConnections = [String: [MySQLConnectionProtocol]]()
    MySQLConnectionPool.inactiveConnections = [String: [MySQLConnectionProtocol]]()
  }

  public func testConnectionConnectCalled() {
    setupPool()
    do {
      var _ = try MySQLConnectionPool.getConnection("192.168.99.100", user: "root", password: "my-secret-pw", database: "")!

      XCTAssertTrue(mockConnection.connectCalled, "Connect should have been called")
    } catch {
      XCTFail("Unable to create connection")
    }
  }

  public func testGetConnectionWithNoInactiveConnectionsCreatesANewConnection() {
    setupPool()
    do {
      let connection = try MySQLConnectionPool.getConnection("192.168.99.100", user: "root", password: "my-secret-pw", database: "")!

      XCTAssertTrue(connection.equals(mockConnection), "Should have used connection from pool")
    } catch {
      XCTFail("Unable to create connection")
    }
  }

  public func testGetConnectionWithNoInactiveConnectionsAddsAnActivePoolItem() {
    setupPool()
    do {
      var _ = try MySQLConnectionPool.getConnection("192.168.99.100", user: "root", password: "my-secret-pw", database: "")!

      XCTAssertEqual(1, MySQLConnectionPool.activeConnections.values.first?.count, "Active connections should contain 1 item")
    } catch {
      XCTFail("Unable to create connection")
    }
  }

  public func testGetConnectionWithInactivePoolItemUsesExistingConnection() {
    setupPool()
    do {
      var inactiveConnections = [MySQLConnectionProtocol]()
      let tempConnection = MockMySQLConnection()
      inactiveConnections.append(tempConnection)

      MySQLConnectionPool.inactiveConnections["192.168.99.100_root_my-secret-pw_test"] = inactiveConnections

      let connection = try MySQLConnectionPool.getConnection("192.168.99.100", user: "root", password: "my-secret-pw", database: "test")!

      XCTAssertTrue(connection.equals(tempConnection), "Should have used connection from pool")
      XCTAssertEqual(1, MySQLConnectionPool.activeConnections.values.first?.count, "There should be no active connections")
      XCTAssertEqual(0, MySQLConnectionPool.inactiveConnections.values.first?.count, "There should be one inactive connections")
    } catch {
      XCTFail("Unable to create connection")
    }
  }

  public func testGetConnectionNoInactiveConnectionsAddsAnActivePoolItemWithAValidKey() {
    setupPool()
    do {
      var _ = try MySQLConnectionPool.getConnection("192.168.99.100", user: "root", password: "my-secret-pw", database: "test")!

      XCTAssertEqual("192.168.99.100_root_my-secret-pw_test", MySQLConnectionPool.activeConnections.keys.first!, "Key should have correct value")
    } catch {
      XCTFail("Unable to create connection")
    }
  }

  #if os(Linux)
  var timer = 0

  public func testGetConnectionBlocksWhenPoolIsExhausted() {
    setupPool()
    let expectation = XCTestCase.expectationWithDescription("Should have blocked when no pool connections are available")

    do {
      MySQLConnectionPool.poolSize = 1
      let connection = try MySQLConnectionPool.getConnection("192.168.99.100", user: "root", password: "my-secret-pw", database: "test")!
      let thread = NSThread(target:self, selector: #selector(MySQLConnectionPoolTests.poolThread), object:nil)


      //delay 1s
      MySQLConnectionPool.releaseConnection(connection)

    } catch {
      XCTFail("Unable to create connection")
    }

    waitForExpectationsWithTimeout(5) { error in
      XCTFail("Test should have returned")
    }

    //test equal elapsed time + delay interval
    XCTAssertEqual(2, timer, "Duration should have not elapsed")
  }

  @objc public func poolThread() {
    // should block until connection is released

    let _ = try MySQLConnectionPool.getConnection("192.168.99.100", user: "root", password: "my-secret-pw", database: "test")!
    expectation.fulfill()
    timer = 1
  }
  #else
  public func testGetConnectionBlocksWhenPoolIsExhausted() {}
  #endif

  public func testReleaseConnectionReturnsConnectionToThePool() {
    setupPool()
    do {
      let connection = try MySQLConnectionPool.getConnection("192.168.99.100", user: "root", password: "my-secret-pw", database: "test")!
      MySQLConnectionPool.releaseConnection(connection)

      XCTAssertEqual(0, MySQLConnectionPool.activeConnections.values.first?.count, "There should be no active connections")
      XCTAssertEqual(1, MySQLConnectionPool.inactiveConnections.values.first?.count, "There should be one inactive connections")
    } catch {
      XCTFail("Unable to create connection")
    }
  }
}

extension MySQLConnectionPoolTests {
  static var allTests: [(String, MySQLConnectionPoolTests -> () throws -> Void)] {
    return [
      ("testConnectionConnectCalled", testConnectionConnectCalled),
      ("testGetConnectionWithNoInactiveConnectionsCreatesANewConnection", testGetConnectionWithNoInactiveConnectionsCreatesANewConnection),
      ("testGetConnectionWithNoInactiveConnectionsAddsAnActivePoolItem", testGetConnectionWithNoInactiveConnectionsAddsAnActivePoolItem),
      ("testGetConnectionWithInactivePoolItemUsesExistingConnection", testGetConnectionWithInactivePoolItemUsesExistingConnection),
      ("testGetConnectionNoInactiveConnectionsAddsAnActivePoolItemWithAValidKey", testGetConnectionNoInactiveConnectionsAddsAnActivePoolItemWithAValidKey),
      ("testGetConnectionBlocksWhenPoolIsExhausted", testGetConnectionBlocksWhenPoolIsExhausted),
      ("testReleaseConnectionReturnsConnectionToThePool", testReleaseConnectionReturnsConnectionToThePool),
    ]
  }
}
