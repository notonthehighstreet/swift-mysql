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

  public func testGetConnectionWithNoInactiveConnectionsAddsAnActivePoolItem() {
    setupPool()
    do {
      var _ = try MySQLConnectionPool.getConnection("192.168.99.100", user: "root", password: "my-secret-pw", database: "")!

      XCTAssertEqual(1, MySQLConnectionPool.activeConnections.values.first?.count, "Active connections should contain 1 item")
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
        ("testGetConnectionWithNoInactiveConnectionsAddsAnActivePoolItem", testGetConnectionWithNoInactiveConnectionsAddsAnActivePoolItem),
        ("testGetConnectionNoInactiveConnectionsAddsAnActivePoolItemWithAValidKey", testGetConnectionNoInactiveConnectionsAddsAnActivePoolItemWithAValidKey),
        ("testReleaseConnectionReturnsConnectionToThePool", testReleaseConnectionReturnsConnectionToThePool)
      ]
    }
}
