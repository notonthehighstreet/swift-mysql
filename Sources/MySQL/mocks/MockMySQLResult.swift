import Foundation

// MockMySQLResult is a mock object which can be used in unit tests to replace the real instance in order to test behaviour
public class MockMySQLResult: MySQLResultProtocol {
  public var nextCalled = 0

  public var results: [MySQLRow?]?
  public var affectedRows = 0
  public var fields = [MySQLField]()

  private var resultItterator = 0

  public func nextResult() -> MySQLRow? {
    nextCalled += 1

    if results == nil || resultItterator >= results!.count{
      resultItterator = 0
      return  nil
    } else {
      resultItterator += 1
      return results![resultItterator - 1]
    }
  }
}
