import Foundation

public func ==(lhs: MySQLQueryBuilder, rhs: MySQLQueryBuilder) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

public class MySQLQueryBuilder: Equatable {

  var insertData:MySQLRow?

  public func select() -> MySQLQueryBuilder {
    return self
  }

  public func insert(data: MySQLRow) -> MySQLQueryBuilder {
    insertData = data
    return self
  }

  public func update(data: MySQLRow) -> MySQLQueryBuilder {
    return self
  }

  public func wheres() -> MySQLQueryBuilder {
    return self
  }

  public func build() -> String {
    let insertPart = createInsertStatement(insertData!)

    return insertPart
  }

  private func createInsertStatement(data: MySQLRow) -> String {
    var statement = "INSERT INTO ("

    for (key, _) in data {
      statement += "'\(key)',"
    }
    statement = trimComma(statement)

    statement += ") VALUES ("

    for (_, value) in data {
      statement += "'\(value)',"
    }
    statement = trimComma(statement)

    statement += ")"

    return statement
  }

  internal func trimComma(statement: String) -> String {
    if statement[statement.endIndex.predecessor()] == "," {
      var chars = Array(statement.characters)
      chars.removeLast()
      return String(chars)
    } else {
      return statement
    }
  }
}
