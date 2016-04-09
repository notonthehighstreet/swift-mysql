import Foundation
import MySQL

print("Running test client")

MySQLConnectionPool.setConnectionProvider() {
  return MySQL.MySQLConnection()
}

var connection_noDB: MySQLConnectionProtocol

do {
  connection_noDB = try MySQLConnectionPool.getConnection("192.168.64.2", user: "root", password: "my-secret-pw")!
} catch {
  print("Unable to create connection")
  exit(0)
}

var client = MySQLClient(connection: connection_noDB)

defer {
  connection_noDB.close()
}

print("MySQL Client Info: " + client.info()!)
print("MySQL Client Version: " + String(client.version()))

client.execute("DROP DATABASE IF EXISTS testdb")
client.execute("CREATE DATABASE testdb")

var connection_withDB: MySQLConnectionProtocol

do {
  connection_withDB = try MySQLConnectionPool.getConnection("192.168.64.2", user: "root", password: "my-secret-pw", database: "testdb")!
} catch {
  print("Unable to create connection")
  exit(0)
}

client = MySQLClient(connection: connection_withDB)
defer {
  connection_withDB.close()
}

client.execute("DROP TABLE IF EXISTS Cars")
client.execute("CREATE TABLE Cars(Id INT, Name TEXT, Price INT)")
client.execute("INSERT INTO Cars VALUES(1,'Audi',52642)")
client.execute("INSERT INTO Cars VALUES(2,'Mercedes',57127)")

var ret = client.execute("SELECT * FROM Cars")
if let result = ret.0 {
  var r = result.nextResult()
  if r != nil {
    repeat {
      for value in r! {
        print(value)
      }
      r = result.nextResult()
    } while(r != nil)
  } else {
    print("No results")
  }
}
