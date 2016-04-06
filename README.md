# swift-mysql
MySQL client implementation for swift

# Build instructions for Mac
## Build for Mac
### Install Swiftenv
https://github.com/kylef/swiftenv

### Install 3.0 Alpha
```
$ swiftenv install DEVELOPMENT-SNAPSHOT-2016-03-24-a
$ swiftenv rehash
```

### Install C dependencies
```
$ brew install mysql // for the client, needed to build the mysql module
```

# Build instructions using Docker
## Run the docker container for building
```
$ docker run -i -t -p 8090:8090 -v $(pwd):/src --name swifty -w /src ibmcom/kitura-ubuntu:latest /bin/bash  
$ cd /root  
$ curl https://swift.org/builds/development/ubuntu1510/swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a/swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a-ubuntu15.10.tar.gz -o swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a-ubuntu15.10.tar.gz  
$ tar -xf swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a-ubuntu15.10.tar.gz  
$ export PATH=/root/swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a-ubuntu15.10/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
$ apt-get install libmysqlclient-dev
```

## Build and run tests
```
$ make test
```

## Usage
Set the connection provider for the connection pool, this closure should return a new instance as internally the connection pool manages the connections.
```swift
MySQLConnectionPool.setConnectionProvider() {
  return MySQL.MySQLConnection()
}
```

To get a connection from the pool call get connection with the parameters for your connection, at present pooling is on the todo list and this call will return a new connection and attempt to connect to the database with the given details.  When a connection fails a MySQLError will be thrown.
```swift
do {
  connection = try MySQLConnectionPool.getConnection("192.168.99.100", user: "root", password: "my-secret-pw", database: "")!
} catch {
  print("Unable to create connection")
  exit(0)
}
```

To create a new client pass the reference to the connection obtained from the pool, at present you need to call connection.close once done with the connection, this will be managed automatically in a later releases.
```swift
var client = MySQLClient(connection: connection)

defer {
  connection.close()
}
```

To execute a query
```swift
var result = client.execute("SELECT * FROM Cars")

// result.1 contains an error, when present the query has failed.
if result.1 != nil {

  // if MySQLResult is nil then no rows have been returned from the query.
  if let mysqlResult = ret.0 {
    var r = result.nextResult() // get the first result from the set
    if r != nil {
      repeat {
        for value in r! {
          print(value) // print the returned dictionary ("Name", "Audi"), ("Price", "52642"), ("Id", "1")
        }
        r = result.nextResult() // get the next result in the set, returns nil when no more records are available.
      } while(r != nil)
  }
}

if let result = ret.0 {

  } else {
    print("No results")
  }
}
```

## Example
Please see the example program in /Sources/Example for further usage.


## Run MySQL in docker
docker run --rm -e MYSQL_ROOT_PASSWORD=my-secret-pw -p 3306:3306 mysql:latest

## Roadmap:
- Complete implementation of the connection pool.
- Complete implementation for the MySQLField to give parity to C library.
- Implement type casting for MySQLRow to match field type.
- Implement binary streaming for blob types.
