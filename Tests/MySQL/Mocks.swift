import Foundation
@testable import MySQL

public class MockMySQLConnection : MySQLConnectionProtocol {
  public var connectCalled:Bool = false
  public var executeCalled:Bool = false
  public var closeCalled:Bool = false

  public var clientInfo:String? = nil
  public var clientVersion:UInt = 0

  public init() { }

  public func connect(
    host: String,
    user: String,
    password: String,
    database: String
  ) throws {
    connectCalled = true
  }

  public func client_info() -> String? { return clientInfo }

  public func client_version() -> UInt { return clientVersion }

  public func execute(query: String) { executeCalled = true }

  public func close() { closeCalled = true }
}

public class MockMySQLConnectionPool : MySQLConnectionPoolProtocol {
  public static var getConnectionCalled = false
  public static var setConnectionProviderCalled = false
  static var connectionProvider:() -> MySQLConnectionProtocol? = { () -> MySQLConnectionProtocol? in
    return nil
  }

  public static func setConnectionProvider(provider: () -> MySQLConnectionProtocol?) {
    self.connectionProvider = provider
    self.setConnectionProviderCalled = true
  }

  public static func getConnection(host: String, user: String, password: String, database: String) throws -> MySQLConnectionProtocol? {
    self.getConnectionCalled = true
    return nil
  }
}
