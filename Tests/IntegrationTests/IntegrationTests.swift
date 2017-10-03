import Foundation
import XCTest
import MySQL

var connectionString: MySQLConnectionString?

public class IntegrationTests: XCTestCase {
  public override func setUp() {
    let mySQLServer = ProcessInfo.processInfo.environment["MYSQL_SERVER"] ?? "0.0.0.0"
    connectionString = MySQLConnectionString(host: mySQLServer)
    connectionString!.port = 3306
    connectionString!.user = "root"
    connectionString!.password = "my-secret-pw"
    connectionString!.database = ""
  }

  func createConnection(
    connectionString: MySQLConnectionString,
    block: ((MySQLConnectionProtocol) throws -> Void)) {

        var pool = MySQLConnectionPool(connectionString: connectionString, poolSize: 1, defaultCharset: "utf8")

        do {
           // get a connection from the pool with no database
           let connection = try pool.getConnection()!

           // release the connection back to the pool
           defer {
             pool.releaseConnection(connection)
           }

           try block(connection)
        } catch {
            print(error)
            XCTFail("An exception has ocurred: \(error)")
        }
  }

  func testConnectsToDBWithNoDatabase() {
    createConnection(connectionString: connectionString!){ _ in}
  }

  func testCanCreateClientAndExecuteQuery() {
    createConnection(connectionString: connectionString!) {
      (connection: MySQLConnectionProtocol) in

      print("MySQL Client Info: " + connection.info()!)
      print("MySQL Client Version: " + String(connection.version()))

      let _ = try connection.execute(query: "DROP DATABASE IF EXISTS testdb")
      let _ = try connection.execute(query: "CREATE DATABASE testdb")
    }
  }

  func testConnectionInsertsAndReadsData() {
    connectionString!.database = "testdb"
    createConnection(connectionString: connectionString!) {
      (connection: MySQLConnectionProtocol) in

        let _ = try connection.execute(query: "DROP TABLE IF EXISTS Cars")
        let _ = try connection.execute(query: "CREATE TABLE Cars(Id INT, Name TEXT, Price INT, UpdatedAt TIMESTAMP, PRIMARY KEY (Id))")

        // use query builder to insert data
        var queryBuilder = MySQLQueryBuilder()
          .insert(data: [
            "Id": 1,
            "Name": "Audi",
            "Price": 52642,
            "UpdatedAt": "2017-07-24 20:43:51"], table: "Cars")

        let _ = try connection.execute(builder: queryBuilder)

        queryBuilder = MySQLQueryBuilder()
          .insert(data: [
            "Id": 2,
            "Name": "Mercedes",
            "Price": 72341,
            "UpdatedAt": "2017-07-24 20:43:51"], table: "Cars")

        let _ = try connection.execute(builder: queryBuilder)

        // create query to select data from the database
        queryBuilder = MySQLQueryBuilder()
          .select(fields: ["Id", "Name", "Price", "UpdatedAt"], table: "Cars")

        let result = try connection.execute(builder: queryBuilder)

        if let r = result.nextResult() {
            XCTAssertEqual(1, r["Id"] as! Int)
            XCTAssertEqual("Audi", r["Name"] as! String)
            XCTAssertNotNil(r["Price"])
            XCTAssertNotNil(r["UpdatedAt"])
        } else {
            XCTFail("No results")
        }
    }
  }

  func testConnectionReadsMultipleRows() {
    var rowCount = 0

    connectionString!.database = "testdb"
    createConnection(connectionString: connectionString!) {
      (connection: MySQLConnectionProtocol) in

        let queryBuilder = MySQLQueryBuilder()
          .select(fields: ["Id", "Name", "Price", "UpdatedAt"], table: "Cars")

        let result = try connection.execute(builder: queryBuilder)

        if result.affectedRows == 0 {
            XCTFail("No results")
        }

        while case let row? = result.nextResult() {            
            XCTAssertNotNil(row)
            rowCount += 1
        }
    }

    XCTAssertEqual(2, rowCount)
  }

  func testSelectWithOrderedResults() {
    connectionString!.database = "testdb"
    createConnection(connectionString: connectionString!) {
      (connection: MySQLConnectionProtocol) in

      let queryBuilder = MySQLQueryBuilder()
        .select(fields: ["Id", "Name", "Price", "UpdatedAt"], table: "Cars")
        .order(byExpression: "Name", order: .Descending)

      let result = try connection.execute(builder: queryBuilder)

      if let r = result.nextResult() {
          XCTAssertEqual("Mercedes", r["Name"] as! String)
      } else {
          XCTFail("No results")
      }
    }
  }

  func testUpdateWithNoRecordFails() {
    connectionString!.database = "testdb"
    createConnection(connectionString: connectionString!) {
      (connection: MySQLConnectionProtocol) in
        var row = MySQLRow()
        row["Name"] = "Something"

        let queryBuilder = MySQLQueryBuilder()
          .update(data: row, table: "Cars")
          .wheres(statement: "id=?", parameters: "12")

        let result = try connection.execute(builder: queryBuilder)

        XCTAssertEqual(0, result.affectedRows)
    }
  }

  func testSeeksToRow() {
    connectionString!.database = "testdb"
    createConnection(connectionString: connectionString!) {
      (connection: MySQLConnectionProtocol) in
        let queryBuilder = MySQLQueryBuilder()
          .select(fields: ["Id", "Name", "Price", "UpdatedAt"], table: "Cars")

        let result = try connection.execute(builder: queryBuilder)

        if result.affectedRows == 0 {
            XCTFail("No results")
        }

        result.seek(offset: 1)

        if let r = result.nextResult() {
            XCTAssertEqual(2, r["Id"] as! Int)
        } else {
            XCTFail("No results")
        }
    }
  }

  func testUpsertWithNoRecordInserts() {
    connectionString!.database = "testdb"
    createConnection(connectionString: connectionString!) {
      (connection: MySQLConnectionProtocol) in
        var row = MySQLRow()
        row["Id"] = 7
        row["Name"] = "Car A"

        let queryBuilder = MySQLQueryBuilder()
          .upsert(data: row, table: "Cars")

        let result = try connection.execute(builder: queryBuilder)

        XCTAssertEqual(1, result.affectedRows)
    }
  }

  func testUpsertWithRecordUpdates() {
    connectionString!.database = "testdb"
    createConnection(connectionString: connectionString!) {
      (connection: MySQLConnectionProtocol) in
        var row = MySQLRow()
        row["Id"] = 7
        row["Name"] = "Car B"

        let queryBuilder = MySQLQueryBuilder()
          .upsert(data: row, table: "Cars")

        let result = try connection.execute(builder: queryBuilder)
        XCTAssertEqual(2, result.affectedRows)

        let selectBuilder = MySQLQueryBuilder()
            .select(fields: ["Id", "Name"], table: "Cars")
            .wheres(statement: "Id = ?", parameters: "7")
        let selectResult = try connection.execute(builder: selectBuilder)

        guard let data = selectResult.nextResult() else {
            XCTFail("No results")
            return
        }

        XCTAssertEqual("Car B", data["Name"] as? String)
    }
  }

  func testInsertAndRollbackDoesNotCreateRecord() {
    connectionString!.database = "testdb"
    createConnection(connectionString: connectionString!) {
      (connection: MySQLConnectionProtocol) in
        connection.startTransaction()

        var row = MySQLRow()
        row["Id"] = 10
        row["Name"] = "Car Transaction"

        let queryBuilder = MySQLQueryBuilder()
          .insert(data: row, table: "Cars")

        let result = try connection.execute(builder: queryBuilder)
        XCTAssertEqual(1, result.affectedRows)

        try connection.rollbackTransaction()

        let selectBuilder = MySQLQueryBuilder()
            .select(fields: ["Id", "Name"], table: "Cars")
            .wheres(statement: "Id = ?", parameters: "10")
        let selectResult = try connection.execute(builder: selectBuilder)

        if let _ = selectResult.nextResult() {
            XCTFail("Transaction should have been rolled back")
            return
        }
    }
  }

  func testInsertAndCommitCreatesRecord() {
    connectionString!.database = "testdb"
    createConnection(connectionString: connectionString!) {
      (connection: MySQLConnectionProtocol) in
        connection.startTransaction()

        var row = MySQLRow()
        row["Id"] = 11
        row["Name"] = "Car Transaction"

        let queryBuilder = MySQLQueryBuilder()
          .insert(data: row, table: "Cars")

        let result = try connection.execute(builder: queryBuilder)
        XCTAssertEqual(1, result.affectedRows)

        try connection.commitTransaction()

        let selectBuilder = MySQLQueryBuilder()
            .select(fields: ["Id", "Name"], table: "Cars")
            .wheres(statement: "Id = ?", parameters: "11")
        let selectResult = try connection.execute(builder: selectBuilder)

        guard let data = selectResult.nextResult() else {
            XCTFail("No data")
            return
        }

        XCTAssertEqual("Car Transaction", data["Name"] as? String)
    }
  }
}
