import Foundation
import XCTest

@testable import MySQL

public class MySQLConnectionTests: XCTestCase {
  var mockConnection:MockMySQLInternalConnection?
  var connection: MySQLConnection?

  public override func setUp() {
    mockConnection = MockMySQLInternalConnection()
    connection = MySQLConnection(connection: mockConnection!)
  }

  public func testClientInfoReturnsClientInfo() {
    mockConnection!.clientInfo = "testinfo"

    let info = connection!.info()
    XCTAssertEqual(mockConnection!.clientInfo, info, "Correct connection info should have been returned")
  }

  public func testClientVersionReturnsClientVersion() {
    mockConnection!.clientVersion = 100

    let version = connection!.version()
    XCTAssertEqual(mockConnection!.clientVersion, version, "Correct connection version should have been returned")
  }

  public func testClientExecutesQuery() throws {
    let _ = try connection!.execute(query: "something")

    XCTAssertEqual(mockConnection!.executeStatement, "something", "Query sent to connection not correct")
    XCTAssertTrue(mockConnection!.executeCalled, "Query should have been executed")
  }

  public func testClientExecutesQueryWithBuilder() throws {
    let builder = MySQLQueryBuilder()
      .select(statement: "SELECT * FROM")
      .wheres(statement: "abc=?", parameters: "bcd")

    let _ = try connection!.execute(builder: builder)

    XCTAssertEqual(mockConnection!.executeStatement, 
                   "SELECT * FROM WHERE abc='bcd';", 
                   "Query sent to connection not correct")
    XCTAssertTrue(mockConnection!.executeCalled, "Query should have been executed")
  }

  public func testClientQueryReturnsMySQLResultWhenResultPresent() throws {
    mockConnection!.executeReturnResult = CMySQLResult(bitPattern: 12)
    mockConnection!.executeReturnHeaders = [CMySQLField]()

    let result = try connection!.execute(query: "something")

    XCTAssertNotNil(result, "Query should have returned results")
  }

  public func testClientQuerySetsAffectedRowsWhenNoResult() throws {
    mockConnection!.executeReturnRows = 0
    let result = try connection!.execute(query: "something")

    XCTAssertEqual(0, result.affectedRows, "Affected rows should be 0 when no result")
  }

  public func testClientQueryReturnsErrorWhenError() throws {
    mockConnection!.executeReturnError = MySQLError.UnableToExecuteQuery(message: "boom")

    var err: Error?

    do {
        let _ = try connection!.execute(query: "something")
    }catch {
        err = error
    }

    XCTAssertNotNil(err, "Query should have returned an error")
  }

  public func testClientNextResultSetReturnsMySQLResultWhenResultPresent() throws {
    mockConnection!.nextResultReturnResult = CMySQLResult(bitPattern: 12)
    mockConnection!.nextResultReturnHeaders = [CMySQLField]()

    let result = try connection!.nextResultSet()

    XCTAssertNotNil(result, "Query should have returned results")
  }

  public func testClientNextResultSetReturnsNilWhenNoResultPresent() {
    mockConnection!.nextResultSetErrorReturn = MySQLError.NoMoreResults

    var err: Error?
    var result: MySQLResultProtocol?

    do {
        result = try connection!.nextResultSet()
    } catch {
        err = error
    }

    XCTAssertNil(result, "Query should not have returned results")
    XCTAssertNotNil(err, "Query should have returned error")
  }

    public func testStartCallsStartTransaction() throws {
        connection!.startTransaction()

        XCTAssertTrue(mockConnection!.startTransactionCalled)
    }
    
    public func testCommitCallsCommitTransaction() throws {
        try connection!.commitTransaction()

        XCTAssertTrue(mockConnection!.commitTransactionCalled)
    }
    
    public func testRollbackCallsRollbackTransaction() throws {
        try connection!.rollbackTransaction()

        XCTAssertTrue(mockConnection!.rollbackTransactionCalled)
    }
}

extension MySQLConnectionTests {
    static var allTests: [(String, (MySQLConnectionTests) -> () throws -> Void)] {
      return [
        ("testClientInfoReturnsClientInfo", testClientInfoReturnsClientInfo),
        ("testClientVersionReturnsClientVersion", testClientVersionReturnsClientVersion),
        ("testClientExecutesQuery", testClientExecutesQuery),
        ("testClientExecutesQueryWithBuilder", testClientExecutesQueryWithBuilder),
        ("testClientQueryReturnsMySQLResultWhenResultPresent", testClientQueryReturnsMySQLResultWhenResultPresent),
        ("testClientQuerySetsAffectedRowsWhenNoResult", testClientQuerySetsAffectedRowsWhenNoResult),
        ("testClientQueryReturnsErrorWhenError", testClientQueryReturnsErrorWhenError),
        ("testClientNextResultSetReturnsMySQLResultWhenResultPresent", testClientNextResultSetReturnsMySQLResultWhenResultPresent),
        ("testClientNextResultSetReturnsNilWhenNoResultPresent", testClientNextResultSetReturnsNilWhenNoResultPresent),
        ("testStartCallsStartTransaction", testStartCallsStartTransaction), 
        ("testCommitCallsCommitTransaction", testCommitCallsCommitTransaction), 
        ("testRollbackCallsRollbackTransaction", testRollbackCallsRollbackTransaction)
      ]
    }
}
