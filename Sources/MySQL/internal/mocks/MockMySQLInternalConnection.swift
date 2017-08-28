import Foundation

// MockMySQLInternalConnection is a mock object which can be used in 
// unit tests to replace the real instance in order to test behaviour
class MockMySQLInternalConnection : MySQLInternalConnectionProtocol {
  var isConnectedReturn = true
  var isConnectedCalled = false
  var connectError: MySQLError?

  var connectCalled = false
  var executeCalled = false
  var closeCalled = false

  var executeStatement = ""

  var clientInfo: String? = nil
  var clientVersion: UInt = 0
  var defaultCharset: String = "utf8"

  var executeReturnRows: Int64 = 0
  var executeReturnResult: CMySQLResult? = nil
  var executeReturnHeaders: [CMySQLField]? = nil
  var executeReturnError: MySQLError? = nil

  var nextResultReturn: CMySQLRow? = nil

  var nextResultReturnRows: Int64 = 0
  var nextResultReturnResult: CMySQLResult? = nil
  var nextResultReturnHeaders: [CMySQLField]? = nil
  var nextResultReturnError: MySQLError? = nil

  var nextResultSetCalled = false
  var nextResultSetReturn: MySQLResultProtocol?
  var nextResultSetErrorReturn: MySQLError?

  var startTransactionCalled = false

  var commitTransactionCalled = false
  var commitTransactionError: MySQLError?

  var rollbackTransactionCalled = false
  var rollbackTransactionError: MySQLError?

  var uuid: Double

  func equals(otherObject: MySQLInternalConnectionProtocol) -> Bool {
    return uuid == (otherObject as! MockMySQLInternalConnection).uuid
  }

  func charset() -> String? {
    return defaultCharset
  }

  func setCharset(charset: String) -> Bool {
    defaultCharset = charset
    return true
  }

  init() {
    uuid = NSDate().timeIntervalSince1970
  }

  func isConnected() -> Bool {
    isConnectedCalled = true
    return isConnectedReturn
  }

  func connect(host: String, user: String, password: String) throws {
    if connectError != nil {
      throw connectError!
    }

    connectCalled = true
  }

  func connect(host: String, user: String, password: String, port: Int) throws {
    if connectError != nil {
      throw connectError!
    }

    connectCalled = true
  }

  func connect(host: String,
               user: String,
               password: String,
               port: Int,
               database: String) throws {
    if connectError != nil {
      throw connectError!
    }

    connectCalled = true
  }

  public func connect(host: String,
                      user: String,
                      password: String, 
                      port: Int,
                      database: String,
                      charset: String) throws {
    if connectError != nil {
      throw connectError!
    }

    connectCalled = true
  }

  func client_info() -> String? { return clientInfo }

  func client_version() -> UInt { return clientVersion }

  func execute(query: String) throws -> (Int64, CMySQLResult?, [CMySQLField]?) {
     executeCalled = true
     executeStatement = query

     if executeReturnError != nil {
        throw executeReturnError!
     }

     return (executeReturnRows, executeReturnResult, executeReturnHeaders)
   }

   func nextResult(result: CMySQLResult) -> CMySQLRow? {
     return nextResultReturn
   }

   func nextResultSet() throws -> (Int64, CMySQLResult?, [CMySQLField]?) {
        if nextResultSetErrorReturn != nil {
            throw nextResultSetErrorReturn!
        }

     return (executeReturnRows, nextResultReturnResult, nextResultReturnHeaders)
   }

  func close() { closeCalled = true }

  func startTransaction() {
    startTransactionCalled = true
  }
  
  func commitTransaction() throws {
    commitTransactionCalled = true
    if commitTransactionError != nil { throw commitTransactionError! }
  }
  
  func rollbackTransaction() throws {
    rollbackTransactionCalled = true
    if rollbackTransactionError != nil { throw rollbackTransactionError! }
  }
}
