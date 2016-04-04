public protocol MySQLConnectionPoolProtocol {
  static func setConnectionProvider(provider: () -> MySQLConnectionProtocol?)
  static func getConnection(host: String, user: String, password: String, database: String) throws -> MySQLConnectionProtocol?
}
