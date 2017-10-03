import Foundation

/**
    MySQLConnectionPool manages connections to a MySQL database.

    ```
    let connectionString = MySQLConnectionString(host: "127.0.0.1")
    let pool = MySQLConnectionPool(connectionString: connectionString,
                                   poolSize: 10,
                                   defaultCharset: "utf8")

    pool.getConnection() {
        (connection: MySQLConnectionProtocol) in
        // use connection
    }

    // connection is returned to the pool
    ```
 */
public class MySQLConnectionPool: MySQLConnectionPoolProtocol {

    var connectionString: MySQLConnectionString
    var activeConnections = [String: [MySQLConnectionProtocol]]()
    var inactiveConnections = [String: [MySQLConnectionProtocol]]()
    var poolSize: Int = 20
    var poolTimeout: Double = 20.0 // 20s
    var defaultCharset: String = "utf8"
    var lock = NSLock()

    var connectionProvider:() -> MySQLInternalConnectionProtocol? = { 
        () -> MySQLInternalConnectionProtocol? in
            return nil
    }

    var logger:(_: MySQLConnectionPoolMessage) -> Void = {
        (message: MySQLConnectionPoolMessage) -> Void in
    }

    /**
        Create a new connection pool

        - Parameters: 
            - connectionString:
            - poolSize: maximum number of open connections in the pool
            - defaultCharset: default character set to use when connecting
                to the database
    */    
    public required init(connectionString: MySQLConnectionString,
                         poolSize: Int,
                         defaultCharset: String) {

        self.connectionString = connectionString
        self.poolSize = poolSize
        self.defaultCharset = defaultCharset
    
        self.connectionProvider = {
            return MySQLInternalConnection()
        }
    }
  
    func setConnectionProvider(provider: @escaping () -> MySQLInternalConnectionProtocol?) {
        self.connectionProvider = provider
    }

    func createAndAddActive() throws -> MySQLConnectionProtocol? {
        let internalConnection = connectionProvider()

        do {
            try internalConnection!.connect(host: self.connectionString.host,
                                    user: self.connectionString.user,
                                    password: self.connectionString.password,
                                    port: self.connectionString.port,
                                    database: self.connectionString.database,
                                    charset: self.defaultCharset)
        } catch {
            logger(_: MySQLConnectionPoolMessage.FailedToCreateConnection)
            throw error
        }

        let connection = MySQLConnection(connection: internalConnection!)

        let key = self.connectionString.key()
        addActive(key: key, connection: connection)
        logger(_: MySQLConnectionPoolMessage.CreatedNewConnection)

        return connection
    }

    func findActiveConnection(connection: MySQLConnectionProtocol) -> (key: String?, index: Int?) {
        var connectionKey: String? = nil
        var connectionIndex: Int? = nil

        for (key, value)  in activeConnections {
            if let index = value.index(where:{$0.equals(otherObject: connection)}) {
                connectionIndex = index
                connectionKey = key
            }
        }

        return (connectionKey, connectionIndex)
    }

    func addActive(key: String, connection: MySQLConnectionProtocol) {
        if activeConnections[key] == nil {
            activeConnections[key] = [MySQLConnectionProtocol]()
        }

        activeConnections[key]!.append(connection)
    }

    func addInactive(key: String, connection: MySQLConnectionProtocol) {
        if inactiveConnections[key] == nil {
            inactiveConnections[key] = [MySQLConnectionProtocol]()
        }

        inactiveConnections[key]!.append(connection)
    }

    func getInactive(key: String) -> MySQLConnectionProtocol? {
        if inactiveConnections[key] != nil && inactiveConnections[key]!.count > 0 {
            // pop a connection off the stack
            let connection = inactiveConnections[key]![0]
            inactiveConnections[key]!.remove(at: 0)

            if connection.isConnected() {
                logger(_: MySQLConnectionPoolMessage.RetrievedConnectionFromPool)
                return connection
            } else {
                logger(_: MySQLConnectionPoolMessage.ConnectionDisconnected)
                return nil
            }
        }

        return nil
    }

    func countActive() -> Int {
        lock.lock()
        defer {
            lock.unlock()
        }

        var c = 0
        for (_, value) in activeConnections {
            c += value.count
        }
        return c
    }
}  

extension MySQLConnectionPool {
    /**
        setLogger allows a call back function to be set, the pool will call
        this function after completing an operation such as creating a new
        connection.  It can be used to send metrics to StatsD or log to StdOut.
     */
    public func setLogger(logger: @escaping (_: MySQLConnectionPoolMessage) -> Void) {
        self.logger = logger
    }


    /**
        getConnection returns a connection from the pool, if a connection is 
        unsuccessful then getConnection throws a MySQLError, if the pool has no 
        available connections getConnection will block util either a connection is 
        free or a timeout occurs.

        - Returns: An object conforming to the MySQLClientProtocol which can be 
            used to make requests to the database.

        ```
        do {
            let connection = try pool.getConnection()
            defer { pool.releaseConnection(connection: connection) }

            // do some work
        } catch {
            // unable to get connection
        }
    */
    public func getConnection() throws -> MySQLConnectionProtocol? {
        var startTime = NSDate()

        while(countActive() >= poolSize) {
            if (NSDate().timeIntervalSince1970 - startTime.timeIntervalSince1970) > poolTimeout {
                throw MySQLError.ConnectionPoolTimeout
            }
        }

        lock.lock()
        defer {
            lock.unlock()
        }

        // check if there is something available in the pool if so return it
        let key = connectionString.key()

        if let connection = getInactive(key: key) {
            addActive(key: key, connection: connection)      
            return connection
        } 
    
        return try createAndAddActive()
    }

    /**
        getConnection returns a connection from the pool, if a connection is 
        unsuccessful then getConnection throws a MySQLError, if the pool has no 
        available connections getConnection will block util either a connection is 
        free or a timeout occurs.

        By passing the optional closure once the code has executed within the block 
        the connection is automatically released back to the pool saving the 
        requirement to manually call releaseConnection.

        - Parameters:
          - closure: Code that will be executed before connection is released back to the pool

        - Returns: An object implementing the MySQLConnectionProtocol.

        ```
        try pool.getConnection() {
            (connection: MySQLConnectionProtocol) in
                let result = connection.execute("SELECT * FROM TABLE")
                ...
        }
        ```
     */
    public func getConnection(closure: ((_: MySQLConnectionProtocol) throws -> Void)) throws {
        do {
            if let connection = try getConnection() {
                defer { self.releaseConnection(connection) }

                try closure(_: connection)
            }
        } catch {
            logger(_: MySQLConnectionPoolMessage.FailedToCreateConnection)
            throw error
        }
    }

    /**
        releaseConnection returns a connection to the pool.

        - Parameters:
            - connection: Connection to be returned to the pool
    */
    public func releaseConnection(_ connection: MySQLConnectionProtocol) {
        lock.lock()
        defer {
            lock.unlock()
        }

        let connectionIndex = findActiveConnection(connection: connection)

        if let key = connectionIndex.0, let index = connectionIndex.1 {
            activeConnections[key]!.remove(at: index)
            addInactive(key: key, connection: connection)
        }
    }
}
