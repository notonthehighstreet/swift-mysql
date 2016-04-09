// Singleton instance which maintains a number of mysql connections
//TODO: Check how scope works in kitura
//TODO: Complete implementation of pool
public class MySQLConnectionPool: MySQLConnectionPoolProtocol {

  static var connectionProvider:() -> MySQLConnectionProtocol? = { () -> MySQLConnectionProtocol? in
    return nil
  }

  /**
    setConnectionProvider sets a reference to a closure which returns an object implementing MySQLConnectionProtocol.  Everytime the connection pool requires a new connection this closure will be executed.

    - Parameters:
      - provider: Closure which returns an object implementing MySQLConnectionProtocol.
  */
  public static func setConnectionProvider(provider: () -> MySQLConnectionProtocol?) {
    self.connectionProvider = provider
  }

  /**
    getConnection returns a connection from the pool, if a connection is unsuccessful then getConnection throws a MySQLError.

    - Parameters:
      - host: The host name or ip address of the database.
      - user: The username to use for the connection.
      - password: The password to use for the connection.

    - Returns: An object conforming to the MySQLConnectionProtocol.
  */
  public static func getConnection(host: String, user: String, password: String) throws -> MySQLConnectionProtocol? {
    return try getConnection(host, user: user, password: password, database: "")
  }

  /**
    getConnection returns a connection from the pool, if a connection is unsuccessful then getConnection throws a MySQLError.

    - Parameters:
      - host: The host name or ip address of the database.
      - user: The username to use for the connection.
      - password: The password to use for the connection.
      - database: The database to connect to.

    - Returns: An object conforming to the MySQLConnectionProtocol.
  */
  public static func getConnection(host: String, user: String, password: String, database: String) throws -> MySQLConnectionProtocol? {
    let connection = connectionProvider()
    try connection!.connect(host, user:user, password:password, database: database)

    return connection
  }
}
