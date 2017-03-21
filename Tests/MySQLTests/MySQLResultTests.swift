import Foundation
import XCTest
import CMySQLClient

@testable import MySQL

public class MySQLResultTests: XCTestCase {
  var field1 = MYSQL_FIELD()
  var field2 = MYSQL_FIELD()

  private func buildFields() -> [CMySQLField] {
    field1.name = "myname".getUnsafeMutablePointer()
    field1.type = MYSQL_TYPE_STRING

    field2.name = "second".getUnsafeMutablePointer()
    field2.type = MYSQL_TYPE_STRING

    var fields = [CMySQLField]()
    fields.append(&field1)
    fields.append(&field2)

    return fields
  }

  public func testParsesHeadersOnInit() {
    let connection = MockMySQLConnection()
    let cresult = CMySQLResult(bitPattern: 12)
    let myresult = MySQLResult(
      result: cresult!,
      fields: buildFields(),
      nextResult:connection.nextResult)

    XCTAssertEqual(2, myresult.fields.count, "Should have returned two headers")
    XCTAssertEqual("myname", myresult.fields[0].name, "Field not equal")
    XCTAssertEqual("second", myresult.fields[1].name, "Field not equal")
  }

  public func testNextResultReturnsNilWhenNoResult() {
    let connection = MockMySQLConnection()
    let cresult = CMySQLResult(bitPattern: 12)
    let myresult = MySQLResult(
      result: cresult!,
      fields: buildFields(),
      nextResult:connection.nextResult)
    let next = myresult.nextResult()

    XCTAssertNil(next, "Result should be nil")
  }

  public func testNextResultReturnsRow() {
    let cRow = CMySQLRow.allocate(capacity: 2)

    cRow[0] = "myvalue".getUnsafeMutablePointer()
    cRow[1] = "myvalue2".getUnsafeMutablePointer()

    let connection = MockMySQLConnection()
    connection.nextResultReturn = cRow

    let cresult = CMySQLResult(bitPattern: 12)
    let myresult = MySQLResult(result: cresult!, fields: buildFields(), nextResult:connection.nextResult)
    let next = myresult.nextResult()

    XCTAssertNotNil(next, "Result should not be nil")
  }

  public func testNextResultParsesRow() {
    let cRow = CMySQLRow.allocate(capacity: 2)

    cRow[0] = "myvalue".getUnsafeMutablePointer()
    cRow[1] = "myvalue2".getUnsafeMutablePointer()

    let connection = MockMySQLConnection()
    connection.nextResultReturn = cRow

    let cresult = CMySQLResult(bitPattern: 12)
    let myresult = MySQLResult(result: cresult!, fields: buildFields(), nextResult:connection.nextResult)
    let next = myresult.nextResult()

    XCTAssertEqual("myvalue", (next!["myname"] as! String), "Result should not be nil")
  }

}

extension MySQLResultTests {
  static var allTests: [(String, (MySQLResultTests) -> () throws -> Void)] {
    return [
      ("testParsesHeadersOnInit", testParsesHeadersOnInit),
      ("testNextResultReturnsNilWhenNoResult", testNextResultReturnsNilWhenNoResult),
      ("testNextResultReturnsRow", testNextResultReturnsRow),
      ("testNextResultParsesRow", testNextResultParsesRow)
    ]
  }
}
