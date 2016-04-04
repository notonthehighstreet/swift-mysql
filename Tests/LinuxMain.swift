import XCTest

@testable import MySQLTestSuite

XCTMain([
  testCase(MySQLClientTests.allTests),
  testCase(MySQLConnectionPoolTests.allTests),
  testCase(MySQLFieldParserTests.allTests),
  testCase(MySQLRowParserTests.allTests),
  testCase(MySQLResultTests.allTests)
])
