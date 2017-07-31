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
            result[headers[i].name] = pointerToString(row[i]!) as AnyObject?
          case MySQLFieldType.Tiny, MySQLFieldType.Short, MySQLFieldType.Long, MySQLFieldType.Int24, MySQLFieldType.LongLong:
            result[headers[i].name] = Int(pointerToString(row[i]!)) as AnyObject?
          case MySQLFieldType.Decimal, MySQLFieldType.NewDecimal, MySQLFieldType.Double:
            result[headers[i].name] = Double(pointerToString(row[i]!)) as AnyObject?
          case MySQLFieldType.Float:
            result[headers[i].name] = Float(pointerToString(row[i]!)) as AnyObject?
          default:
            result[headers[i].name] = nil
        }
      }
    }

    return result
  }

  private func pointerToString(_ pointer: UnsafeMutablePointer<Int8>) -> String {
    let p2 = UnsafePointer<Int8>(pointer)
    return String(cString: p2)
  }
}
