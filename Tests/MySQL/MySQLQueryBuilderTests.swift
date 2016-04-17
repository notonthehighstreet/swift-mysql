import Foundation
import XCTest

@testable import MySQL

public class MySQLQueryBuilderTests : XCTestCase {
  public func testInsertReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.insert(MySQLRow(), table: "")

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testUpdateReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.update(MySQLRow(), table: "")

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testSelectReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.select("")

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testSelectWithFieldsReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.select([""], table: "")

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testWheresReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.wheres("something = ?", parameters: "value")

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testSelectReturnsValidQuery() {
    let builder = MySQLQueryBuilder()
    let statement = builder
      .select("SELECT * FROM TABLE")
      .build()

    XCTAssertEqual("SELECT * FROM TABLE", statement, "Returned invalid select statement")
  }

  public func testSelectWithArrayReturnsValidQuery() {
    let builder = MySQLQueryBuilder()
    let statement = builder
        .select(["Field1", "Field2"], table: "MyTABLE")
        .build()

    XCTAssertEqual("SELECT Field1, Field2 FROM MyTABLE", statement, "Returned invalid select statement")
  }

  public func testInsertGeneratesValidQuery() {
    var data = MySQLRow()
    data["abc"] = "bcd"

    let query = MySQLQueryBuilder()
    .insert(data, table: "MyTable")
    .build()

    XCTAssertEqual("INSERT INTO MyTable ('abc') VALUES ('bcd')", query, "Should have returned valid query")
  }

  public func testUpdateGeneratesValidQuery() {
    var data = MySQLRow()
    data["abc"] = "abc"
    data["bcd"] = "bcd"

    let query = MySQLQueryBuilder()
      .update(data, table: "MyTable")
      .build()

    XCTAssertEqual("UPDATE MyTable SET abc='abc', bcd='bcd'", query, "Should have returned valid query")
  }

  public func testWheresGeneratesValidQuery() {
    let query = MySQLQueryBuilder()
      .wheres("WHERE param1=? and param2=?", parameters: "abc", "bcd")
      .build()

    XCTAssertEqual("WHERE param1='abc' and param2='bcd'", query, "Should have returned valid query")
  }

  public func testSelectWithWheresGeneratesValidQuery() {
    let query = MySQLQueryBuilder()
      .select("SELECT * FROM TABLE")
      .wheres("WHERE param1=? and param2=?", parameters: "abc", "bcd")
      .build()

    XCTAssertEqual("SELECT * FROM TABLE WHERE param1='abc' and param2='bcd'", query, "Should have returned valid query")
  }

  public func testUpdateWithWheresGeneratesValidQuery() {
    let query = MySQLQueryBuilder()
      .update(["abc": "bcd"], table: "MyTable")
      .wheres("WHERE param1=? and param2=?", parameters: "abc", "bcd")
      .build()

    XCTAssertEqual("UPDATE MyTable SET abc='bcd' WHERE param1='abc' and param2='bcd'", query, "Should have returned valid query")
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
        ("testSelectWithFieldsReturnsSelf", testSelectWithFieldsReturnsSelf),
        ("testWheresReturnsSelf", testWheresReturnsSelf),
        ("testSelectReturnsValidQuery", testSelectReturnsValidQuery),
        ("testSelectWithArrayReturnsValidQuery", testSelectWithArrayReturnsValidQuery),
        ("testInsertGeneratesValidQuery", testInsertGeneratesValidQuery),
        ("testUpdateGeneratesValidQuery", testUpdateGeneratesValidQuery),
        ("testWheresGeneratesValidQuery", testWheresGeneratesValidQuery),
        ("testSelectWithWheresGeneratesValidQuery", testSelectWithWheresGeneratesValidQuery),
        ("testUpdateWithWheresGeneratesValidQuery", testUpdateWithWheresGeneratesValidQuery),
        ("testTrimCharTrimsWhenStatementEndsInAComma", testTrimCharTrimsWhenStatementEndsInAComma),
        ("testTrimCharDoesNothingWhenStatementDoesNotEndInAComma", testTrimCharDoesNothingWhenStatementDoesNotEndInAComma)
      ]
    }
}
