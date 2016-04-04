import Foundation
import CMySQLClient

public class MySQLConnection : MySQLConnectionProtocol {

  private var connection: UnsafeMutablePointer<MYSQL> = nil
  private var result:UnsafeMutablePointer<MYSQL_RES> = nil

  public init() {}
}

extension MySQLConnection {
  public func client_info() -> String? {
    return String(cString: CMySQLClient.mysql_get_client_info())
  }

  public func client_version() -> UInt {
    return CMySQLClient.mysql_get_client_version();
  }

  public func connect(host: String, user: String, password: String, database: String) throws {
    connection = CMySQLClient.mysql_init(nil);

    if connection == nil {
      print("Error: Unable to create connection")
      throw MySQLConnectionError.UnableToCreateConnection
    }

    if CMySQLClient.mysql_real_connect(connection, host, user, password, nil, 0, nil, 0) == nil {
      print("Error: Unable to connect to database")
      close()
      throw MySQLConnectionError.UnableToCreateConnection
    }
  }

  public func execute(query: String) -> (CMySQLResult?, [CMySQLField]?, MySQLConnectionError?) {
    if (CMySQLClient.mysql_query(connection, query) == 1) {
      let error = String(cString: CMySQLClient.mysql_error(connection))
      print("Error executing query: " + query)
      print(error)

      return (nil, nil, MySQLConnectionError.UnableToExecuteQuery(message: error))
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

  private func getHeaders(resultPointer: CMySQLResult) -> [CMySQLField] {
    let num_fields = CMySQLClient.mysql_num_fields(resultPointer);
    var fields = [CMySQLField]()

    for _ in 0..<num_fields {
      fields.append(mysql_fetch_field(resultPointer))
    }

    return fields
  }

  public func nextResult(result: CMySQLResult) -> CMySQLRow? {
    if result == nil {
      return nil
    }

    let row = CMySQLClient.mysql_fetch_row(result)
    if row != nil {
      return row
    } else {
      CMySQLClient.mysql_free_result(result)
      return nil
    }
  }

  public func close() {
    CMySQLClient.mysql_close(connection)
  }
}
