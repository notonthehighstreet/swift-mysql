import Foundation
import MySQL

print("Running test client")

let connection = MySQL.MySQLConnection(host: "192.168.99.100", user: "root", password: "my-secret-pw", database: "")
var client: MySQLClient
do {
  client = try MySQLClient(connection: connection)
} catch {
  print("Unable to create connection")
  exit(0)
}

defer {
  client.close()
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
client.execute("SELECT * FROM Cars")
