import Foundation
import XCTest

@testable import MySQL

public class MySQLQueryBuilderTests : XCTestCase {
  public func testInsertReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.insert(data: MySQLRow(), table: "")

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testUpdateReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.update(data: MySQLRow(), table: "")

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testDeleteReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.delete(fromTable: "")

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testSelectReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.select(statement: "")

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testSelectWithFieldsReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.select(fields: [""], table: "")

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testWheresReturnsSelf() {
    let builder = MySQLQueryBuilder()
    let ret = builder.wheres(statement: "something = ?", parameters: "value")

    XCTAssertEqual(builder, ret, "Should have returned self")
  }

  public func testSelectReturnsValidQuery() {
    let builder = MySQLQueryBuilder()
    let statement = builder
      .select(statement: "SELECT * FROM TABLE")
      .build()

    XCTAssertEqual("SELECT * FROM TABLE;", statement, "Returned invalid select statement")
  }

  public func testSelectWithArrayReturnsValidQuery() {
    let builder = MySQLQueryBuilder()
    let statement = builder
        .select(fields: ["Field1", "Field2"], table: "MyTABLE")
        .build()

    XCTAssertEqual("SELECT MyTABLE.Field1, MyTABLE.Field2 FROM MyTABLE;", statement, "Returned invalid select statement")
  }

  public func testInsertGeneratesValidQuery() {
    var data = MySQLRow()
    data["abc"] = "bcd"
    data["bcd"] = "efg"

    let query = MySQLQueryBuilder()
    .insert(data: data, table: "MyTable")
    .build()

    XCTAssertEqual("INSERT INTO MyTable (abc, bcd) VALUES ('bcd', 'efg');", query, "Should have returned valid query")
  }

  public func testUpdateGeneratesValidQuery() {
    var data = MySQLRow()
    data["abc"] = "abc"
    data["bcd"] = "bcd"

    let query = MySQLQueryBuilder()
      .update(data: data, table: "MyTable")
      .build()

    XCTAssertEqual("UPDATE MyTable SET abc='abc', bcd='bcd';", query, "Should have returned valid query")
  }
  
  public func testUpsertGeneratesValidQuery() {
    var data = MySQLRow()
    data["abc"] = "abc"
    data["bcd"] = "bcd"

    let query = MySQLQueryBuilder()
      .upsert(data: data, table: "MyTable")
      .build()
    
      XCTAssertEqual("INSERT INTO MyTable (abc, bcd) VALUES ('abc', 'bcd') ON DUPLICATE KEY UPDATE abc = 'abc', bcd = 'bcd';", 
                   query,
                   "Should have returned valid query")
  }

  public func testDeleteGeneratesValidQuery() {
    let builder = MySQLQueryBuilder()
    let statement = builder
        .delete(fromTable: "MyTABLE")
        .build()

    XCTAssertEqual("DELETE FROM MyTABLE;", statement, "Returned invalid select statement")
  }

  public func testWheresGeneratesValidQuery() {
    let query = MySQLQueryBuilder()
      .wheres(statement: "param1=? and param2=?", parameters: "abc", "bcd")
      .build()

    XCTAssertEqual(" WHERE param1='abc' and param2='bcd';", query, "Should have returned valid query")
  }

  public func testSelectWithWheresGeneratesValidQuery() {
    let query = MySQLQueryBuilder()
      .select(statement: "SELECT * FROM TABLE")
      .wheres(statement: "param1=? and param2=?", parameters: "abc", "bcd")
      .build()

    XCTAssertEqual("SELECT * FROM TABLE WHERE param1='abc' and param2='bcd';", query, "Should have returned valid query")
  }
  
  public func testSelectWithWheresAndFieldsGeneratesValidQuery() {
    let query = MySQLQueryBuilder()
      .select(fields: ["Field1", "Field2"], table: "MyTable")
      .wheres(statement: "Field1=? and Field2=?", parameters: "abc", "bcd")
      .build()

    XCTAssertEqual("SELECT MyTable.Field1, MyTable.Field2 FROM MyTable WHERE MyTable.Field1='abc' and MyTable.Field2='bcd';", 
                   query, 
                   "Should have returned valid query")
  }

  public func testUpdateWithWheresGeneratesValidQuery() {
    let query = MySQLQueryBuilder()
      .update(data: ["abc": "bcd"], table: "MyTable")
      .wheres(statement: "param1=? and param2=?", parameters: "abc", "bcd")
      .build()

    XCTAssertEqual("UPDATE MyTable SET abc='bcd' WHERE param1='abc' and param2='bcd';", query, "Should have returned valid query")
  }

  public func testDeleteWithWheresGeneratesValidQuery() {
    let query = MySQLQueryBuilder()
        .delete(fromTable: "MyTable")
        .wheres(statement: "id=?", parameters: "2")
        .build()

    XCTAssertEqual("DELETE FROM MyTable WHERE id='2';", query, "Should have returned valid query")
  }

  public func testJoinWithOneJoinConcatenatesQuery() {
    let builder = MySQLQueryBuilder()
        .select(fields: ["Field1", "Field2"], table: "MyTable1")

    let builder2 = MySQLQueryBuilder()
      .select(fields: ["Id"], table: "MyTable2")
      .wheres(statement: "param1=? and param2=?", parameters: "abc", "bcd")

    let query = builder.join(builder: builder2, from: "Field1", to: "Id", type: .InnerJoin).build()

    XCTAssertEqual("SELECT MyTable1.Field1, MyTable1.Field2, MyTable2.Id FROM MyTable1 " +
                   "INNER JOIN MyTable2 ON MyTable1.Field1 = MyTable2.Id;",
                   query, 
                   "Should have returned valid query")
  }

  public func testTrimCharTrimsWhenStatementEndsInAComma() {
    let statement = "INSERT BLAH ('dfdf',"

    XCTAssertEqual("INSERT BLAH ('dfdf'", statement.trimChar(character: ","), "Should have trimmed comma from statement")
  }

  public func testTrimCharDoesNothingWhenStatementDoesNotEndInAComma() {
    let statement = "INSERT BLAH ('dfdf'"

    XCTAssertEqual("INSERT BLAH ('dfdf'", statement.trimChar(character: ","), "Should have trimmed comma from statement")
  }
}

extension MySQLQueryBuilderTests {
    static var allTests: [(String, (MySQLQueryBuilderTests) -> () throws -> Void)] {
      return [
        ("testInsertReturnsSelf", testInsertReturnsSelf),
        ("testUpdateReturnsSelf", testUpdateReturnsSelf),
        ("testDeleteReturnsSelf", testDeleteReturnsSelf),
        ("testSelectReturnsSelf", testSelectReturnsSelf),
        ("testSelectWithFieldsReturnsSelf", testSelectWithFieldsReturnsSelf),
        ("testWheresReturnsSelf", testWheresReturnsSelf),
        ("testSelectReturnsValidQuery", testSelectReturnsValidQuery),
        ("testSelectWithArrayReturnsValidQuery", testSelectWithArrayReturnsValidQuery),
        ("testInsertGeneratesValidQuery", testInsertGeneratesValidQuery),
        ("testUpdateGeneratesValidQuery", testUpdateGeneratesValidQuery),
        ("testDeleteGeneratesValidQuery", testDeleteGeneratesValidQuery),
        ("testWheresGeneratesValidQuery", testWheresGeneratesValidQuery),
        ("testSelectWithWheresGeneratesValidQuery", testSelectWithWheresGeneratesValidQuery),
        ("testUpdateWithWheresGeneratesValidQuery", testUpdateWithWheresGeneratesValidQuery),
        ("testDeleteWithWheresGeneratesValidQuery", testDeleteWithWheresGeneratesValidQuery),
        ("testJoinWithOneJoinConcatenatesQuery", testJoinWithOneJoinConcatenatesQuery),
        ("testTrimCharTrimsWhenStatementEndsInAComma", testTrimCharTrimsWhenStatementEndsInAComma),
        ("testTrimCharDoesNothingWhenStatementDoesNotEndInAComma", testTrimCharDoesNothingWhenStatementDoesNotEndInAComma)
      ]
    }
}
