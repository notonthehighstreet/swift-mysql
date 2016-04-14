import Foundation

#if os(OSX)
    public typealias MySQLRow = [String: AnyObject]
#else
    public typealias MySQLRow = [String: Any]
#endif
