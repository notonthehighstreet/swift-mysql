import Foundation

// MockMySQLResult is a mock object which can be used in unit tests to replace the real instance in order to test behaviour
public class MockMySQLResult: MySQLResultProtocol {
  public var nextCalled = 0
  public var results: [MySQLRow?]?

  public func nextResult() -> MySQLRow? {
    nextCalled += 1

    if results == nil || nextCalled > results!.count{
      return  nil
    } else {
      return results![nextCalled - 1]
    }
  }
}
