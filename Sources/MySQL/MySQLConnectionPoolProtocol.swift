import Foundation

public protocol MySQLConnectionPoolProtocol {

  init(connectionString: MySQLConnectionString,
       poolSize: Int,
       defaultCharset: String)

  /**
    setLogger sets the function that will be called when an event occurs with the connectionPool,
    you can use this method can be used to setup logging to be used for debugging or metrics.

    ```
      MySQLConnectionPool.getConnection { (message: MySQLConnectionPoolMessage) in
          print(message)
      }
    ```
  */
  func setLogger(logger: @escaping (_ message: MySQLConnectionPoolMessage) -> Void)

  /**
    getClient returns a client from the pool, if a connection is unsuccessful 
    then getConnection throws a MySQLError. If the pool has no available connections 
    getConnection will block util either a connection is free or a timeout occurs.

    - Returns: An object implementing the MySQLClientProtocol.
  */
  func getConnection() throws -> MySQLConnectionProtocol?

  /**
    getClient returns a client from the pool, if a connection is unsuccessful 
    then getClient throws a MySQLError. If the pool has no available connections 
    getConnection will block util either a connection is free or a timeout occurs.

    By passing the optional closure once the code has executed within the block 
    the connection is automatically released back to the pool saving the 
    requirement to manually call releaseConnection.

    - Parameters:
      - closure: Code that will be executed before connection is released back to the pool

    - Returns: An object implementing the MySQLClientProtocol.

    ```
      MySQLConnectionPoolProtocol.getConnection() {
        (connection: MySQLConnectionProtocol) in
          let result = connection.execute("SELECT * FROM TABLE")
          ...
      }
    ```
  */
  func getConnection(closure: ((_: MySQLConnectionProtocol) throws -> Void)) throws

  /**
    releaseClient returns a client to the pool.

    - Parameters:
      - clent: Client to be returned to the pool
  */
  func releaseConnection(_ connection: MySQLConnectionProtocol)
}
