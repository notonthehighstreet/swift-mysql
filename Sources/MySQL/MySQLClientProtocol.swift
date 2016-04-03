import Foundation

public protocol MySQLClientProtocol {
  init(connection: MySQLConnectionProtocol) throws
  func info() -> String?
  func version() -> UInt
  func execute(query: String)
  func close()
}
