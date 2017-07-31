import Foundation

public protocol MySQLConnectionPoolProtocol {

  init(connectionString: MySQLConnectionString, 
       poolSize: Int, 
       provider: @escaping () -> MySQLConnectionProtocol?)

  /**
    setConnectionProvider requires you to provide a closure which returns a new object which implements
    the MySQLConnectionProtocol.  Everytime a new connection is required this block is called.

    - Parameters:
      - provider: closure returning an object implementing MySQLConnectionProtocol

    ```
      MySQLConnectionPoolProtocol.setConnectionProvider() {
        return MySQLConnection()
      }
    ```
  **/
  func setConnectionProvider(provider: @escaping () -> MySQLConnectionProtocol?)

  /**
    setPoolSize sets the size for the connection pool, default is 20

    - Parameters:
      - size: new size of the pool
  */
  func setPoolSize(size: Int)

  /**
    setLogger sets the function that will be called when an event occurs with the connectionPool,
    you can use this method can be used to setup logging to be used for debugging or metrics.

    ```
      MySQLConnectionPool.setPoolSize {
        (message: MySQLConnectionPoolMessage) in
          print(message)
    }
    ```
  */
  func setLogger(logger: @escaping (_ message: MySQLConnectionPoolMessage) -> Void)

  /**
    getConnection returns a connection from the pool, if a connection is unsuccessful then getConnection throws a MySQLError,
    if the pool has no available connections getConnection will block util either a connection is free or a timeout occurs.

    - Returns: An object implementing the MySQLConnectionProtocol.
  */
  func getConnection() throws -> MySQLConnectionProtocol?

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
  func getConnection(closure: ((_: MySQLConnectionProtocol) -> Void)) throws

  /**
    releaseConnection returns a connection to the pool.

    - Parameters:
      - connection: Connection to be returned to the pool
  */
  func releaseConnection(_ connection: MySQLConnectionProtocol)
}
