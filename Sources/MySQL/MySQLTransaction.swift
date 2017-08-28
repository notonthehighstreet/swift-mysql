import Foundation

public class MySQLTransaction: MySQLConnection {

    public init(_ connection: MySQLConnection) {
        super.init(connection: connection.connection)
    }

    public func start() {
        connection.startTransaction()
    }

    public func commit() throws {
        try connection.commitTransaction() 
    }

    public func rollback() throws {
        try connection.rollbackTransaction() 
    }
}
