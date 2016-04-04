import Foundation
import XCTest
import CMySQLClient

@testable import MySQL

public class MySQLResultTests: XCTestCase {
  var field1 = MYSQL_FIELD()
  var field2 = MYSQL_FIELD()

  private func buildFields() -> [CMySQLField] {
    field1.name = UnsafeMutablePointer<Int8>(("myname" as NSString).UTF8String)
    field2.name = UnsafeMutablePointer<Int8>(("second" as NSString).UTF8String)

    var fields = [CMySQLField]()
    fields.append(&field1)
    fields.append(&field2)

    return fields
  }

  public func testParsesHeadersOnInit() {
    let connection = MockMySQLConnection()
    let cresult = CMySQLResult(bitPattern: 12)
    let myresult = MySQLResult(
      result: cresult,
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
      result: cresult,
      fields: buildFields(),
      nextResult:connection.nextResult)
    let next = myresult.nextResult()

    XCTAssertNil(next, "Result should be nil")
  }

  public func testNextResultReturnsRow() {
    let cRow = CMySQLRow(allocatingCapacity: 2)
    cRow[0] = UnsafeMutablePointer<Int8>(("myvalue" as NSString).UTF8String)
    cRow[1] = UnsafeMutablePointer<Int8>(("myvalue2" as NSString).UTF8String)

    let connection = MockMySQLConnection()
    connection.nextResultReturn = cRow

    let cresult = CMySQLResult(bitPattern: 12)
    let myresult = MySQLResult(result: cresult, fields: buildFields(), nextResult:connection.nextResult)
    let next = myresult.nextResult()

    XCTAssertNotNil(next, "Result should not be nil")
  }

  public func testNextResultParsesRow() {
    let cRow = CMySQLRow(allocatingCapacity: 2)
    cRow[0] = UnsafeMutablePointer<Int8>(("myvalue" as NSString).UTF8String)
    cRow[1] = UnsafeMutablePointer<Int8>(("myvalue2" as NSString).UTF8String)

    let connection = MockMySQLConnection()
    connection.nextResultReturn = cRow

    let cresult = CMySQLResult(bitPattern: 12)
    let myresult = MySQLResult(result: cresult, fields: buildFields(), nextResult:connection.nextResult)
    let next = myresult.nextResult()

    XCTAssertEqual("myvalue", (next!["myname"] as! String), "Result should not be nil")
  }

}

extension MySQLResultTests {
  static var allTests: [(String, MySQLResultTests -> () throws -> Void)] {
    return [
      ("testParsesHeadersOnInit", testParsesHeadersOnInit),
      ("testNextResultReturnsNilWhenNoResult", testNextResultReturnsNilWhenNoResult),
      ("testNextResultReturnsRow", testNextResultReturnsRow),
      ("testNextResultParsesRow", testNextResultParsesRow)
    ]
  }
}
