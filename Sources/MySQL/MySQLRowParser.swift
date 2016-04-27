import Foundation

internal class MySQLRowParser {

  internal func parse(row: CMySQLRow, headers: [MySQLField]) -> MySQLRow {
    var result = MySQLRow()

    for i in 0...(headers.count-1) {
      if row[i] == nil {
          result[headers[i].name] = nil
      } else {
        switch headers[i].type {
          case MySQLFieldType.String:
            result[headers[i].name] = String(cString: row[i])
          case MySQLFieldType.Int24:
            result[headers[i].name] = Int(String(cString: row[i]))
          default:
            result[headers[i].name] = nil
        }
      }
    }

    return result
  }
}
