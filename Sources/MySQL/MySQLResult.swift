import Foundation
import CMySQLClient

#if os(OSX)
    public typealias MySQLRow = [String: AnyObject]
#else
    public typealias MySQLRow = [String: Any]
#endif

public class MySQLResult {

  private var resultPointer: CMySQLResult = nil
  private var getNextResult:(result:CMySQLResult) -> CMySQLRow?

  public var fields = [MySQLHeader]()

  public init(result:CMySQLResult, fields: [CMySQLField], nextResult: ((result:CMySQLResult) -> CMySQLRow?)) {
    resultPointer = result
    getNextResult = nextResult
    parseFields(fields)
  }

  private func parseFields(fields: [CMySQLField]) {
    let parser = MySQLHeaderParser()
    for field in fields {
      self.fields.append(parser.parse(field.pointee))
    }
  }

  public func nextResult() -> MySQLRow? {
    if let row = getNextResult(result:resultPointer) {
      let parser = MySQLRowParser()
      return parser.parse(row, headers:fields)
    } else {
      return nil
    }
  }
}
