import XCTest

@testable import MySQLTests

XCTMain([
  testCase(MySQLConnectionPoolTests.allTests),
  testCase(MySQLConnectionTests.allTests),
  testCase(MySQLFieldParserTests.allTests),
  testCase(MySQLQueryBuilderTests.allTests),
//  testCase(MySQLResultTests.allTests),
  testCase(MySQLRowParserTests.allTests)
])
