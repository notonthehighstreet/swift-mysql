public enum MySQLConnectionPoolMessage {
  case CreatedNewConnection
  case FailedToCreateConnection
  case ConnectionDisconnected
  case RetrievedConnectionFromPool
}
