import Foundation

public func ==(lhs: MySQLQueryBuilder, rhs: MySQLQueryBuilder) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

public class MySQLQueryBuilder: Equatable {
  var selectStatement: String?
  var insertStatement:String?

  /**
    select sets the select statement part of the query

    - Parameters:
      - statement: select statement

    ```
      var builder = MySQLQueryBuilder().select("SELECT 'abc', 'cde' FROM myTable")
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

    ```
      var builder = MySQLQueryBuilder().select(["abc", "cde"], table: "myTable")
    ```
  */
  public func select(fields: [String], table: String) -> MySQLQueryBuilder {
    selectStatement = createSelectStatement(fields, table: table)
    return self
  }

  public func insert(data: MySQLRow) -> MySQLQueryBuilder {
    insertStatement = createInsertStatement(data)
    return self
  }

  public func update(data: MySQLRow) -> MySQLQueryBuilder {
    return self
  }

  public func wheres(statement: String, parameters: String...) -> MySQLQueryBuilder {
    return self
  }

  public func build() -> String {
    var query = ""

    if selectStatement != nil {
      query += selectStatement!
    }

    if insertStatement != nil {
      query += insertStatement!
    }

    return query
  }

  private func createSelectStatement(fields: [String], table: String) -> String {
    var statement = "SELECT "

    for field in fields {
      statement += "\(field), "
    }
    statement = statement.trimChar(" ")
    statement = statement.trimChar(",")
    statement += " FROM \(table)"

    return statement
  }

  private func createInsertStatement(data: MySQLRow) -> String {
    var statement = "INSERT INTO ("

    for (key, _) in data {
      statement += "'\(key)',"
    }
    statement = statement.trimChar(",")

    statement += ") VALUES ("

    for (_, value) in data {
      statement += "'\(value)',"
    }
    statement = statement.trimChar(",")

    statement += ")"

    return statement
  }
}

extension String {
  public func trimChar(character: Character) -> String {
    if self[self.endIndex.predecessor()] == character {
      var chars = Array(self.characters)
      chars.removeLast()
      return String(chars)
    } else {
      return self
    }
  }
}
