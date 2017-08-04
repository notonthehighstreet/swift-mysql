import Foundation

// MockMySQLClient is a mock object which can be used in unit tests to replace 
// the real instance in order to test behaviour
public class MockMySQLConnection: MySQLConnectionProtocol {
  public var executeQueryCalled = false
  public var executeQueryParams: String?

  public var executeBuilderCalled = false
  public var executeBuilderParams: MySQLQueryBuilder?
  public var executeMySQLResultReturn: MySQLResultProtocol?
  public var executeMySQLErrorReturn: MySQLError?

  public var nextResultSetCalled = false
  public var nextResultSetReturn: MySQLResultProtocol?
  public var nextResultSetErrorReturn: MySQLError?

  public func info() -> String? { return "1.2"}
  public func version() -> UInt { return 1 }
  public func isConnected() -> Bool { return true }

  public func execute(query: String) throws -> (MySQLResultProtocol?) {
    executeQueryParams = query
    executeQueryCalled = true

    return executeMySQLResultReturn
  }

  public func execute(builder: MySQLQueryBuilder) throws -> (MySQLResultProtocol?) {
    executeBuilderParams = builder
    executeBuilderCalled = true

    return executeMySQLResultReturn
  }

  public func nextResultSet() throws -> (MySQLResultProtocol?) {
    nextResultSetCalled = true

    return nextResultSetReturn
  }

  public func equals(otherObject: MySQLConnectionProtocol) -> Bool {
    return true
  }
}
