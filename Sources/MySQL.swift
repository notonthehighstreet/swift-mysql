import Foundation
import CMySQLClient

public class MySQL {

  private var connection: UnsafeMutablePointer<MYSQL> = nil

  public func client_info() -> String? {
    return String(cString: CMySQLClient.mysql_get_client_info())
  }

  public func client_version() -> UInt {
    return CMySQLClient.mysql_get_client_version();
  }

  public func connect() {
    connection = CMySQLClient.mysql_init(nil);

    if connection == nil {
      print("unable to create connection")
    }

    if CMySQLClient.mysql_real_connect(connection, "192.168.99.100", "root", "my-secret-pw", nil, 0, nil, 0) == nil {
      print("unable to connect to database")
      close()
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
