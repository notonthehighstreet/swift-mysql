public protocol MySQLConnectionPoolProtocol {
  static func getConnection(host: String, user: String, password: String, database: String) throws
}
