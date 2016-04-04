import Foundation
import CMySQLClient

public typealias CMySQLResult = UnsafeMutablePointer<MYSQL_RES>
public typealias CMySQLRow = UnsafeMutablePointer<UnsafeMutablePointer<Int8>>
public typealias CMySQLField = UnsafeMutablePointer<MYSQL_FIELD>

public enum MySQLConnectionError: ErrorProtocol {
  case UnableToCreateConnection
  case UnableToExecuteQuery(message: String)
}

public protocol MySQLConnectionProtocol {
  func connect(host: String, user: String, password: String, database: String) throws
  func client_info() -> String?
  func client_version() -> UInt
  func execute(query: String) -> (CMySQLResult?, [CMySQLField]?, MySQLConnectionError?)
  func nextResult(result: CMySQLResult) -> CMySQLRow?
  func close()
}
