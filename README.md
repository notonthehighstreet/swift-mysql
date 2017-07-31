# swift-mysql
swift-mysql is a MySQL client implementation for Swift 3, it wraps the libmysql library and provides many convenience functions such as connection pooling and result sets as native types.

## API Documentation:
**[Docs](http://htmlpreview.github.io/?https://github.com/nicholasjackson/swift-mysql/blob/master/docs/index.html)**

## Build instructions for Mac

### Install C dependencies
```
$ brew install mysql // for the client, needed to build the mysql module
```

### Build and run tests
```
$ make test_unit
$ MYSQL_SERVER=[DOCKER HOST IP] make test_integration
```

## Build instructions using Docker
### Run the docker container for building
```
$ docker run -i -t -v $(pwd):/src --name swiftmysql -w /src ibmcom/kitura-ubuntu:latest /bin/bash  
$ apt-get install libmysqlclient-dev
```

### Build and run tests
```
$ make test
```

### Usage
Set the connection provider for the connection pool, this closure should return a new instance as internally the connection pool manages the connections.
```swift
let connectionString = MySQLConnectionString(host: "127.0.0.1")
connectionString!.port = 3306
connectionString!.user = "root"
connectionString!.password = "my-secret-pw"
connectionString!.database = ""


var pool = MySQLConnectionPool(connectionString: connectionString, poolSize:10) {
  return MySQL.MySQLConnection()
}

```

To get a connection from the pool call get connection with the parameters for your connection, at present pooling is on the todo list and this call will return a new connection and attempt to connect to the database with the given details.  When a connection fails a MySQLError will be thrown.
```swift
do {
  let connection = try pool.getConnection()!
  
  // release the connection back to the pool
  defer {
    pool.releaseConnection(connection) 
  }

  // do some work
} catch {
  print("Unable to create connection")
}
```

As an alternative approach to manually calling release connection you can use the getConnection method which takes a closure.  Once the code inside the closure has executed then the connection is automatically released back to the pool.
```swift
do {
  let connection = try pool.getConnection() {
    (connection: MySQLConnectionProtocol) in
      let client = MySQLClient(connection: connection)
      let result = client.execute("SELECT * FROM MYTABLE")
      ...
  }
} catch {
  print("Unable to create connection")
  exit(0)
}
```

To read from the result set:

To execute a query
```swift
var result = client.execute("SELECT * FROM Cars")

// result.1 contains an error, when present the query has failed.
// if MySQLResult is nil then no rows have been returned from the query.
  if let resultSet = ret.0 {
    while case let row? = resultSet.nextResult() {
      // do something with result dictionary, row["Id"] etc
    }
  }
}
```

## QueryBuilder
When executing queries you can use the MySQLQueryBuilder class to generate a safe query for you.  This will ensure that all parameters are escaped to avoid SQL injection attacks.

### Simple select
```swift
var queryBuilder = MySQLQueryBuilder()
  .select(["Id", "Name"], table: "MyTable")

var result = client.execute(queryBuilder)
```

### Parametrised where clause
```swift
var queryBuilder = MySQLQueryBuilder()
  .select(["Id", "Name"], table: "MyTable")
  .wheres("WHERE Id=?", 2)

var result = client.execute(queryBuilder)
```

## Run MySQL in docker
docker run --rm -e MYSQL_ROOT_PASSWORD=my-secret-pw -p 3306:3306 mysql:latest

## Roadmap:
- ~~Complete implementation of the connection pool.~~
- ~~Complete implementation for the MySQLField to give parity to C library.~~
- Implement type casting for MySQLRow to match field type. - Complete for numbers and strings, 
- Implement binary streaming for blob types.
