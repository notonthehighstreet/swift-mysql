import XCTest

@testable import MySQLTests

XCTMain([
  testCase(MySQLClientTests.allTests),
  testCase(MySQLConnectionPoolTests.allTests),
  testCase(MySQLConnectionTests.allTests),
  testCase(MySQLTransactionTests.allTests),
  testCase(MySQLFieldParserTests.allTests),
  testCase(MySQLRowParserTests.allTests),
  testCase(MySQLResultTests.allTests),
  testCase(MySQLQueryBuilderTests.allTests)
])
