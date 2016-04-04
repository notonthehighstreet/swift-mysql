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

  public func execute(query: String) -> (MySQLResult?, MySQLConnectionError?) {
    let result = connection.execute(query)

    if (result.0 != nil) {
      return (MySQLResult(result:result.0!, fields: result.1!, nextResult: connection.nextResult), result.2)
    }

    return (nil, result.2)
  }

  public func nextResult() -> CMySQLRow? {
    return nil
  }
}
