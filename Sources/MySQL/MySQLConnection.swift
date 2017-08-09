import Foundation

/** 
    MySQLClient allows execution of queries and the return of results from MySQL databases this class
    is never directly created.  A connection pool should be used to create and manage connections.
*/
public class MySQLConnection: MySQLConnectionProtocol{
    internal var uuid: Double
    internal let connection: MySQLInternalConnectionProtocol

     /**
       Initialises a new MySQLClient with the provided connection.

       - Parameters:
         - connection: A valid connection object which implements the MySQLConnectionProtocol

       - Returns: A MySQLClient which can be used to query the database.

     */
    internal init(connection: MySQLInternalConnectionProtocol) {
        uuid = NSDate().timeIntervalSince1970

        self.connection = connection
    }
}

// MARK: MySQLClientProtocol implementation
extension MySQLConnection {
    public func equals(otherObject: MySQLConnectionProtocol) -> Bool {
        return uuid == (otherObject as! MySQLConnection).uuid
    }

     /**
       Retrieve information for the underlying client library version.

       - Returns: String representing the current client version.
     */
    public func info() -> String? {
        return connection.client_info()
    }

    /**
        Retrieve the version for the underlying client library version.

        - Returns: UInt representing the current client version.
    */
    public func version() -> UInt {
        return connection.client_version()
    }

    /**
        Check if the current connection is currently connected.

        - Returns: Bool, where true is connected.
    */
    public func isConnected() -> Bool {
        return connection.isConnected()
    }

    /**
        Execute the given SQL query against the database, preferably the method 
        execute(builder: MySQLQueryBuilder) should be used as this method
        does not protect against SQL injection.

        - Parameters:
            - query: valid TSQL statement to execute.

        - Returns: MySQLResultProtocol. If the query fails then a MySQLError is 
            thrown.  It possible for no results to be returned as some queries do 
            not return results.
    */
    public func execute(query: String) throws -> MySQLResultProtocol {
        let result = try connection.execute(query: query)

        guard let mysqlResult = result.1, let mysqlFields = result.2 else {
            return MySQLResult(rows: result.0, 
                           result: nil, 
                           fields: nil, 
                           nextResult: connection.nextResult)

        }
    
        return MySQLResult(rows: result.0, 
                           result: mysqlResult, 
                           fields: mysqlFields, 
                           nextResult: connection.nextResult)
    }

    /**
        Execute the given SQL query against the database.

        - Parameters:
            - builder: MySQLQueryBuilder

        - Returns: MySQLResultProtocol. If the query fails then a MySQLError is 
            thrown.  It possible for no results to be returned as some queries do 
            not return results.

        ```
        var builder = MySQLQueryBuilder()
            .select(["abc"], table: "MyTable")
            .wheres("WHERE abc=?", "1")

        var (result, error) = mySQLClient.execute(builder)
        ```
    */
    public func execute(builder: MySQLQueryBuilder) throws -> MySQLResultProtocol {
        let statement = builder.build()
    
        return try execute(query: statement)
    }

  /**
    Return the next result set after executing a query, this isused when you
    specify a multi statement query.

    - Returns: MySQLResultProtocol. If the query fails then a MySQLError object will 
        be thrown. Even on a successful query it is still possible for no results 
        to be returned as some queries do not return results.

        ```
        var table1Builder = MySQLQueryBuilder()
            .select(["abc"], table: "MyTable")
            .wheres("WHERE abc=?", "1")

        var table2Builder = = MySQLQueryBuilder()
            .select(["abc"], table: "MyOtherTable")
            .wheres("WHERE abc=?", "1")

        table1Builder.join(table2Builder)

        do {
            var result = try mySQLClient.execute(table1Builder)
            var row = result.nextResult() // use rows from table1

            result = mySQLClient.nextResult()
            row = result.nextResult() // use rows from table2
        }
        ```
    */
    public func nextResultSet() throws -> MySQLResultProtocol {
        let result = try connection.nextResultSet()

        guard let mysqlResult = result.1, let mysqlFields = result.2 else {
            return MySQLResult(rows: result.0, 
                           result: nil, 
                           fields: nil, 
                           nextResult: connection.nextResult)
        }
      
        return MySQLResult(rows: result.0,
                           result:mysqlResult, 
                           fields: mysqlFields, 
                           nextResult: connection.nextResult)
    }
}
