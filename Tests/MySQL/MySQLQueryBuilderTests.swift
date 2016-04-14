import Foundation
import XCTest

@testable import MySQL

public class MySQLQueryBuilderTests : XCTestCase {
  public func testInsertReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.insert(MySQLRow())

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testUpdateReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.update(MySQLRow())

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testSelectReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.select()

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testWheresReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.wheres()

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testInsertGeneratesValidQuery() {
    var data = MySQLRow()
    data["abc"] = "bcd"

    let query = MySQLQueryBuilder().insert(data).build()

    XCTAssertEqual("INSERT INTO ('abc') VALUES ('bcd')", query, "Should have returned valid query")
  }

  public func testTrimCommaTrimsWhenStatementEndsInAComma() {
    let statement = "INSERT BLAH ('dfdf',"
    let builder = MySQLQueryBuilder()

    XCTAssertEqual("INSERT BLAH ('dfdf'", builder.trimComma(statement), "Should have trimmed comma from statement")
  }

  public func testTrimCommaDoesNothingWhenStatementDoesNotEndInAComma() {
    let statement = "INSERT BLAH ('dfdf'"
    let builder = MySQLQueryBuilder()

    XCTAssertEqual("INSERT BLAH ('dfdf'", builder.trimComma(statement), "Should have trimmed comma from statement")
  }
}

extension MySQLQueryBuilderTests {
    static var allTests: [(String, MySQLQueryBuilderTests -> () throws -> Void)] {
      return [
        ("testInsertReturnsSelf", testInsertReturnsSelf),
        ("testUpdateReturnsSelf", testUpdateReturnsSelf),
        ("testSelectReturnsSelf", testSelectReturnsSelf),
        ("testWheresReturnsSelf", testWheresReturnsSelf),
        ("testInsertGeneratesValidQuery", testInsertGeneratesValidQuery),
        ("testTrimCommaTrimsWhenStatementEndsInAComma", testTrimCommaTrimsWhenStatementEndsInAComma)
      ]
    }
}
