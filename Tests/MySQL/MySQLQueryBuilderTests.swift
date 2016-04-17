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
    let ret = builder.select("")

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testWheresReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.wheres("something = ?", parameters: "value")

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testSelectReturnsValidQuery() {
    let builder = MySQLQueryBuilder()
    builder.select("SELECT * FROM TABLE")
    let statement = builder.build()

    XCTAssertEqual("SELECT * FROM TABLE", statement, "Returned invalid select statement")
  }

  public func testSelectWithArrayReturnsValidQuery() {
    let builder = MySQLQueryBuilder()
    builder.select(["Field1", "Field2"], table: "MyTABLE")
    let statement = builder.build()

    XCTAssertEqual("SELECT Field1, Field2 FROM MyTABLE", statement, "Returned invalid select statement")
  }

  public func testInsertGeneratesValidQuery() {
    var data = MySQLRow()
    data["abc"] = "bcd"

    let query = MySQLQueryBuilder().insert(data).build()

    XCTAssertEqual("INSERT INTO ('abc') VALUES ('bcd')", query, "Should have returned valid query")
  }

  public func testTrimCharTrimsWhenStatementEndsInAComma() {
    let statement = "INSERT BLAH ('dfdf',"

    XCTAssertEqual("INSERT BLAH ('dfdf'", statement.trimChar(","), "Should have trimmed comma from statement")
  }

  public func testTrimCharDoesNothingWhenStatementDoesNotEndInAComma() {
    let statement = "INSERT BLAH ('dfdf'"

    XCTAssertEqual("INSERT BLAH ('dfdf'", statement.trimChar(","), "Should have trimmed comma from statement")
  }
}

extension MySQLQueryBuilderTests {
    static var allTests: [(String, MySQLQueryBuilderTests -> () throws -> Void)] {
      return [
        ("testInsertReturnsSelf", testInsertReturnsSelf),
        ("testUpdateReturnsSelf", testUpdateReturnsSelf),
        ("testSelectReturnsSelf", testSelectReturnsSelf),
        ("testWheresReturnsSelf", testWheresReturnsSelf),
        ("testSelectReturnsValidQuery", testSelectReturnsValidQuery),
        ("testInsertGeneratesValidQuery", testInsertGeneratesValidQuery),
        ("testTrimCharTrimsWhenStatementEndsInAComma", testTrimCharTrimsWhenStatementEndsInAComma),
        ("testSelectWithArrayReturnsValidQuery", testSelectWithArrayReturnsValidQuery),
        ("testTrimCharDoesNothingWhenStatementDoesNotEndInAComma", testTrimCharDoesNothingWhenStatementDoesNotEndInAComma)
      ]
    }
}
