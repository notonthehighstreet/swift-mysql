import Foundation
import XCTest
import CMySQLClient

@testable import MySQL

public class MySQLRowParserTests: XCTestCase {
  public func testParsesRowWithStringValue() {
    let parser = MySQLRowParser()

    var header1 = MySQLHeader()
    header1.name = "header1"

    var headers = [MySQLHeader]()
    headers.append(header1)
    let cRow = CMySQLRow(allocatingCapacity: 1)
    cRow[0] = UnsafeMutablePointer<Int8>(("myvalue" as NSString).UTF8String)

    let row = parser.parse(cRow, headers: headers)

    XCTAssertEqual("myvalue", (row["header1"] as! String))
  }
}

extension MySQLRowParserTests {
    static var allTests: [(String, MySQLRowParserTests -> () throws -> Void)] {
      return [
        ("testParsesRowWithStringValue", testParsesRowWithStringValue)
      ]
    }
}
