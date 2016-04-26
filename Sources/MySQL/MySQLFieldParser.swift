import Foundation
import CMySQLClient

internal class MySQLFieldParser {
  internal func parse(field: MYSQL_FIELD) -> MySQLField {
    let name = String(cString: field.name)
    let type = field.type

    var fieldType = MySQLFieldType.Null

    switch type {
      case MYSQL_TYPE_TINY:
        fieldType = MySQLFieldType.Tiny
      case MYSQL_TYPE_SHORT:
        fieldType = MySQLFieldType.Short
      case MYSQL_TYPE_LONG:
        fieldType = MySQLFieldType.Long
      case MYSQL_TYPE_INT24:
        fieldType = MySQLFieldType.Int24
      case MYSQL_TYPE_LONGLONG:
        fieldType = MySQLFieldType.LongLong
      case MYSQL_TYPE_DECIMAL:
        fieldType = MySQLFieldType.Decimal
      case MYSQL_TYPE_NEWDECIMAL:
        fieldType = MySQLFieldType.NewDecimal
      case MYSQL_TYPE_FLOAT:
        fieldType = MySQLFieldType.Float
      case MYSQL_TYPE_DOUBLE:
        fieldType = MySQLFieldType.Double
      case MYSQL_TYPE_BIT:
        fieldType = MySQLFieldType.Bit
      case MYSQL_TYPE_TIMESTAMP:
        fieldType = MySQLFieldType.Timestamp
      case MYSQL_TYPE_DATE:
        fieldType = MySQLFieldType.Date
      case MYSQL_TYPE_TIME:
        fieldType = MySQLFieldType.Time
      case MYSQL_TYPE_DATETIME:
        fieldType = MySQLFieldType.DateTime
      case MYSQL_TYPE_YEAR:
        fieldType = MySQLFieldType.Year
      case MYSQL_TYPE_STRING:
        fieldType = MySQLFieldType.String
      case MYSQL_TYPE_VAR_STRING:
        fieldType = MySQLFieldType.VarString
      case MYSQL_TYPE_BLOB:
        fieldType = MySQLFieldType.Blob
      case MYSQL_TYPE_SET:
        fieldType = MySQLFieldType.Set
      case MYSQL_TYPE_ENUM:
        fieldType = MySQLFieldType.Enum
      case MYSQL_TYPE_GEOMETRY:
        fieldType = MySQLFieldType.Geometry
      default:
        fieldType = MySQLFieldType.Null
    }

    let header = MySQLField(name: name, type: fieldType)

    return header
  }
}
