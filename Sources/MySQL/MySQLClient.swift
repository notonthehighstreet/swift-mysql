import Foundation

public class MySQLClient: MySQLClientProtocol{

  internal var connection: MySQLConnectionProtocol

  public required init(connection: MySQLConnectionProtocol) {
    self.connection = connection
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

  public func execute(query: String) -> MySQLResult? {
    connection.execute(query)
    return nil
  }

  public func close() {
    connection.close()
  }
}
