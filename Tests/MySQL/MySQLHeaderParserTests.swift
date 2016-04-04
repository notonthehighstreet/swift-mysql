import Foundation
import XCTest
import CMySQLClient

@testable import MySQL

public class MySQLHeaderParserTests: XCTestCase {
  public func testParseSetsFieldName() {
    let name = "myname"
    let parser = MySQLHeaderParser()

    var field = MYSQL_FIELD()
    field.name = UnsafeMutablePointer<Int8>(("myname" as NSString).UTF8String)

    let header = parser.parse(field)

    XCTAssertEqual(name, header.name, "Name should be equal")
  }
}

extension MySQLHeaderParserTests {
    static var allTests: [(String, MySQLHeaderParserTests -> () throws -> Void)] {
      return [
        ("testParseSetsFieldName", testParseSetsFieldName)
      ]
    }
}
