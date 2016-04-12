import Foundation
import CMySQLClient

// Represents an active connection to a MySQL database.
public class MySQLConnection : MySQLConnectionProtocol  {
  private var uuid: UInt32

  private var connection: UnsafeMutablePointer<MYSQL> = nil
  private var result:UnsafeMutablePointer<MYSQL_RES> = nil

  public init() {
    uuid = arc4random_uniform(UInt32.max)
  }
}

extension MySQLConnection {

  public func equals(otherObject: MySQLConnectionProtocol) -> Bool {
    return uuid == (otherObject as! MySQLConnection).uuid
  }

  /**
    Open a connection to the database with the given parameters, in the instance of a failed connection the connect method throws MySQLError.

    - Parameters:
      - host: The host name or ip address of the database.
      - user: The username to use for the connection.
      - password: The password to use for the connection.
  */
  public func connect(host: String, user: String, password: String) throws {
    return try connect(host, user: user, password: password, database: "")
  }

  /**
    Open a connection to the database with the given parameters, in the instance of a failed connection the connect method throws MySQLError.

    - Parameters:
      - host: The host name or ip address of the database.
      - user: The username to use for the connection.
      - password: The password to use for the connection.
      - database: The database to connect to.
  */
  public func connect(host: String, user: String, password: String, database: String) throws {
    connection = CMySQLClient.mysql_init(nil);

    if connection == nil {
      print("Error: Unable to create connection")
      throw MySQLError.UnableToCreateConnection
    }

    if CMySQLClient.mysql_real_connect(connection, host, user, password, database, 0, nil, 0) == nil {
      print("Error: Unable to connect to database")
      close()
      throw MySQLError.UnableToCreateConnection
    }
  }

  /**
    Close the connection.
  */
  public func close() {
    clearResult()
    CMySQLClient.mysql_close(connection)
  }

  /**
    Retrieve information for the underlying client library version.

    - Returns: String representing the current client version.
  */
  public func client_info() -> String? {
    return String(cString: CMySQLClient.mysql_get_client_info())
  }

  /**
    Retrieve the version for the underlying client library version.

    - Returns: UInt representing the current client version.
  */
  public func client_version() -> UInt {
    return CMySQLClient.mysql_get_client_version();
  }

  /**
    Execute the given SQL query against the database.

    - Parameters:
      - query: valid TSQL statement to execute.

    - Returns: Tuple consiting of an optional CMySQLResult, array of CMySQLField and MySQLError.  If the query fails then an error object will be returned and CMySQLResult and [CMySQLField] will be nil.  Upon success MySQLError will be nil however it is still possible for no results to be returned as some queries do not return results.
  */
  public func execute(query: String) -> (CMySQLResult?, [CMySQLField]?, MySQLError?) {
    clearResult() // clear any memory allocated to a previous result

    if (CMySQLClient.mysql_query(connection, query) == 1) {
      let error = String(cString: CMySQLClient.mysql_error(connection))
      print("Error executing query: " + query)
      print(error)

      return (nil, nil, MySQLError.UnableToExecuteQuery(message: error))
    }

    result = CMySQLClient.mysql_store_result(connection);
    if (result == nil) {
      print("Error getting results for: " + query)
      print(String(cString: CMySQLClient.mysql_error(connection)))
      return (nil, nil, nil)
    } else {
      return (result, getHeaders(result), nil)
    }
  }

  /**
    Return the next result from executing a query.

    - Parameters:
      - result: CMySQLResult instance returned from execute.

    - Returns: A pointer to an array of strings.
  */
  public func nextResult(result: CMySQLResult) -> CMySQLRow? {
    if result == nil {
      return nil
    }

    let row = CMySQLClient.mysql_fetch_row(result)
    if row != nil {
      return row
    } else {
      // no more results free any memory and return
      clearResult()
      return nil
    }
  }

  /**
    Clears any memory  which has been allocated to a mysql result
  */
  private func clearResult() {
    if result != nil {
      CMySQLClient.mysql_free_result(result)
    }
  }

  private func getHeaders(resultPointer: CMySQLResult) -> [CMySQLField] {
    let num_fields = CMySQLClient.mysql_num_fields(resultPointer);
    var fields = [CMySQLField]()

    for _ in 0..<num_fields {
      fields.append(mysql_fetch_field(resultPointer))
    }

    return fields
  }
}
