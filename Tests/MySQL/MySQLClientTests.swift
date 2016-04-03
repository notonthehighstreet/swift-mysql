import Foundation
import XCTest

@testable import MySQL

public class MockMySQLConnection : MySQLConnectionProtocol {

  public var connectCalled:Bool = false
  public var executeCalled:Bool = false
  public var closeCalled:Bool = false

  public var clientInfo:String? = nil
  public var clientVersion:UInt = 0

  public required init(host: String, user: String, password: String, database: String) {

  }

  public func connect() throws {
    connectCalled = true
  }

  public func client_info() -> String? {
    return clientInfo
  }

  public func client_version() -> UInt {
    return clientVersion
  }

  public func execute(query: String) {
    executeCalled = true
  }

  public func close() {
    closeCalled = true
  }
}

public class MySQLClientTests: XCTestCase {

  public func createClient(connection: MySQLConnectionProtocol) -> MySQLClient? {
    do {
      return try MySQLClient(connection: connection)
    } catch {
      XCTFail("Unable to create client")
    }
    return nil
  }

  public func testSetsInitParameters() {
    let connection = MockMySQLConnection(host: "", user: "", password: "", database: "")
    let mysql = createClient(connection)!
    XCTAssertNotNil(mysql.connection, "Should have set connection")
  }

  public func testCallsConnectOnInit() {
    let connection = MockMySQLConnection(host: "", user: "", password: "", database: "")
    let _ = createClient(connection)!
    XCTAssertTrue(connection.connectCalled, "Connect should have been called")
  }

  public func testClientInfoReturnsClientInfo() {
    let connection = MockMySQLConnection(host: "", user: "", password: "", database: "")
    connection.clientInfo = "testinfo"

    let mysql = createClient(connection)!
    let info = mysql.info()
    XCTAssertEqual(connection.clientInfo, info, "Correct client info should have been returned")
  }

  public func testClientVersionReturnsClientVersion() {
    let connection = MockMySQLConnection(host: "", user: "", password: "", database: "")
    connection.clientVersion = 100

    let mysql = createClient(connection)!
    let version = mysql.version()
    XCTAssertEqual(connection.clientVersion, version, "Correct client version should have been returned")
  }

  //TODO: implement these tests correctly this is just a placeholder
  public func testClientExecutesQuery() {
    let connection = MockMySQLConnection(host: "", user: "", password: "", database: "")
    let mysql = createClient(connection)!

    mysql.execute("soemthing")
    XCTAssertTrue(connection.executeCalled, "Query should have been executed")
  }

  public func testClientCallsClose() {
    let connection = MockMySQLConnection(host: "", user: "", password: "", database: "")
    let mysql = createClient(connection)!

    mysql.close()
    XCTAssertTrue(connection.closeCalled, "Close should have been called")
  }
}

extension MySQLClientTests {
    static var allTests: [(String, MySQLClientTests -> () throws -> Void)] {
      return [
        ("testSetsInitParameters", testSetsInitParameters),
        ("testCallsConnectOnInit", testCallsConnectOnInit),
        ("testClientInfoReturnsClientInfo", testClientInfoReturnsClientInfo),
        ("testClientVersionReturnsClientVersion", testClientVersionReturnsClientVersion),
        ("testClientExecutesQuery", testClientExecutesQuery),
        ("testClientCallsClose", testClientCallsClose)
      ]
    }
}
