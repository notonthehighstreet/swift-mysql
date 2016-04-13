public enum MySQLError: ErrorProtocol {
  case UnableToCreateConnection
  case UnableToExecuteQuery(message: String)
  case ConnectionPoolTimeout
}
