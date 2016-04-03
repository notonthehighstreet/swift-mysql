import Foundation

public enum MySQLConnectionError: ErrorProtocol {
  case UnableToCreateConnection
}

public protocol MySQLConnectionProtocol {
  init(host: String, user: String, password: String, database: String)
  func connect() throws
  func client_info() -> String?
  func client_version() -> UInt
  func execute(query: String)
  func close()
}
