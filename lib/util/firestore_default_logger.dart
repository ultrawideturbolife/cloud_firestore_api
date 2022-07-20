import 'package:cloud_firestore_api/abstracts/firestore_logger.dart';
import 'package:flutter/rendering.dart';

/// Default logger implementing [FirestoreLogger] used to log debug info of the [FirestoreAPI].
class FirestoreDefaultLogger implements FirestoreLogger {
  const FirestoreDefaultLogger();

  @override
  void info(
    String message,
  ) =>
      debugPrint('$time [FirestoreAPI] 🗣 [INFO] $message');

  @override
  void success(
    String message,
  ) =>
      debugPrint('$time [FirestoreAPI] ✅ [SUCCESS] $message');

  @override
  void warning(
    String message,
  ) =>
      debugPrint('$time [FirestoreAPI] ⚠ [WARNING]️ $message');

  @override
  void value(
    Object? value,
    String? description,
  ) =>
      debugPrint(
          '$time [FirestoreAPI] 💾 [VALUE] ${description != null ? '$description: ' : ''}$value');

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      debugPrint('$time [FirestoreAPI] ❌ [ERROR] $message');

  /// Used to specify the time in each log.
  String get time => '[${DateTime.now().hourMinuteSecond}]';
}

extension on DateTime {
  /// Used to format the time in each log.
  String get hourMinuteSecond => '${hour < 10 ? '0$hour' : hour}:'
      '${minute < 10 ? '0$minute' : minute}:'
      '${second < 10 ? '0$second' : second}';
}
