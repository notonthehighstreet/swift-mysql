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

}

extension MySQLConnectionPoolTests {
    static var allTests: [(String, MySQLConnectionPoolTests -> () throws -> Void)] {
      return [
        ("testConnectionConnectCalled", testConnectionConnectCalled)
      ]
    }
}
