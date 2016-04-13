import Foundation
@testable import MySQL

public class MockMySQLConnection : MySQLConnectionProtocol {
  public var connectCalled:Bool = false
  public var executeCalled:Bool = false
  public var closeCalled:Bool = false

  public var clientInfo:String? = nil
  public var clientVersion:UInt = 0

  public var executeReturnResult:CMySQLResult? = nil
  public var executeReturnHeaders:[CMySQLField]? = nil
  public var executeReturnError:MySQLError? = nil

  public var nextResultReturn:CMySQLRow? = nil

  private var uuid: Double

  public func equals(otherObject: MySQLConnectionProtocol) -> Bool {
    return uuid == (otherObject as! MockMySQLConnection).uuid
  }

  public init() {
    uuid = NSDate().timeIntervalSince1970
  }

  public func connect(
    host: String,
    user: String,
    password: String,
    database: String
  ) throws {
    connectCalled = true
  }

  public func connect(
    host: String,
    user: String,
    password: String
  ) throws {
    connectCalled = true
  }

  public func client_info() -> String? { return clientInfo }

  public func client_version() -> UInt { return clientVersion }

  public func execute(query: String) -> (CMySQLResult?, [CMySQLField]?, MySQLError?) {
     executeCalled = true
     return (executeReturnResult, executeReturnHeaders, executeReturnError)
   }

   public func nextResult(result: CMySQLResult) -> CMySQLRow? {
     return nextResultReturn
   }

  public func close() { closeCalled = true }
}


public class MockMySQLConnectionPool : MySQLConnectionPoolProtocol {
  public static var getConnectionCalled = false
  public static var setConnectionProviderCalled = false
  static var connectionProvider:() -> MySQLConnectionProtocol? = { () -> MySQLConnectionProtocol? in
    return nil
  }

  public static func setPoolSize(size: Int) {
    
  }

  public static func setConnectionProvider(provider: () -> MySQLConnectionProtocol?) {
    self.connectionProvider = provider
    self.setConnectionProviderCalled = true
  }

  public static func getConnection(host: String, user: String, password: String) throws -> MySQLConnectionProtocol? {
    self.getConnectionCalled = true
    return nil
  }

  public static func getConnection(host: String, user: String, password: String, database: String) throws -> MySQLConnectionProtocol? {
    self.getConnectionCalled = true
    return nil
  }

  public static func releaseConnection(connection: MySQLConnectionProtocol) {

  }
}
