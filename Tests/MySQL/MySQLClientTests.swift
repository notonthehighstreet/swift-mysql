import Foundation
import XCTest

@testable import MySQL

public class MySQLClientTests: XCTestCase {
  var mockConnection:MockMySQLConnection?
  var client: MySQLClient?

  public override func setUp() {
    mockConnection = MockMySQLConnection()
    client = MySQLClient(connection: mockConnection!)
  }

  public func testClientInfoReturnsClientInfo() {
    mockConnection!.clientInfo = "testinfo"

    let info = client!.info()
    XCTAssertEqual(mockConnection!.clientInfo, info, "Correct client info should have been returned")
  }

  public func testClientVersionReturnsClientVersion() {
    mockConnection!.clientVersion = 100

    let version = client!.version()
    XCTAssertEqual(mockConnection!.clientVersion, version, "Correct client version should have been returned")
  }

  //TODO: implement these tests correctly this is just a placeholder
  public func testClientExecutesQuery() {
    client!.execute("something")

    XCTAssertEqual(mockConnection!.executeStatement, "something", "Query sent to connection not correct")
    XCTAssertTrue(mockConnection!.executeCalled, "Query should have been executed")
  }

  public func testClientExecutesQueryWithBuilder() {
    let builder = MySQLQueryBuilder()
      .select("SELECT * FROM")
      .wheres("WHERE abc=?", parameters: "bcd")

    client!.execute(builder)

    XCTAssertEqual(mockConnection!.executeStatement, "SELECT * FROM WHERE abc='bcd'", "Query sent to connection not correct")
    XCTAssertTrue(mockConnection!.executeCalled, "Query should have been executed")
  }

  public func testClientQueryReturnsMySQLResultWhenResultPresent() {
    mockConnection!.executeReturnResult = CMySQLResult(bitPattern: 12)
    mockConnection!.executeReturnHeaders = [CMySQLField]()

    let result = client!.execute("something")

    XCTAssertNotNil(result.0, "Query should have returned results")
  }

  public func testClientQueryDoesNotReturnMySQLResultWhenNoResult() {
    let result = client!.execute("something")

    XCTAssertNil(result.0, "Query should have been executed")
  }

  public func testClientQueryReturnsErrorWhenError() {
    mockConnection!.executeReturnError = MySQLError.UnableToExecuteQuery(message: "boom")

    let result = client!.execute("something")

    XCTAssertNotNil(result.1, "Query should have returned an error")
  }
}

extension MySQLClientTests {
    static var allTests: [(String, MySQLClientTests -> () throws -> Void)] {
      return [
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
