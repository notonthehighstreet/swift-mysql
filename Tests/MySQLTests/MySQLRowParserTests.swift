import Foundation
import XCTest
import CMySQLClient

@testable import MySQL

public class MySQLRowParserTests: XCTestCase {

  let parser = MySQLRowParser()
  let cRow = CMySQLRow.allocate(capacity: 1)
  var headers = [MySQLField]()

  public override func setUp() {
    var header1 = MySQLField(name: "tester", type: MySQLFieldType.String)
    header1.name = "header1"

    headers.append(header1)
  }

  public func testParsesRowWithStringValue() {
    cRow[0] = "myvalue".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.String

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertEqual("myvalue", (row["header1"] as! String))
  }

  public func testParsesFieldWithNilValueSetsNil() {
    cRow[0] = nil
    headers[0].type = MySQLFieldType.String

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertNil(row["header1"])
  }

  public func testParsesFieldWithStringValueSetsTypeString() {
    cRow[0] = "myvalue".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.String

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertTrue(row["header1"] is String, "Type should be String")
  }

  public func testParsesFieldWithVarStringValueSetsTypeString() {
    cRow[0] = "myvalue".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.VarString

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertTrue(row["header1"] is String, "Type should be String")
  }

  public func testParsesFieldWithTinyValueSetsTypeInt() {
    cRow[0] = "1".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.Tiny

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertEqual(1, row["header1"] as? Int)
    XCTAssertTrue(row["header1"] is Int, "Type should be Int")
  }

  public func testParsesFieldWithShortValueSetsTypeInt() {
    cRow[0] = "1".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.Short

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertEqual(1, row["header1"] as? Int)
    XCTAssertTrue(row["header1"] is Int, "Type should be Int")
  }

  public func testParsesFieldWithLongValueSetsTypeInt() {
    cRow[0] = "1".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.Long

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertEqual(1, row["header1"] as? Int)
    XCTAssertTrue(row["header1"] is Int, "Type should be Int")
  }

  public func testParsesFieldWithInt24ValueSetsTypeInt() {
    cRow[0] = "1".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.Int24

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertEqual(1, row["header1"] as? Int)
    XCTAssertTrue(row["header1"] is Int, "Type should be Int")
  }

  public func testParsesFieldWithLongLongValueSetsTypeInt() {
    cRow[0] = "1".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.LongLong

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertEqual(1, row["header1"] as? Int)
    XCTAssertTrue(row["header1"] is Int, "Type should be Int")
  }

  public func testParsesFieldWithDecimalValueSetsTypeDouble() {
    cRow[0] = "1".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.Decimal

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertEqual(1, row["header1"] as? Double)
    XCTAssertTrue(row["header1"] is Double, "Type should be Double")
  }

  public func testParsesFieldWithNewDecimalValueSetsTypeDouble() {
    cRow[0] = "1".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.NewDecimal

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertEqual(1, row["header1"] as? Double)
    XCTAssertTrue(row["header1"] is Double, "Type should be Double")
  }

  public func testParsesFieldWithFloatValueSetsTypeFloat() {
    cRow[0] = "1".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.Float

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertEqual(1, row["header1"] as? Float)
    XCTAssertTrue(row["header1"] is Float, "Type should be Float")
  }

  public func testParsesFieldWithDoubleValueSetsTypeDouble() {
    cRow[0] = "1".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.Double

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertEqual(1, row["header1"] as? Double)
    XCTAssertTrue(row["header1"] is Double, "Type should be Double")
  }

  public func testParsesFieldWithTimestampValueSetsTypeString() {
    cRow[0] = "1".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.Timestamp

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertTrue(row["header1"] is String, "Type should be String")
  }

  public func testParsesFieldWithBlobValueSetsTypeString() {
    cRow[0] = "1".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.Blob

    let row = parser.parse(row: cRow, headers: headers)

    XCTAssertTrue(row["header1"] is String, "Type should be String")
  }
}

extension MySQLRowParserTests {
    static var allTests: [(String, (MySQLRowParserTests) -> () throws -> Void)] {
      return [
        ("testParsesRowWithStringValue", testParsesRowWithStringValue),
        ("testParsesFieldWithNilValueSetsNil", testParsesFieldWithNilValueSetsNil),
        ("testParsesFieldWithStringValueSetsTypeString", testParsesFieldWithStringValueSetsTypeString),
        ("testParsesFieldWithVarStringValueSetsTypeString", testParsesFieldWithVarStringValueSetsTypeString),
        ("testParsesFieldWithTinyValueSetsTypeInt", testParsesFieldWithTinyValueSetsTypeInt),
        ("testParsesFieldWithShortValueSetsTypeInt", testParsesFieldWithShortValueSetsTypeInt),
        ("testParsesFieldWithLongValueSetsTypeInt", testParsesFieldWithLongValueSetsTypeInt),
        ("testParsesFieldWithInt24ValueSetsTypeInt", testParsesFieldWithInt24ValueSetsTypeInt),
        ("testParsesFieldWithLongLongValueSetsTypeInt", testParsesFieldWithLongLongValueSetsTypeInt),
        ("testParsesFieldWithDecimalValueSetsTypeDouble", testParsesFieldWithDecimalValueSetsTypeDouble),
        ("testParsesFieldWithNewDecimalValueSetsTypeDouble", testParsesFieldWithNewDecimalValueSetsTypeDouble),
        ("testParsesFieldWithFloatValueSetsTypeFloat", testParsesFieldWithFloatValueSetsTypeFloat),
        ("testParsesFieldWithDoubleValueSetsTypeDouble", testParsesFieldWithDoubleValueSetsTypeDouble),
        ("testParsesFieldWithTimestampValueSetsTypeString", testParsesFieldWithTimestampValueSetsTypeString),
        ("testParsesFieldWithBlobValueSetsTypeString", testParsesFieldWithBlobValueSetsTypeString)
      ]
    }
}
