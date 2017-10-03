import Foundation

/**
  MySQLConnectionString encapsulates the information required
  to be able to connect to a MySQL database
*/
public struct MySQLConnectionString {
  public var host: String = ""
  public var port:Int = 3306
  public var user:String = ""
  public var password: String = ""
  public var database: String = ""

  public init(host: String, port: Int = 3306, user: String = "", password: String = "", database: String = "") {
    self.host = host
    self.port = port
    self.user = user
    self.password = password
    self.database = database
  }

  public func key() -> String {
    return "\(host)_\(user)_\(password)_\(database)"
  }
}
