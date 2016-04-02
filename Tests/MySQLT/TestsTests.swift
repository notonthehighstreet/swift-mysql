import Foundation
import XCTest

@testable import MySQL

public class TestsTests: XCTestCase {
  public func testSomething() {
    let mysql = MySQL()
    let data = mysql.client_info()
    print(data)
  }
}

extension TestsTests {
    static var allTests: [(String, TestsTests -> () throws -> Void)] {
      return [
        ("testSomething", testSomething)
      ]
    }
}
