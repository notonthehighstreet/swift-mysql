// singleton instance which maintains a number of mysql connections
// need to check how scope works in kitura
public class MySQLConnectionPool: MySQLConnectionPoolProtocol {
  public static func getConnection(host: String, user: String, password: String, database: String) {

  }
}
