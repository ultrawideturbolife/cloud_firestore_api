/// Used to decide on the type of search.
enum SearchTermType {
  /// Indicates the search should be performed by comparing the string value of a field.
  startsWith,

  /// Indicates the search should be performed by comparing the contents of an array of a field.
  arrayContains,
}
