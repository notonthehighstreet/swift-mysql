import Foundation

public protocol MySQLClientProtocol {
  init(connection: MySQLConnectionProtocol)
  func info() -> String?
  func version() -> UInt
  func execute(query: String) -> (MySQLResult?, MySQLConnectionError?)
}
