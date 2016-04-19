import Foundation

public protocol MySQLResultProtocol {
  func nextResult() -> MySQLRow?
}
