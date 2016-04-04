// singleton instance which maintains a number of mysql connections
// need to check how scope works in kitura
public class MySQLConnectionPool: MySQLConnectionPoolProtocol {
  static var connectionProvider:() -> MySQLConnectionProtocol? = { () -> MySQLConnectionProtocol? in
    return nil
  }

  public static func setConnectionProvider(provider: () -> MySQLConnectionProtocol?) {
    self.connectionProvider = provider
  }

  public static func getConnection(host: String, user: String, password: String, database: String) throws -> MySQLConnectionProtocol? {
    let connection = connectionProvider()
    try connection!.connect(host, user:user, password:password, database: database)

    return connection
  }
}
