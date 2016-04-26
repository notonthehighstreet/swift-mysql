// MySQLField encapsulates the metadata associated with a field in the database.
//TODO: complete implementation of header corresponding to the C library.
public struct MySQLField {

  /**
    Name of the field.
  */
  var name: String = ""
  var type: MySQLFieldType
}
