import 'package:cloud_firestore_api/data/models/sensitive_data.dart';

/// Used to log debug info of the [FirestoreAPI].
///
/// Inherit and implement the methods in this class in order to use your own logger.
abstract class FirestoreLogger {
  /// Logs any info related debugging information of the [FirestoreAPI].
  void info({
    required String message,
    required SensitiveData? sensitiveData,
  });

  /// Logs any success related debugging information of the [FirestoreAPI].
  void success({
    required String message,
    required SensitiveData? sensitiveData,
  });

  /// Logs any info related debugging information of the [FirestoreAPI].
  void warning({
    required String message,
    required SensitiveData? sensitiveData,
  });

  /// Logs any error related debugging information of the [FirestoreAPI].
  void error({
    required String message,
    Object? error,
    StackTrace? stackTrace,
    required SensitiveData? sensitiveData,
  });
}
