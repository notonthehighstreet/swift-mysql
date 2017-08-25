# swift-mysql

![Swift 3.1](https://img.shields.io/badge/Swift-3.1-orange.svg)
[![Swift Package Manager compatible](https://img.shields.io/badge/SwiftPM-compatible-orange.svg)](https://github.com/apple/swift-package-manager)
[![Documentation](https://img.shields.io/badge/Docs-click%20here-orange.svg)](http://htmlpreview.github.io/?https://github.com/nicholasjackson/swift-mysql/blob/master/docs/index.html)

A MySQL client for Swift. It wraps the `libmysql` C library and provides many convenience functions such as connection pooling and result sets as native types.

## Installation

Add `swift-mysql` to your `Package.swift` file:

```swift
import PackageDescription

let package = Package(
    // ...
    dependencies: [        
        .Package(url: "https://github.com/nicholasjackson/swift-mysql.git", majorVersion: 1)
    ]
)
```

## Usage

To interact with a database, you'll want a connection pool.

```swift
import MySQL

// Create connection string to your database server
var connectionString = MySQLConnectionString(host: "127.0.0.1")
connectionString!.port = 3306
connectionString!.user = "root"
connectionString!.password = "my-secret-pw"
connectionString!.database = ""

// Create a connection pool to manage the database connections.
var pool = MySQLConnectionPool(connectionString: connectionString, poolSize: 10)
```

> **Note**: To easily run your own MySQL database server, we recommend using Docker. The following Docker command starts a container running a MySQL server: `docker run --rm -e MYSQL_ROOT_PASSWORD=my-secret-pw -p 3306:3306 mysql:latest`. For more details, read the [documentation for the mysql Docker image](https://hub.docker.com/_/mysql/).

A connection pool provides connections for querying the database. There are two ways to get a connection:

```swift
// 1. the closure way...
do {
    try pool.getConnection() { (connection: MySQLConnectionProtocol) in            
        // make queries...
    }
} catch {
    print(error.localizedDescription)
}

// 2. the imperative way...
func executeQuery() throws -> MySQLResultProtocol {    
    let connection = try pool.getConnection()

    // manually release the connection when you're done (function exists)
    defer { pool.releaseConnection(connection!) }

    // make queries...
}
```

With a connection, you can make queries manually (susceptible to SQL injection attacks):

```swift
// select
let selectResults = try connection.execute(query: "SELECT * FROM Cars")
while case let row? = selectResults.nextResult() {
    // do something with results dictionary (ex. row["Id"])    
}

// insert
let insertResults = try connection.execute(query: "INSERT INTO Cars (Id, Name, Price, UpdatedAt) VALUES ('1', 'Audi', '52642', '2017-07-24 20:43:51';")
if insertResults.affectedRows > 0 {
    // Car was inserted...
}
```

Or, you can make safe queries using `MySQLQueryBuilder` to ensure that all query parameters are escaped, avoiding SQL injection attacks.

```swift
// select
let select = MySQLQueryBuilder().select(["Id", "Name"], table: "Cars")
let selectResults = try connection.execute(builder: select)

// select (parametrized where clause)
let selectWithID = MySQLQueryBuilder().select(["Id", "Name"], table: "MyTable")
                                      .wheres(statement: "Id=?", parameters: 2)
let selectWithIDResults = connection.execute(builder: selectWithID)

// query builder also supports inserts, updates, deletes, and joins (see documentation)
```

## How to Build Your Project

Before you build projects with this package, you must install the `libmysql` C library:

**For Mac**

```bash
# install libmysql C dependencies
$ brew install mysql
```

**For Linux (using Docker)**

```bash
# run a docker container for building Swift projects
$ docker run -i -t -v $(pwd):/src --name swiftmysql -w /src ibmcom/kitura-ubuntu:latest /bin/bash

# install libmysql C dependencies
$ apt-get install libmysqlclient-dev
```

Then, link to the dependencies when compiling your Swift project. This should work on either Mac or Linux.

```bash
# "/usr/local/lib" is a standard location for libmysql C dependencies
$ swift build -Xlinker -L/usr/local/lib
```

## How to Contribute

Make a PR. For any changes you make, write tests!

```bash
# build and run unit tests
$ make test_unit

# run integration tests
$ MYSQL_SERVER=[DOCKER HOST IP] make test_integration

# run all tests
$ make test
```

## Roadmap

- ~~Complete implementation of the connection pool.~~
- ~~Complete implementation for the MySQLField to give parity to C library.~~
- Implement type casting for MySQLRow to match field type. - Complete for numbers and strings,
- Implement binary streaming for blob types.
