import Foundation

internal class MySQLRowParser {

  internal func parse(row: CMySQLRow, headers: [MySQLField]) -> MySQLRow {
    var result = MySQLRow()

    for i in 0...(headers.count-1) {
      result[headers[i].name] = String(cString: row[i])
    }

    return result
  }
}
