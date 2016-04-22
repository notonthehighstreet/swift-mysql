import Foundation

/// MySQLClient allows execution of queries and the return of results from MySQL databases.
public class MySQLClient: MySQLClientProtocol{

  internal let connection: MySQLConnectionProtocol

  /**
    Initialises a new MySQLClient with the provided connection.

    - Parameters:
      - connection: A valid connection object which implements the MySQLConnectionProtocol

    - Returns: A MySQLClient which can be used to query the database.

  */
  public required init(connection: MySQLConnectionProtocol) {
    self.connection = connection
  }

}

// MARK: MySQLClientProtocol implementation
extension MySQLClient {
  /**
    Retrieve information for the underlying client library version.

    - Returns: String representing the current client version.
  */
  public func info() -> String? {
    return connection.client_info()
  }

  /**
    Retrieve the version for the underlying client library version.

    - Returns: UInt representing the current client version.
  */
  public func version() -> UInt {
    return connection.client_version()
  }

  /**
    Execute the given SQL query against the database.

    - Parameters:
      - query: valid TSQL statement to execute.

    - Returns: Tuple consiting of an optional MySQLResult and MySQLError.  If the query fails then an error object will be returned and MySQLResult will be nil.  Upon success MySQLError will be nil however it is still possible for no results to be returned as some queries do not return results.
  */
  public func execute(query: String) -> (MySQLResultProtocol?, MySQLError?) {
    let result = connection.execute(query)

    if (result.0 != nil) {
      return (MySQLResult(result:result.0!, fields: result.1!, nextResult: connection.nextResult), result.2)
    }

    return (nil, result.2)
  }

  /**
    Execute the given SQL query against the database.

    - Parameters:
      - builder: MySQLQueryBuilder

    - Returns: Tuple consiting of an optional MySQLResult and MySQLError.  If the query fails then an error object will be returned and MySQLResult will be nil.  Upon success MySQLError will be nil however it is still possible for no results to be returned as some queries do not return results.

    ```
      var builder = MySQLQueryBuilder()
        .select(["abc"], table: "MyTable")
        .wheres("WHERE abc=?", "1")

      var (result, error) = mySQLClient.execute(builder)
    ```
  */
  public func execute(builder: MySQLQueryBuilder) -> (MySQLResultProtocol?, MySQLError?) {
    let statement = builder.build()
    print(statement)
    return execute(statement)
  }

  /**
    Return the next result set after executing a query, this might be used when you
    specify a multi statement query.

    - Returns: Tuple consiting of an optional CMySQLResult, array of CMySQLField and MySQLError.  If the query fails then an error object will be returned and CMySQLResult and [CMySQLField] will be nil.  Upon success MySQLError will be nil however it is still possible for no results to be returned as some queries do not return results.

    ```
      var table1Builder = MySQLQueryBuilder()
        .select(["abc"], table: "MyTable")
        .wheres("WHERE abc=?", "1")

      var table2Builder = = MySQLQueryBuilder()
        .select(["abc"], table: "MyOtherTable")
        .wheres("WHERE abc=?", "1")

      table1Builder.join(table2Builder)

      var (result, error) = mySQLClient.execute(table1Builder)
      var row = result.nextResult() // use rows from table1

      result = mySQLClient.nextResult()
      row = result.nextResult() // use rows from table2
    ```
  */
  public func nextResultSet() -> (MySQLResultProtocol?, MySQLError?) {
    let result = connection.nextResultSet()

    if (result.0 != nil) {
      return (MySQLResult(result:result.0!, fields: result.1!, nextResult: connection.nextResult), result.2)
    }

    return (nil, result.2)
  }
}
