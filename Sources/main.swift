import Foundation
import CMySQLClient

print("running")
let mysql = MySQL()
var data = mysql.client_info()

print("MySQL Client Info: " + data!)
print("MySQL Client Version: " + String(mysql.client_version()))

mysql.connect()

mysql.execute("DROP DATABASE IF EXISTS testdb")
mysql.execute("CREATE DATABASE testdb")
mysql.execute("USE testdb")
mysql.execute("DROP TABLE IF EXISTS Cars")
mysql.execute("CREATE TABLE Cars(Id INT, Name TEXT, Price INT)")
mysql.execute("INSERT INTO Cars VALUES(1,'Audi',52642)")
mysql.execute("INSERT INTO Cars VALUES(2,'Mercedes',57127)")
mysql.execute("SELECT * FROM Cars")

mysql.close()
