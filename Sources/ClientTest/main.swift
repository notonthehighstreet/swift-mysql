import Foundation
import MySQL

print("Running test client")

MySQLConnectionPool.setConnectionProvider() {
  return MySQL.MySQLConnection()
}

var connection: MySQLConnectionProtocol

do {
  connection = try MySQLConnectionPool.getConnection("192.168.99.100", user: "root", password: "my-secret-pw", database: "")!
} catch {
  print("Unable to create connection")
  exit(0)
}

var client = MySQLClient(connection: connection)

defer {
  connection.close()
}

print("MySQL Client Info: " + client.info()!)
print("MySQL Client Version: " + String(client.version()))

client.execute("DROP DATABASE IF EXISTS testdb")
client.execute("CREATE DATABASE testdb")
client.execute("USE testdb")
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
