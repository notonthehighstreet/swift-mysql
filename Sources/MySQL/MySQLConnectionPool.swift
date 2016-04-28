import Foundation

// Singleton instance which maintains a number of mysql connections
//TODO: Check how scope works in kitura
//TODO: Complete implementation of pool
public class MySQLConnectionPool: MySQLConnectionPoolProtocol {

  static var activeConnections = [String: [MySQLConnectionProtocol]]()
  static var inactiveConnections = [String: [MySQLConnectionProtocol]]()
  static var poolSize:Int = 20
  static var poolTimeout:Double = 20.0 // 20s

  static var lock = NSLock()

  static var connectionProvider:() -> MySQLConnectionProtocol? = { () -> MySQLConnectionProtocol? in
    return nil
  }

  /**
    setPoolSize sets the size for the connection pool, default is 20

    - Parameters:
      - size: new size of the pool
  */
  public static func setPoolSize(size: Int) {
    poolSize = size
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
  getConnection returns a connection from the pool, if a connection is unsuccessful then getConnection throws a MySQLError,
  if the pool has no available connections getConnection will block util either a connection is free or a timeout occurs.

    - Parameters:
      - host: The host name or ip address of the database.
      - user: The username to use for the connection.
      - password: The password to use for the connection.

    - Returns: An object conforming to the MySQLConnectionProtocol.
  */
  public static func getConnection(host: String, user: String, password: String) throws -> MySQLConnectionProtocol? {
    return try getConnection(host, user: user, password: password, port: 3306, database: "")
  }

  /**
    getConnection returns a connection from the pool, if a connection is unsuccessful then getConnection throws a MySQLError,
    if the pool has no available connections getConnection will block util either a connection is free or a timeout occurs.

    By passing the optional closure once the code has executed within the block the connection is automatically released
    back to the pool saving the requirement to manually call releaseConnection.

    - Parameters:
      - host: The host name or ip address of the database
      - user: The username to use for the connection
      - password: The password to use for the connection
      - port: The the port to connect to
      - database: The database to connect to
      - closure: Code that will be executed before connection is released back to the pool

    - Returns: An object implementing the MySQLConnectionProtocol.

    ```
      MySQLConnectionPoolProtocol.getConnection(host: "127.0.0.1",
                                                user: "root",
                                                password: "mypassword",
                                                port: 3306,
                                                database: "mydatabase") {
        (connection: MySQLConnectionProtocol) in
          let result = connection.execute("SELECT * FROM TABLE")
          ...
      }
    ```
  */
  public static func getConnection(host: String,
                                   user: String,
                                   password: String,
                                   port: Int,
                                   database: String,
                                   closure: ((connection: MySQLConnectionProtocol) -> Void)) throws {
    do {
      let connection = try getConnection(host, user: user, password: password, port: port, database: database)
      defer {
        self.releaseConnection(connection!)
      }

      closure(connection: connection!)
    } catch {
      throw error
    }
  }

  /**
    getConnection returns a connection from the pool, if a connection is unsuccessful then getConnection throws a MySQLError,
    if the pool has no available connections getConnection will block util either a connection is free or a timeout occurs.

    - Parameters:
      - host: The host name or ip address of the database
      - user: The username to use for the connection
      - password: The password to use for the connection
      - port: The the port to connect to
      - database: The database to connect to

    - Returns: An object conforming to the MySQLConnectionProtocol.
  */
  public static func getConnection(host: String, user: String, password: String, port: Int, database: String) throws -> MySQLConnectionProtocol? {
    // check pool has space
    var startTime = NSDate()
    while(countActive()  >= poolSize) {
      if (NSDate().timeIntervalSince1970 - startTime.timeIntervalSince1970) > poolTimeout {
        throw MySQLError.ConnectionPoolTimeout
      }
    }

    lock.lock()
    defer {
      lock.unlock()
    }

    // check if there is something available in the pool if so return it
    let key = computeKey(host, user: user, password: password, database: database)
    if let connection = getInactive(key) {
      addActive(key, connection: connection)
      return connection
    } else {
      return try createAndAddActive(host, user: user, password: password, port: port, database: database)
    }
  }

  /**
    releaseConnection returns a connection to the pool.

    - Parameters:
      - connection: Connection to be returned to the pool
  */
  public static func releaseConnection(connection: MySQLConnectionProtocol) {
    lock.lock()
    defer {
      lock.unlock()
    }

    let (connectionKey, index) = findActiveConnection(connection)

    if(connectionKey != nil) {
      activeConnections[connectionKey!]!.remove(at: index)
      addInactive(connectionKey!, connection: connection)
    }
  }

  private static func createAndAddActive(host: String, user: String, password: String, port: Int, database: String) throws -> MySQLConnectionProtocol? {
    let connection = connectionProvider()
    try connection!.connect(host, user: user, password: password, port: port, database: database)

    let key = computeKey(host, user: user, password: password, database: database)

    addActive(key, connection: connection!)
    return connection
  }

  private static func findActiveConnection(connection: MySQLConnectionProtocol) -> (key: String?, index: Int) {
    var connectionKey:String? = nil
    var connectionIndex = -1

    for (key, value)  in activeConnections {
      if let index = value.index(where:{$0.equals(connection)}) {
        connectionIndex = index
        connectionKey = key
      }
    }

    return (connectionKey, connectionIndex)
  }

  private static func addActive(key: String, connection: MySQLConnectionProtocol) {
    if activeConnections[key] == nil {
      activeConnections[key] = [MySQLConnectionProtocol]()
    }

    activeConnections[key]!.append(connection)
  }

  private static func addInactive(key: String, connection: MySQLConnectionProtocol) {
    if inactiveConnections[key] == nil {
      inactiveConnections[key] = [MySQLConnectionProtocol]()
    }

    inactiveConnections[key]!.append(connection)
  }

  private static func getInactive(key: String) -> MySQLConnectionProtocol? {
    if inactiveConnections[key] != nil && inactiveConnections[key]!.count > 0 {
      // pop a connection off the stack
      let connection = inactiveConnections[key]![0]
      inactiveConnections[key]!.remove(at: 0)

      return (connection.isConnected()) ? connection: nil
    }

    return nil
  }

  private static func countActive() -> Int {
    lock.lock()
    defer {
      lock.unlock()
    }

    var c = 0
    for (_, value) in activeConnections {
      c += value.count
    }
    return c
  }

  private static func computeKey(host: String, user: String, password: String, database: String) -> String {
    return host + "_" + user + "_" + password + "_" + database
  }
}
