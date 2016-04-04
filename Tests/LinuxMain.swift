import XCTest

@testable import MySQLTestSuite

XCTMain([
  testCase(MySQLClientTests.allTests),
  testCase(MySQLConnectionPoolTests.allTests),
  testCase(MySQLHeaderParserTests.allTests),
  testCase(MySQLRowParserTests.allTests),
  testCase(MySQLResultTests.allTests)
])
