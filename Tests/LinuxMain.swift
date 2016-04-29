import XCTest

@testable import MySQLTestSuite

XCTMain([
  MySQLClientTests(),
  MySQLConnectionPoolTests(),
  MySQLFieldParserTests(),
  MySQLRowParserTests(),
  MySQLResultTests(),
  MySQLQueryBuilderTests()
])
