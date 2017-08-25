import Foundation

public func ==(lhs: MySQLQueryBuilder, rhs: MySQLQueryBuilder) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

public enum Joins {
    case LeftJoin
    case RightJoin
    case InnerJoin
}

internal struct MySQLJoin {
    let from: String
    let to: String
    let builder: MySQLQueryBuilder
    let type: Joins

    init(builder: MySQLQueryBuilder, from: String, to: String, type: Joins) {
        self.builder = builder
        self.from = from
        self.to = to
        self.type = type
    }
}

public class MySQLQueryBuilder: Equatable {
  var selectStatement: String?
  var insertStatement: String?
  var updateStatement: String?
  var deleteStatement: String?
  var whereStatement: String?
  var upsertStatement: String?

  var joinedStatements = [MySQLJoin]()

  var fields: [String]?
  var tableName: String?

  public init() {}

  /**
    select sets the select statement part of the query

    - Parameters:
      - statement: select statement

    - Returns: returns self

    ```
      var builder = MySQLQueryBuilder()
        .select("SELECT 'abc', 'cde' FROM myTable")
    ```
  */
  public func select(statement: String) -> MySQLQueryBuilder {
    selectStatement = statement
    return self
  }

  /**
    select sets the select statement part of the query

    - Parameters:
      - fields: array of fields to return
      - table: name of the table to select from

    - Returns: returns self

    ```
      var builder = MySQLQueryBuilder()
        .select(["abc", "cde"], table: "myTable")
    ```
  */
  public func select(fields: [String], table: String) -> MySQLQueryBuilder {
    self.fields = fields
    self.tableName = table
    
    return self
  }

  /**
    insert sets the insert statement part of the query

    - Parameters:
      - data: dictionary containing the data to be inserted
      - table: table to insert data into

    - Returns: returns self

    ```
      var builder = MySQLQueryBuilder()
        .insert(["abc": "cde"], table: "myTable")
    ```
  */
  public func insert(data: MySQLRow, table: String) -> MySQLQueryBuilder {
    insertStatement = createInsertStatement(data: data, table: table)
    return self
  }

  /**
    update sets the update statement part of the query

    - Parameters:
      - data: dictionary containing the data to be inserted
      - table: table to insert data into

    - Returns: returns self

    ```
      var builder = MySQLQueryBuilder()
        .update(["abc": "cde"], table: "myTable")
    ```
  */
  public func update(data: MySQLRow, table: String) -> MySQLQueryBuilder {
    updateStatement = createUpdateStatement(data: data, table: table)

    return self
  }
    
  /**
    upsert updates a record if it exists and inserts a new one if it does not
    exist

    - Parameters:
      - data: dictionary containing the data to be inserted
      - table: table to insert data into

    - Returns: returns self

    ```
      var builder = MySQLQueryBuilder()
        .upsert(["abc": "cde"], table: "myTable")
    ```
  */
  public func upsert(data: MySQLRow, table: String) -> MySQLQueryBuilder {
    upsertStatement = createUpsertStatement(data: data, table: table)

    return self
  }

  /**
    delete sets the delete statement part of the query

    - Parameters:
      - recordFromTable: table to remove record from

    - Returns: returns self

    ```
      var builder = MySQLQueryBuilder()
        .delete(recordFromTable: "myTable")
    ```
  */
  public func delete(fromTable table: String) -> MySQLQueryBuilder {
    deleteStatement = createDeleteStatement(withTable: table)

    return self
  }

  /**
    wheres sets the where statement part of the query, escapting the parameters
    to secure against SQL injection

    - Parameters:
      - statement: where clause to filter data by
      - parameters: list of parameters corresponding to the statement

    - Returns: returns self

    ```
      var builder = MySQLQueryBuilder()
        .select("SELECT * FROM MyTABLE")
        .wheres("WHERE abc = ? and bcd = ?", abcValue, bcdValue)
    ```
  */
    public func wheres(statement: String, parameters: String...) -> MySQLQueryBuilder {
        var tempStatement = statement
        // prepend the table name
        if let fields = self.fields, let tableName = self.tableName {
            for field in fields {
                tempStatement = tempStatement.replacingOccurrences(of: field, with: "\(tableName).\(field)")
            }
        }

        // replace the parameters
        var i = 0
        var w = ""

        for char in tempStatement.characters {
            if char == "?" {
                w += "'\(parameters[i])'"
                i += 1
            } else {
                w += String(char)
            }
        }

        whereStatement = " WHERE " + w
        return self
  }

  /**
    join concatenates the output of one or more MySQLQueryBuilders to create a multi statement query

    - Parameters:
      - builder: MySQLQueryBuilder whos output which will be concatenated to this one

    - Returns: returns self

    ```
    var builder = MySQLQueryBuilder()
      .insert(["abc": "cde"], table: "myTable")

    var builder2 = MySQLQueryBuilder()
      .insert(["def": "ghi"], table: "myTable")

    let query = builder.join(builder2).build()
    // query: INSERT INTO myTable (abc) VALUES ('cde'); INSERT INTO myTable SET def='ghi';
    ```
  */
  public func join(builder: MySQLQueryBuilder, from: String, to: String, type: Joins) -> MySQLQueryBuilder {
    joinedStatements.append(MySQLJoin(builder: builder, from: from, to: to, type: type))

    return self
  }

  /**
    build compiles all data and returns the SQL statement for execution

    - Returns: SQL Statement
  */
  public func build() -> String {
    var query = ""

    if let selectStatement = selectStatement {
      query += selectStatement
    }

    // build any statements with joins
    if let _ = self.fields, let _ = self.tableName {
        query += createSelectStatement(fields: self.fields, table: self.tableName, joins: self.joinedStatements)
    }

    if let insertStatement = insertStatement {
      query += insertStatement
    }

    if let updateStatement = updateStatement {
      query += updateStatement
    }
    
    if let upsertStatement = upsertStatement {
      query += upsertStatement
    }

    if let deleteStatement = deleteStatement {
      query += deleteStatement
    }

    if let whereStatement = whereStatement {
      query += whereStatement
    }

    return query + ";"
  }

    private func createSelectStatement(fields: [String]?, table: String?, joins: [MySQLJoin]?) -> String {
        guard let fields = fields, let table = table, let joins = joins else {
            return ""
        }

        var statement = "SELECT "

        for field in fields {
            statement += "\(table).\(field), "
        }

        for join in joins {
            for field in join.builder.fields! {
                statement += "\(join.builder.tableName!).\(field), "
            }
        }
        
        statement = statement.trimChar(character: " ")
        statement = statement.trimChar(character: ",")
        statement += " FROM \(table)"
        
        for join in joins {
            switch join.type {
            case .LeftJoin:
                statement += " LEFT JOIN \(join.builder.tableName!) ON "
            case .RightJoin:
                statement += " RIGHT JOIN \(join.builder.tableName!) ON "
            case .InnerJoin:
                statement += " INNER JOIN \(join.builder.tableName!) ON "
            }

            statement += "\(table).\(join.from) = \(join.builder.tableName!).\(join.to)"
        }
        
        statement = statement.trimChar(character: " ")
        statement = statement.trimChar(character: ",")

        return statement
    }

  private func createInsertStatement(data: MySQLRow, table: String) -> String {
    var statement = "INSERT INTO \(table) ("

    for (key, _) in data {
      statement += "\(key), "
    }
    statement = statement.trimChar(character: " ")
    statement = statement.trimChar(character: ",")

    statement += ") VALUES ("

    for (_, value) in data {
      statement += "'\(value)', "
    }
    statement = statement.trimChar(character: " ")
    statement = statement.trimChar(character: ",")

    statement += ")"

    return statement
  }

  private func createUpsertStatement(data: MySQLRow, table: String) -> String {
    let update = createInsertStatement(data: data, table: table)
    
    var statement = " ON DUPLICATE KEY UPDATE "
    for (key, value) in data {
      statement += "\(key) = '\(value)', "
    }

    statement = statement.trimChar(character: " ")
    statement = statement.trimChar(character: ",")

    return update + statement
  }

  private func createUpdateStatement(data: MySQLRow, table: String) -> String {
    var statement = "UPDATE \(table) SET "

    for (key, value) in data {
      statement += "\(key)='\(value)', "
    }
    statement = statement.trimChar(character: " ")
    statement = statement.trimChar(character: ",")

    return statement
  }

  private func createDeleteStatement(withTable table: String) -> String {
    return "DELETE FROM \(table)"    
  }
}

extension String {
  public func trimChar(character: Character) -> String {
    if self[self.index(before:self.endIndex)] == character {
      var chars = Array(self.characters)
      chars.removeLast()
      return String(chars)
    } else {
      return self
    }
  }
}
