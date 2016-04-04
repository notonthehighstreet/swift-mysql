import Foundation
import XCTest

@testable import MySQL

public class MySQLClientTests: XCTestCase {

  public func createClient(connection: MySQLConnectionProtocol) -> MySQLClient? {
    return MySQLClient(connection: connection)
  }

  public func testSetsInitParameters() {
    let connection = MockMySQLConnection()
    let mysql = createClient(connection)!
    XCTAssertNotNil(mysql.connection, "Should have set connection")
  }

  public func testClientInfoReturnsClientInfo() {
    let connection = MockMySQLConnection()
    connection.clientInfo = "testinfo"

    let mysql = createClient(connection)!
    let info = mysql.info()
    XCTAssertEqual(connection.clientInfo, info, "Correct client info should have been returned")
  }

  public func testClientVersionReturnsClientVersion() {
    let connection = MockMySQLConnection()
    connection.clientVersion = 100

    let mysql = createClient(connection)!
    let version = mysql.version()
    XCTAssertEqual(connection.clientVersion, version, "Correct client version should have been returned")
  }

  //TODO: implement these tests correctly this is just a placeholder
  public func testClientExecutesQuery() {
    let connection = MockMySQLConnection()
    let mysql = createClient(connection)!

    mysql.execute("soemthing")
    XCTAssertTrue(connection.executeCalled, "Query should have been executed")
  }
}

extension MySQLClientTests {
    static var allTests: [(String, MySQLClientTests -> () throws -> Void)] {
      return [
        ("testSetsInitParameters", testSetsInitParameters),
        ("testClientInfoReturnsClientInfo", testClientInfoReturnsClientInfo),
        ("testClientVersionReturnsClientVersion", testClientVersionReturnsClientVersion),
        ("testClientExecutesQuery", testClientExecutesQuery)
      ]
    }
}
