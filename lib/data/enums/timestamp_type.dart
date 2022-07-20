/// Used to decide on the type of created/updated timestamp.
enum TimestampType {
  /// Indicates only a 'created' timestamp should be set.
  created,

  /// Indicates only an 'updated' timestamp should be set.
  updated,

  /// Indicates both a 'created' and 'updated' timestamp should be set.
  createdAndUpdated,

  /// Indicates no timestamp should be set.
  none,
}
