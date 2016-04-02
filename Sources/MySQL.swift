import Foundation
import CMySQLClient

public class MySQL {
  public func client_info() -> String? {
    return String(cString: CMySQLClient.get_client_info())
  }
}
