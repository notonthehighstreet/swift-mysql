import Foundation

// Protocol containing the public methods available to the MySQLClient.
public protocol MySQLClientProtocol {
  init(connection: MySQLConnectionProtocol)
  func info() -> String?
  func version() -> UInt
  func execute(query: String) -> (MySQLResultProtocol?, MySQLError?)
  func execute(builder: MySQLQueryBuilder) -> (MySQLResultProtocol?, MySQLError?)
}
