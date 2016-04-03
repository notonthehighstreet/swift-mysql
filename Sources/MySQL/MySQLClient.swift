import Foundation

public class MySQLClient: MySQLClientProtocol{

  internal var connection: MySQLConnectionProtocol

  public required init(connection: MySQLConnectionProtocol) throws {
    self.connection = connection
    try self.connection.connect()
  }

}

// Client protocol implementation
extension MySQLClient {
  public func info() -> String? {
    return connection.client_info()
  }

  public func version() -> UInt {
    return connection.client_version()
  }

  public func execute(query: String) {
    connection.execute(query)
  }

  public func close() {
    connection.close()
  }
}
