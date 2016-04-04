import Foundation

#if os(OSX)
    typealias MySQLRow = [String: AnyObject]
#else
    typealias MySQLRow = [String: Any]
#endif

public class MySQLResult {
  var headers = [MySQLHeader]()
}
