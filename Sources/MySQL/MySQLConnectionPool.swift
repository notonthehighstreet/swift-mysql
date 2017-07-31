import Foundation

public class MySQLConnectionPool: MySQLConnectionPoolProtocol {

  var connectionString: MySQLConnectionString
  var activeConnections = [String: [MySQLConnectionProtocol]]()
  var inactiveConnections = [String: [MySQLConnectionProtocol]]()
  var poolSize:Int = 20
  var poolTimeout:Double = 20.0 // 20s

  var lock = NSLock()

  var connectionProvider:() -> MySQLConnectionProtocol? = { () -> MySQLConnectionProtocol? in
    return nil
  }

  var logger:(_: MySQLConnectionPoolMessage) -> Void = {
    (message: MySQLConnectionPoolMessage) -> Void in
  }


 public required init(connectionString: MySQLConnectionString, 
       poolSize: Int, 
       provider: @escaping () -> MySQLConnectionProtocol?) {

    self.connectionString = connectionString
    self.poolSize = poolSize
    self.connectionProvider = provider
  }

  /**
    setPoolSize sets the size for the connection pool, default is 20

    - Parameters:
      - size: new size of the pool
  */
  public func setPoolSize(size: Int) {
    poolSize = size
  }

  public func setLogger(logger: @escaping (_: MySQLConnectionPoolMessage) -> Void) {
    self.logger = logger
  }

  /**
    setConnectionProvider sets a reference to a closure which returns an object implementing MySQLConnectionProtocol.  Everytime the connection pool requires a new connection this closure will be executed.

    - Parameters:
      - provider: Closure which returns an object implementing MySQLConnectionProtocol.
  */
  public func setConnectionProvider(provider: @escaping () -> MySQLConnectionProtocol?) {
    self.connectionProvider = provider
  }
  /**
    getConnection returns a connection from the pool, if a connection is unsuccessful then getConnection throws a MySQLError,
    if the pool has no available connections getConnection will block util either a connection is free or a timeout occurs.

    - Returns: An object conforming to the MySQLConnectionProtocol.
  */
  public func getConnection() throws -> MySQLConnectionProtocol? {
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
    let key = self.connectionString.key()

    if let connection = getInactive(key: key) {
      addActive(key: key, connection: connection)
      logger(_: MySQLConnectionPoolMessage.RetrievedConnectionFromPool)
      return connection
    } else {
      return try createAndAddActive()
    }
  }

  /**
    getConnection returns a connection from the pool, if a connection is unsuccessful then getConnection throws a MySQLError,
    if the pool has no available connections getConnection will block util either a connection is free or a timeout occurs.

    By passing the optional closure once the code has executed within the block the connection is automatically released
    back to the pool saving the requirement to manually call releaseConnection.

    - Parameters:
      - closure: Code that will be executed before connection is released back to the pool

    - Returns: An object implementing the MySQLConnectionProtocol.

    ```
      MySQLConnectionPoolProtocol.getConnection() {
        (connection: MySQLConnectionProtocol) in
          let result = connection.execute("SELECT * FROM TABLE")
          ...
      }
    ```
  */
  public func getConnection(closure: ((_: MySQLConnectionProtocol) -> Void)) throws {
    do {
      let connection = try getConnection()
      defer {
        self.releaseConnection(connection!)
      }

      closure(_: connection!)
    } catch {
      logger(_: MySQLConnectionPoolMessage.FailedToCreateConnection)
      throw error
    }
  }

  /**
    releaseConnection returns a connection to the pool.

    - Parameters:
      - connection: Connection to be returned to the pool
  */
  public func releaseConnection(_ connection: MySQLConnectionProtocol) {
    lock.lock()
    defer {
      lock.unlock()
    }

    let (connectionKey, index) = findActiveConnection(connection: connection)

    if(connectionKey != nil) {
      activeConnections[connectionKey!]!.remove(at: index)
      addInactive(key: connectionKey!, connection: connection)
    }
  }

  private func createAndAddActive() throws -> MySQLConnectionProtocol? {
    let connection = connectionProvider()

    do {
      try connection!.connect(host: self.connectionString.host,
                              user: self.connectionString.user, 
                              password: self.connectionString.password, 
                              port: self.connectionString.port, 
                              database: self.connectionString.database)
    } catch {
      logger(_: MySQLConnectionPoolMessage.FailedToCreateConnection)
      throw error
    }

    let key = self.connectionString.key()
    addActive(key: key, connection: connection!)
    logger(_: MySQLConnectionPoolMessage.CreatedNewConnection)

    return connection
  }

  private func findActiveConnection(connection: MySQLConnectionProtocol) -> (key: String?, index: Int) {
    var connectionKey:String? = nil
    var connectionIndex = -1

    for (key, value)  in activeConnections {
      if let index = value.index(where:{$0.equals(otherObject: connection)}) {
        connectionIndex = index
        connectionKey = key
      }
    }

    return (connectionKey, connectionIndex)
  }

  private func addActive(key: String, connection: MySQLConnectionProtocol) {
    if activeConnections[key] == nil {
      activeConnections[key] = [MySQLConnectionProtocol]()
    }

    activeConnections[key]!.append(connection)
  }

  private func addInactive(key: String, connection: MySQLConnectionProtocol) {
    if inactiveConnections[key] == nil {
      inactiveConnections[key] = [MySQLConnectionProtocol]()
    }

    inactiveConnections[key]!.append(connection)
  }

  private func getInactive(key: String) -> MySQLConnectionProtocol? {
    if inactiveConnections[key] != nil && inactiveConnections[key]!.count > 0 {
      // pop a connection off the stack
      let connection = inactiveConnections[key]![0]
      inactiveConnections[key]!.remove(at: 0)

      if connection.isConnected() {
        return connection
      } else {
        logger(_: MySQLConnectionPoolMessage.ConnectionDisconnected)
        return nil
      }
    }

    return nil
  }

  private func countActive() -> Int {
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
}
