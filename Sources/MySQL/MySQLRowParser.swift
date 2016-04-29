import Foundation

internal class MySQLRowParser {

  internal func parse(row: CMySQLRow, headers: [MySQLField]) -> MySQLRow {
    var result = MySQLRow()

    for i in 0...(headers.count-1) {
      if row[i] == nil {
          result[headers[i].name] = nil
      } else {
        switch headers[i].type {
          case MySQLFieldType.String, MySQLFieldType.VarString:
            result[headers[i].name] = String(cString: row[i]!)
          case MySQLFieldType.Tiny, MySQLFieldType.Short, MySQLFieldType.Long, MySQLFieldType.Int24, MySQLFieldType.LongLong:
            result[headers[i].name] = Int(String(cString: row[i]!))
          case MySQLFieldType.Decimal, MySQLFieldType.NewDecimal, MySQLFieldType.Double:
            result[headers[i].name] = Double(String(cString: row[i]!))
          case MySQLFieldType.Float:
            result[headers[i].name] = Float(String(cString: row[i]!))
          default:
            result[headers[i].name] = nil
        }
      }
    }

    return result
  }
}
