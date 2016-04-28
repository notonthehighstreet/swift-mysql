import Foundation

// MockMySQLConnection is a mock object which can be used in unit tests to replace the real instance in order to test behaviour
public class MockMySQLConnection : MySQLConnectionProtocol {
  public var isConnectedReturn = true
  public var isConnectedCalled = false

  public var connectCalled = false
  public var executeCalled = false
  public var closeCalled = false

  public var executeStatement = ""

  public var clientInfo:String? = nil
  public var clientVersion:UInt = 0

  public var executeReturnResult:CMySQLResult? = nil
  public var executeReturnHeaders:[CMySQLField]? = nil
  public var executeReturnError:MySQLError? = nil

  public var nextResultReturn:CMySQLRow? = nil

  public var nextResultReturnResult:CMySQLResult? = nil
  public var nextResultReturnHeaders:[CMySQLField]? = nil
  public var nextResultReturnError:MySQLError? = nil

  private var uuid: Double

  public func equals(otherObject: MySQLConnectionProtocol) -> Bool {
    return uuid == (otherObject as! MockMySQLConnection).uuid
  }

  public init() {
    uuid = NSDate().timeIntervalSince1970
  }

  public func isConnected() -> Bool {
    isConnectedCalled = true
    return isConnectedReturn
  }

  public func connect(
    host: String,
    user: String,
    password: String
  ) throws {
    connectCalled = true
  }

  public func connect(
    host: String,
    user: String,
    password: String,
    port: Int
  ) throws {
    connectCalled = true
  }

  public func connect(
    host: String,
    user: String,
    password: String,
    port: Int,
    database: String
  ) throws {
    connectCalled = true
  }

  public func client_info() -> String? { return clientInfo }

  public func client_version() -> UInt { return clientVersion }

  public func execute(query: String) -> (CMySQLResult?, [CMySQLField]?, MySQLError?) {
     executeCalled = true
     executeStatement = query
     return (executeReturnResult, executeReturnHeaders, executeReturnError)
   }

   public func nextResult(result: CMySQLResult) -> CMySQLRow? {
     return nextResultReturn
   }

   public func nextResultSet() -> (CMySQLResult?, [CMySQLField]?, MySQLError?) {
     return (nextResultReturnResult, nextResultReturnHeaders, nextResultReturnError)
   }

  public func close() { closeCalled = true }
}
