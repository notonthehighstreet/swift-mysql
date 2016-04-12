import Foundation

public protocol MySQLConnectionPoolProtocol {
  static func setConnectionProvider(provider: () -> MySQLConnectionProtocol?)
  static func getConnection(host: String, user: String, password: String) throws -> MySQLConnectionProtocol?
  static func getConnection(host: String, user: String, password: String, database: String) throws -> MySQLConnectionProtocol?
  static func releaseConnection(connection: MySQLConnectionProtocol)
}
