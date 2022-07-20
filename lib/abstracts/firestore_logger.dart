/// Used to log debug info of the [FirestoreAPI].
///
/// Inherit and implement the methods in this class in order to use your own logger.
abstract class FirestoreLogger {
  /// Logs any info related debugging information of the [FirestoreAPI].
  void info(
    String message,
  );

  /// Logs any success related debugging information of the [FirestoreAPI].
  void success(
    String message,
  );

  /// Logs any info related debugging information of the [FirestoreAPI].
  void warning(
    String message,
  );

  /// Logs any value related debugging information of the [FirestoreAPI].
  void value(
    Object? value,
    String? description,
  );

  /// Logs any error related debugging information of the [FirestoreAPI].
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  });
}
