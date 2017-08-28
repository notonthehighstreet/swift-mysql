import Foundation
import XCTest

@testable import MySQL

public class MySQLTransactionTests: XCTestCase {
    var mockConnection:MockMySQLInternalConnection?
    var transaction: MySQLTransaction?

    public override func setUp() {
        mockConnection = MockMySQLInternalConnection()
        transaction = MySQLTransaction(MySQLConnection(connection: mockConnection!))

        if transaction == nil {
            XCTFail("Unable to cast connection to transaction")
            exit(1)
        }
    }

    public func testStartCallsStartTransaction() throws {
        transaction!.start()

        XCTAssertTrue(mockConnection!.startTransactionCalled)
    }
    
    public func testCommitCallsCommitTransaction() throws {
        try transaction!.commit()

        XCTAssertTrue(mockConnection!.commitTransactionCalled)
    }
    
    public func testRollbackCallsRollbackTransaction() throws {
        try transaction!.rollback()

        XCTAssertTrue(mockConnection!.rollbackTransactionCalled)
    }
}

extension MySQLTransactionTests {
    static var allTests: [(String, (MySQLTransactionTests) -> () throws -> Void)] {
        return [
            ("testStartCallsStartTransaction", testStartCallsStartTransaction), 
            ("testCommitCallsCommitTransaction", testCommitCallsCommitTransaction), 
            ("testRollbackCallsRollbackTransaction", testRollbackCallsRollbackTransaction)
        ]
    }
}
