import Foundation
import XCTest
import CMySQLClient

@testable import MySQL

public class MySQLRowParserTests: XCTestCase {

  let parser = MySQLRowParser()
  let cRow = CMySQLRow(allocatingCapacity: 1)
  var headers = [MySQLField]()

  public override func setUp() {
    var header1 = MySQLField(name: "tester", type: MySQLFieldType.String)
    header1.name = "header1"

    headers.append(header1)
  }

  public func testParsesRowWithStringValue() {
    cRow[0] = "myvalue".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.String

    let row = parser.parse(cRow, headers: headers)

    XCTAssertEqual("myvalue", (row["header1"] as! String))
  }

  public func testParsesFieldWithNilValueSetsNil() {
    cRow[0] = nil
    headers[0].type = MySQLFieldType.String

    let row = parser.parse(cRow, headers: headers)

    XCTAssertNil(row["header1"])
  }

  public func testParsesFieldWithStringValueSetsTypeString() {
    cRow[0] = "myvalue".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.String

    let row = parser.parse(cRow, headers: headers)

    XCTAssertTrue(row["header1"] is String, "Type should be String")
  }

  public func testParsesFieldWithIntValueSetsTypeInt() {
    cRow[0] = "1".getUnsafeMutablePointer()
    headers[0].type = MySQLFieldType.Int24

    let row = parser.parse(cRow, headers: headers)

    XCTAssertEqual(1, row["header1"] as? Int)
    XCTAssertTrue(row["header1"] is Int, "Type should be Int")
  }
}

extension MySQLRowParserTests {
    static var allTests: [(String, MySQLRowParserTests -> () throws -> Void)] {
      return [
        ("testParsesRowWithStringValue", testParsesRowWithStringValue),
        ("testParsesFieldWithStringValueSetsTypeString", testParsesFieldWithStringValueSetsTypeString),
        ("testParsesFieldWithIntValueSetsTypeInt", testParsesFieldWithIntValueSetsTypeInt)
      ]
    }
}
