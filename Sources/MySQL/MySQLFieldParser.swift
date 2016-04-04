import Foundation
import CMySQLClient

internal class MySQLFieldParser {
  internal func parse(field: MYSQL_FIELD) -> MySQLField {
    var header = MySQLField()

    header.name = String(cString: field.name)

    return header
  }
}
