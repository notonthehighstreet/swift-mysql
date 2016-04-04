import Foundation
import CMySQLClient

public class MySQLHeaderParser {
  public func parse(field: MYSQL_FIELD) -> MySQLHeader {
    var header = MySQLHeader()

    header.name = String(cString: field.name)

    return header
  }
}
