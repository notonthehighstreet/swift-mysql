import Foundation

// MockMySQLConnectionPool is a mock object which can be used in unit tests to replace the real instance in order to test behaviour
public class MockMySQLConnectionPool: MySQLConnectionPoolProtocol {
  public var setPoolSizeCalled = false
  public var setConnectionProviderCalled = false
  public var releaseConnectionCalled = false

  public var getConnectionCalled = false
  public var getConnectionReturn: MySQLConnectionProtocol?

  var connectionString: MySQLConnectionString
  var poolSize: Int
  var defaultCharset: String
  var provider: (() -> MySQLConnectionProtocol?)?

  public required init(connectionString: MySQLConnectionString,
                       poolSize: Int,
                       defaultCharset: String) {

    self.connectionString = connectionString
    self.poolSize = poolSize
    self.defaultCharset = defaultCharset
}

  public var connectionProvider:() -> MySQLConnectionProtocol? = { () -> MySQLConnectionProtocol? in
    return nil
  }

  public var logger:(_: MySQLConnectionPoolMessage) -> Void = {
    (message: MySQLConnectionPoolMessage) -> Void in
  }

  public func setLogger(logger: @escaping (_: MySQLConnectionPoolMessage) -> Void) {
    self.logger = logger
  }

  public func setConnectionProvider(provider: @escaping () -> MySQLConnectionProtocol?) {
    self.connectionProvider = provider
    self.setConnectionProviderCalled = true
  }

  public func getConnection() throws -> MySQLConnectionProtocol? {
    self.getConnectionCalled = true
    return getConnectionReturn
  }

  public func getConnection(closure: ((_: MySQLConnectionProtocol) throws -> Void)) throws {
    self.getConnectionCalled = true
    try closure(getConnectionReturn!)
  }

  public func releaseConnection(_ connection: MySQLConnectionProtocol) {
    self.releaseConnectionCalled = true
  }

  /**
    resetMock allows you to reset the state of this instance since it is a static class
  */
  public func resetMock() {
    setPoolSizeCalled = false
    setConnectionProviderCalled = false
    releaseConnectionCalled = false
    getConnectionCalled = false
    getConnectionReturn = nil
    connectionProvider = { () -> MySQLConnectionProtocol? in return nil }
  }
}
