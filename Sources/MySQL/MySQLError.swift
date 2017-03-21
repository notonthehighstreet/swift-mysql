public enum MySQLError: Error {
  case UnableToCreateConnection
  case UnableToExecuteQuery(message: String)
  case ConnectionPoolTimeout
  case NoMoreResults
}
