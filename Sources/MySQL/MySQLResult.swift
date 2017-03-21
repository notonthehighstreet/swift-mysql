import Foundation
import CMySQLClient

// MySQLResult encapsulates the fields and data returned from a query, this object is not ordinarily instanstiated.
public class MySQLResult: MySQLResultProtocol {

  private var resultPointer: CMySQLResult? = nil
  private var getNextResult:(_:CMySQLResult) -> CMySQLRow?

  /**
    The fields property returns an array containing the fields which corresponds to the query executed.
  */
  public var fields = [MySQLField]()

  /**
    nextResult returns the next row from the database for the executed query, when no more rows are available nextResult returns nil.

    Returns: an instance of MySQLRow which is a dictionary [field_name (String): Object], when no further rows are avaialble this method returns nil.
  */
  public func nextResult() -> MySQLRow? {
    if  resultPointer == nil {
      return nil
    }

    if let row = getNextResult(_: resultPointer!) {
      let parser = MySQLRowParser()
      return parser.parse(row: row, headers:fields)
    } else {
      return nil
    }
  }

  internal init(result:CMySQLResult, fields: [CMySQLField], nextResult: @escaping ((_:CMySQLResult) -> CMySQLRow?)) {
    resultPointer = result
    getNextResult = nextResult
    parseFields(fields: fields)
  }

  private func parseFields(fields: [CMySQLField]) {
    let parser = MySQLFieldParser()
    for field in fields {
      self.fields.append(parser.parse(field: field.pointee))
    }
  }
}
