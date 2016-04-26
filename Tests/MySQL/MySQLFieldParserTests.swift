import Foundation
import XCTest
import CMySQLClient

@testable import MySQL

public class MySQLFieldParserTests: XCTestCase {

  var parser: MySQLFieldParser?

  public override func setUp() {
    parser = MySQLFieldParser()
  }

  public func testParsesName() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()

    let parsed = parser!.parse(field)
    XCTAssertEqual("myname", parsed.name, "Name should be equal to myname")
  }

  public func testParsesTypeMYSQL_TYPE_TINYReturnsTiny() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_TINY

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Tiny, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_SHORTReturnsShort() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_SHORT

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Short, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_LONGReturnsLong() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_LONG

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Long, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_INT24ReturnsInt24() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_INT24

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Int24, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_LONGLONGReturnsLongLong() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_LONGLONG

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.LongLong, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_DECIMALReturnsDecimal() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_DECIMAL

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Decimal, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_NEWDECIMALReturnsNewDecimal() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_NEWDECIMAL

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.NewDecimal, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_FLOATReturnsFloat() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_FLOAT

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Float, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_DOUBLEReturnsDouble() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_DOUBLE

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Double, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_BITReturnsBit() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_BIT

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Bit, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_TIMESTAMPReturnsTimestamp() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_TIMESTAMP

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Timestamp, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_DATEReturnsDate() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_DATE

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Date, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_TIMEReturnsTime() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_TIME

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Time, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_DATETIMEReturnsDateTime() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_DATETIME

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.DateTime, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_YEARReturnsYear() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_YEAR

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Year, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_STRINGReturnsString() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_STRING

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.String, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_VAR_STRINGReturnsVarString() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_VAR_STRING

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.VarString, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_BLOBReturnsBlob() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_BLOB

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Blob, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_SETReturnsSet() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_SET

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Set, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_ENUMReturnsEnum() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_ENUM

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Enum, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_GEOMETRYReturnsGeometry() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_GEOMETRY

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Geometry, parsed.type)
  }

  public func testParsesTypeMYSQL_TYPE_NULLReturnsNull() {
    var field = MYSQL_FIELD()
    field.name = "myname".getUnsafeMutablePointer()
    field.type = MYSQL_TYPE_NULL

    let parsed = parser!.parse(field)
    XCTAssertEqual(MySQLFieldType.Null, parsed.type)
  }
}

extension MySQLFieldParserTests {
    static var allTests: [(String, MySQLFieldParserTests -> () throws -> Void)] {
      return [
        ("testParsesName", testParsesName),
        ("testParsesTypeMYSQL_TYPE_TINYReturnsTiny", testParsesTypeMYSQL_TYPE_TINYReturnsTiny),
        ("testParsesTypeMYSQL_TYPE_SHORTReturnsShort", testParsesTypeMYSQL_TYPE_SHORTReturnsShort),
        ("testParsesTypeMYSQL_TYPE_LONGReturnsLong", testParsesTypeMYSQL_TYPE_LONGReturnsLong),
        ("testParsesTypeMYSQL_TYPE_INT24ReturnsInt24", testParsesTypeMYSQL_TYPE_INT24ReturnsInt24),
        ("testParsesTypeMYSQL_TYPE_LONGLONGReturnsLongLong", testParsesTypeMYSQL_TYPE_LONGLONGReturnsLongLong),
        ("testParsesTypeMYSQL_TYPE_DECIMALReturnsDecimal", testParsesTypeMYSQL_TYPE_DECIMALReturnsDecimal),
        ("testParsesTypeMYSQL_TYPE_NEWDECIMALReturnsNewDecimal", testParsesTypeMYSQL_TYPE_NEWDECIMALReturnsNewDecimal),
        ("testParsesTypeMYSQL_TYPE_FLOATReturnsFloat", testParsesTypeMYSQL_TYPE_FLOATReturnsFloat),
        ("testParsesTypeMYSQL_TYPE_DOUBLEReturnsDouble", testParsesTypeMYSQL_TYPE_DOUBLEReturnsDouble),
        ("testParsesTypeMYSQL_TYPE_BITReturnsBit", testParsesTypeMYSQL_TYPE_BITReturnsBit),
        ("testParsesTypeMYSQL_TYPE_TIMESTAMPReturnsTimestamp", testParsesTypeMYSQL_TYPE_TIMESTAMPReturnsTimestamp),
        ("testParsesTypeMYSQL_TYPE_DATEReturnsDate", testParsesTypeMYSQL_TYPE_DATEReturnsDate),
        ("testParsesTypeMYSQL_TYPE_TIMEReturnsTime", testParsesTypeMYSQL_TYPE_TIMEReturnsTime),
        ("testParsesTypeMYSQL_TYPE_DATETIMEReturnsDateTime", testParsesTypeMYSQL_TYPE_DATETIMEReturnsDateTime),
        ("testParsesTypeMYSQL_TYPE_YEARReturnsYear", testParsesTypeMYSQL_TYPE_YEARReturnsYear),
        ("testParsesTypeMYSQL_TYPE_STRINGReturnsString", testParsesTypeMYSQL_TYPE_STRINGReturnsString),
        ("testParsesTypeMYSQL_TYPE_VAR_STRINGReturnsVarString", testParsesTypeMYSQL_TYPE_VAR_STRINGReturnsVarString),
        ("testParsesTypeMYSQL_TYPE_BLOBReturnsBlob", testParsesTypeMYSQL_TYPE_BLOBReturnsBlob),
        ("testParsesTypeMYSQL_TYPE_SETReturnsSet", testParsesTypeMYSQL_TYPE_SETReturnsSet),
        ("testParsesTypeMYSQL_TYPE_ENUMReturnsEnum", testParsesTypeMYSQL_TYPE_ENUMReturnsEnum),
        ("testParsesTypeMYSQL_TYPE_GEOMETRYReturnsGeometry", testParsesTypeMYSQL_TYPE_GEOMETRYReturnsGeometry),
        ("testParsesTypeMYSQL_TYPE_NULLReturnsNull", testParsesTypeMYSQL_TYPE_NULLReturnsNull)
      ]
    }
}
