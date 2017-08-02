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
    block: ((MySQLConnectionProtocol) -> Void)) {
    var pool = MySQLConnectionPool(connectionString: connectionString, poolSize: 1) {
      return MySQL.MySQLConnection()
    }

    do {
      // get a connection from the pool with no database
      let connection = try pool.getConnection()!

      // release the connection back to the pool
      defer {
        pool.releaseConnection(connection)
      }

      block(connection)
    } catch {
      XCTFail("Unable to create connection: \(error)")
    }
  }

  func testConnectsToDBWithNoDatabase() {
    createConnection(connectionString: connectionString!){ _ in}
  }

  func testCanCreateClientAndExecuteQuery() {
    createConnection(connectionString: connectionString!) {
      (connection: MySQLConnectionProtocol) in

      // create a new client using the leased connection
      let client = MySQLClient(connection: connection)

      print("MySQL Client Info: " + client.info()!)
      print("MySQL Client Version: " + String(client.version()))

      let _ = client.execute(query: "DROP DATABASE IF EXISTS testdb")
      let _ = client.execute(query: "CREATE DATABASE testdb")
    }
  }

  func testConnectionInsertsAndReadsData() {
    connectionString!.database = "testdb"
    createConnection(connectionString: connectionString!) {
      (connection: MySQLConnectionProtocol) in

        let client = MySQLClient(connection: connection)

        let _ = client.execute(query: "DROP TABLE IF EXISTS Cars")
        let _ = client.execute(query: "CREATE TABLE Cars(Id INT, Name TEXT, Price INT, UpdatedAt TIMESTAMP)")

        // use query builder to insert data
        var queryBuilder = MySQLQueryBuilder()
          .insert(data: [
            "Id": 1,
            "Name": "Audi",
            "Price": 52642,
            "UpdatedAt": "2017-07-24 20:43:51"], table: "Cars")

        let _ = client.execute(builder: queryBuilder)

        queryBuilder = MySQLQueryBuilder()
          .insert(data: [
            "Id": 2,
            "Name": "Mercedes",
            "Price": 72341,
            "UpdatedAt": "2017-07-24 20:43:51"], table: "Cars")

        let _ = client.execute(builder: queryBuilder)

        // create query to select data from the database
        queryBuilder = MySQLQueryBuilder()
          .select(fields: ["Id", "Name", "Price", "UpdatedAt"], table: "Cars")

        let ret = client.execute(builder: queryBuilder) // returns a tuple (MySQLResult, MySQLError)
        XCTAssertNil(ret.1)

        if let result = ret.0 {
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
  }

  func testConnectionReadsMultipleRows() {
    var rowCount = 0

    connectionString!.database = "testdb"
    createConnection(connectionString: connectionString!) {
      (connection: MySQLConnectionProtocol) in

        let client = MySQLClient(connection: connection)
        let queryBuilder = MySQLQueryBuilder()
          .select(fields: ["Id", "Name", "Price", "UpdatedAt"], table: "Cars")

        let ret = client.execute(builder: queryBuilder) // returns a tuple (MySQLResult, MySQLError)
        XCTAssertNil(ret.1)

        if let resultSet = ret.0 {
          while case let row? = resultSet.nextResult() {
            XCTAssertNotNil(row)
            rowCount += 1
          }
        }
    }

    XCTAssertEqual(2, rowCount)
  }
}
