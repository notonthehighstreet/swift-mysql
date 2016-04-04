import Foundation

public enum MySQLConnectionError: ErrorProtocol {
  case UnableToCreateConnection = "Unable to crate connection to the database"
  case UnableToConnectToDatabase = "Unable to connect to the specified database"
  case UnableToExecuteQuery = "Unable to execute the query"
  case UnableToReturnResults = "Unable to return the results of the query"
}

public protocol MySQLConnectionProtocol {
  func connect(host: String, user: String, password: String, database: String) throws
  func client_info() -> String?
  func client_version() -> UInt
  func execute(query: String) throws
  func close()
}
