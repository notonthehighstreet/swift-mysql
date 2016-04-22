import Foundation

// MockMySQLClient is a mock object which can be used in unit tests to replace the real instance in order to test behaviour
public class MockMySQLClient: MySQLClientProtocol {
  public var executeQueryCalled = false
  public var executeQueryParams: String?

  public var executeBuilderCalled = false
  public var executeBuilderParams: MySQLQueryBuilder?
  public var executeMySQLResultReturn: MySQLResultProtocol?
  public var executeMySQLErrorReturn: MySQLError?

  public var nextResultSetCalled = false
  public var nextResultSetReturn: MySQLResultProtocol?
  public var nextResultSetErrorReturn: MySQLError?

  public required init(connection: MySQLConnectionProtocol) { }
  public func info() -> String? { return "1.2"}
  public func version() -> UInt { return 1 }

  public func execute(query: String) -> (MySQLResultProtocol?, MySQLError?) {
    executeQueryParams = query
    executeQueryCalled = true

    return (executeMySQLResultReturn, executeMySQLErrorReturn)
  }

  public func execute(builder: MySQLQueryBuilder) -> (MySQLResultProtocol?, MySQLError?) {
    executeBuilderParams = builder
    executeBuilderCalled = true

    return (executeMySQLResultReturn, executeMySQLErrorReturn)
  }

  public func nextResultSet() -> (MySQLResultProtocol?, MySQLError?) {
    nextResultSetCalled = true

    return (nextResultSetReturn, nextResultSetErrorReturn)
  }
}
