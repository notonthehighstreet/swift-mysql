import Foundation
import CMySQLClient

// Pointer to a result object returned from executing a query.
public typealias CMySQLResult = UnsafeMutablePointer<MYSQL_RES>

// Pointer to an array of strings containing the data representing a row from a query.
public typealias CMySQLRow = MYSQL_ROW

// Pointer to a MYSQL_FIELD struct as defined in the native c library.
public typealias CMySQLField = UnsafeMutablePointer<MYSQL_FIELD>

// Represents a protocol for connections to implement.
public protocol MySQLConnectionProtocol {
  func charset() -> String?
  func setCharset(charset: String) -> Bool
  func isConnected() -> Bool
  func connect(host: String, user: String, password: String) throws
  func connect(host: String, user: String, password: String, port: Int) throws
  func connect(host: String, user: String, password: String, port: Int, database: String) throws
  func connect(host: String, user: String, password: String, port: Int, database: String, charset: String) throws
  func close()
  func client_info() -> String?
  func client_version() -> UInt
  func execute(query: String) -> (CMySQLResult?, [CMySQLField]?, MySQLError?)
  func nextResult(result: CMySQLResult) -> CMySQLRow?
  func nextResultSet() -> (CMySQLResult?, [CMySQLField]?, MySQLError?)
  func equals(otherObject: MySQLConnectionProtocol) -> Bool
}
