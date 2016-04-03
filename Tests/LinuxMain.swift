import XCTest

@testable import MySQLTestSuite

XCTMain([
  testCase(MySQLClientTests.allTests)
])
