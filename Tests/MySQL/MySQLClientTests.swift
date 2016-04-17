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

    mysql.execute("something")

    XCTAssertEqual(connection.executeStatement, "something", "Query sent to connection not correct")
    XCTAssertTrue(connection.executeCalled, "Query should have been executed")
  }

  public func testClientExecutesQueryWithBuilder() {
    let connection = MockMySQLConnection()
    let mysql = createClient(connection)!
    let builder = MySQLQueryBuilder()
      .select("SELECT * FROM")
      .wheres("WHERE abc=?", parameters: "bcd")

    mysql.execute(builder)

    XCTAssertEqual(connection.executeStatement, "SELECT * FROM WHERE abc='bcd'", "Query sent to connection not correct")
    XCTAssertTrue(connection.executeCalled, "Query should have been executed")
  }

  public func testClientQueryReturnsMySQLResultWhenResultPresent() {
    let connection = MockMySQLConnection()
    connection.executeReturnResult = CMySQLResult(bitPattern: 12)
    connection.executeReturnHeaders = [CMySQLField]()

    let mysql = createClient(connection)!

    let result = mysql.execute("something")
    XCTAssertNotNil(result.0, "Query should have returned results")
  }

  public func testClientQueryDoesNotReturnMySQLResultWhenNoResult() {
    let connection = MockMySQLConnection()
    let mysql = createClient(connection)!

    let result = mysql.execute("something")
    XCTAssertNil(result.0, "Query should have been executed")
  }

  public func testClientQueryReturnsErrorWhenError() {
    let connection = MockMySQLConnection()
    connection.executeReturnError = MySQLError.UnableToExecuteQuery(message: "boom")

    let mysql = createClient(connection)!

    let result = mysql.execute("something")
    XCTAssertNotNil(result.1, "Query should have returned an error")
  }
}

extension MySQLClientTests {
    static var allTests: [(String, MySQLClientTests -> () throws -> Void)] {
      return [
        ("testSetsInitParameters", testSetsInitParameters),
        ("testClientInfoReturnsClientInfo", testClientInfoReturnsClientInfo),
        ("testClientVersionReturnsClientVersion", testClientVersionReturnsClientVersion),
        ("testClientExecutesQuery", testClientExecutesQuery),
        ("testClientExecutesQueryWithBuilder", testClientExecutesQueryWithBuilder),
        ("testClientQueryReturnsMySQLResultWhenResultPresent", testClientQueryReturnsMySQLResultWhenResultPresent),
        ("testClientQueryDoesNotReturnMySQLResultWhenNoResult", testClientQueryDoesNotReturnMySQLResultWhenNoResult),
        ("testClientQueryReturnsErrorWhenError", testClientQueryReturnsErrorWhenError)
      ]
    }
}
