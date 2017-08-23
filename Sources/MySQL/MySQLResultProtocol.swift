import Foundation

public protocol MySQLResultProtocol {
    var fields: [MySQLField] { get }
    var affectedRows: Int64 { get }
    func nextResult() -> MySQLRow?
    func seek(offset: Int64)
}
