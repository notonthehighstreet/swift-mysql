import Foundation
import MySQL

print("Running test client")

MySQLConnectionPool.setConnectionProvider() {
  return MySQL.MySQLConnection()
}

var connection_noDB: MySQLConnectionProtocol

do {
  // get a connection from the pool with no database
  connection_noDB = try MySQLConnectionPool.getConnection("docker.local", user: "root", password: "my-secret-pw")!
  defer {
    MySQLConnectionPool.releaseConnection(connection_noDB) // release the connection back to the pool
  }
} catch {
  print("Unable to create connection")
  exit(0)
}

// create a new client using the leased connection
var client = MySQLClient(connection: connection_noDB)

print("MySQL Client Info: " + client.info()!)
print("MySQL Client Version: " + String(client.version()))

client.execute("DROP DATABASE IF EXISTS testdb")
client.execute("CREATE DATABASE testdb")

var connection_withDB: MySQLConnectionProtocol

do {
  // get a connection from the pool connecting to a specific database
  connection_withDB = try MySQLConnectionPool.getConnection("192.168.64.3", user: "root", password: "my-secret-pw", database: "testdb")!
  defer {
    MySQLConnectionPool.releaseConnection(connection_withDB)
  }
} catch {
  print("Unable to create connection")
  exit(0)
}

client = MySQLClient(connection: connection_withDB)

client.execute("DROP TABLE IF EXISTS Cars")
client.execute("CREATE TABLE Cars(Id INT, Name TEXT, Price INT)")

// use query builder to insert data
var queryBuilder = MySQLQueryBuilder()
  .insert(["Id": "1", "Name": "Audi", "Price": "52642"], table: "Cars")
client.execute(queryBuilder)

queryBuilder = MySQLQueryBuilder()
  .insert(["Id": "2", "Name": "Mercedes", "Price": "72341"], table: "Cars")
client.execute(queryBuilder)

// create query to select data from the database
queryBuilder = MySQLQueryBuilder()
  .select(["Id", "Name", "Price"], table: "Cars")

var ret = client.execute(queryBuilder) // returns a tuple (MySQLResult, MySQLError)
if let result = ret.0 {
  var r = result.nextResult() // get the first result from the result set
  if r != nil {
    repeat {
      for value in r! {
        print(value)
      }
      r = result.nextResult() // get the next result from the result set
    } while(r != nil) // loop while there are results
  } else {
    print("No results")
  }
}
