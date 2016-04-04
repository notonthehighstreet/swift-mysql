import Foundation
import CMySQLClient

public class MySQLConnection : MySQLConnectionProtocol {

  private var connection: UnsafeMutablePointer<MYSQL> = nil
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

  public func execute(query: String) {
    if (CMySQLClient.mysql_query(connection, query) == 1) {
      print("Error executing query: " + query)
      print(String(cString: CMySQLClient.mysql_error(connection)))
      return
    }

    let result = CMySQLClient.mysql_store_result(connection);
    if (result == nil) {
      print("Error getting results for: " + query)
      print(String(cString: CMySQLClient.mysql_error(connection)))
      return
    }

    let num_fields = CMySQLClient.mysql_num_fields(result);
    print("Fields: " + String(num_fields))

    var row:UnsafeMutablePointer<UnsafeMutablePointer<Int8>>

    var field:UnsafeMutablePointer<MYSQL_FIELD>

    field = mysql_fetch_field(result)
    repeat {
      print(String(cString: field.pointee.name), terminator: " ")
      field = mysql_fetch_field(result)
    } while (field != nil)
    print("")

    row = CMySQLClient.mysql_fetch_row(result)
    repeat {
      for i:Int in 0...Int(num_fields) {
        print(String(cString: row[i]), terminator: " ")
      }
      row = CMySQLClient.mysql_fetch_row(result)
      print("")
    } while (row != nil)

    CMySQLClient.mysql_free_result(result);
  }

  public func close() {
    CMySQLClient.mysql_close(connection)
  }

}
