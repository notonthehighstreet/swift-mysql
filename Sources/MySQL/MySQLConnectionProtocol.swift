import Foundation

// Protocol containing the public methods available to the MySQLClient.
public protocol MySQLConnectionProtocol {
  func info() -> String?
  func version() -> UInt
  func isConnected() -> Bool
  func execute(query: String) throws  -> MySQLResultProtocol?
  func execute(builder: MySQLQueryBuilder) throws -> MySQLResultProtocol?
  func nextResultSet() throws -> (MySQLResultProtocol?)
  func equals(otherObject: MySQLConnectionProtocol) -> Bool
}
