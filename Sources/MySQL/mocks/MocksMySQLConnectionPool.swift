import Foundation

// MockMySQLConnectionPool is a mock object which can be used in unit tests to replace the real instance in order to test behaviour
public class MockMySQLConnectionPool : MySQLConnectionPoolProtocol {
  public static var setPoolSizeCalled = false
  public static var setConnectionProviderCalled = false
  public static var releaseConnectionCalled = false

  public static var getConnectionCalled = false
  public static var getConnectionReturn: MySQLConnectionProtocol?

  public static var connectionProvider:() -> MySQLConnectionProtocol? = { () -> MySQLConnectionProtocol? in
    return nil
  }

  public static func setPoolSize(size: Int) {
    self.setPoolSizeCalled = true
  }

  public static func setConnectionProvider(provider: () -> MySQLConnectionProtocol?) {
    self.connectionProvider = provider
    self.setConnectionProviderCalled = true
  }

  public static func getConnection(host: String, user: String, password: String) throws -> MySQLConnectionProtocol? {
    self.getConnectionCalled = true
    return getConnectionReturn
  }

  public static func getConnection(host: String, user: String, password: String, port: Int, database: String) throws -> MySQLConnectionProtocol? {
    self.getConnectionCalled = true
    return getConnectionReturn
  }

  public static func getConnection(host: String,
                            user: String,
                            password: String,
                            port: Int,
                            database: String,
                            closure: ((connection: MySQLConnectionProtocol) -> Void)) throws {
    self.getConnectionCalled = true
    closure(connection: getConnectionReturn!)
  }

  public static func releaseConnection(connection: MySQLConnectionProtocol) {
    self.releaseConnectionCalled = true
  }

  /**
    resetMock allows you to reset the state of this instance since it is a static class
  */
  public static func resetMock() {
    setPoolSizeCalled = false
    setConnectionProviderCalled = false
    releaseConnectionCalled = false
    getConnectionCalled = false
    getConnectionReturn = nil
    connectionProvider = { () -> MySQLConnectionProtocol? in return nil }
  }
}
