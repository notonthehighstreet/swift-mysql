import Foundation

public protocol MySQLResultProtocol {
    var fields: [MySQLField] { get }
    var affectedRows: Int { get }
    func nextResult() -> MySQLRow?
}
