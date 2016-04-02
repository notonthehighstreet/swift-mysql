import Foundation
import CMySQLClient

print("running")
let mysql = MySQL()
var data = mysql.client_info()

print("MySQL Client Info: " + data!)
