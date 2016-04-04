import Foundation

public enum MySQLConnectionError: ErrorProtocol {
  case UnableToCreateConnection
}

public protocol MySQLConnectionProtocol {
  func connect(host: String, user: String, password: String, database: String) throws
  func client_info() -> String?
  func client_version() -> UInt
  func execute(query: String)
  func close()
}
