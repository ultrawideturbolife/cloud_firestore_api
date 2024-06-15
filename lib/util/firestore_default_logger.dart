import 'package:cloud_firestore_api/abstracts/firestore_logger.dart';
import 'package:cloud_firestore_api/data/models/sensitive_data.dart';
import 'package:flutter/rendering.dart';

/// Default logger implementing [FirestoreLogger] used to log debug info of the [FirestoreAPI].
class FirestoreDefaultLogger implements FirestoreLogger {
  const FirestoreDefaultLogger();

  @override
  void info({
    required String message,
    SensitiveData? sensitiveData,
  }) =>
      debugPrint(
          '$time [FirestoreAPI] 🗣 [INFO] $message [SensitiveData: $sensitiveData]');

  @override
  void success({
    required String message,
    SensitiveData? sensitiveData,
  }) =>
      debugPrint(
          '$time [FirestoreAPI] ✅ [SUCCESS] $message [SensitiveData: $sensitiveData]');

  @override
  void warning({
    required String message,
    SensitiveData? sensitiveData,
  }) =>
      debugPrint(
          '$time [FirestoreAPI] ⚠ [WARNING]️ $message [SensitiveData: $sensitiveData]');

  @override
  void error({
    required String message,
    Object? error,
    required SensitiveData? sensitiveData,
    StackTrace? stackTrace,
  }) =>
      debugPrint(
          '$time [FirestoreAPI] ❌ [ERROR] $message [SensitiveData: $sensitiveData]');

  /// Used to specify the time in each log.
  String get time => '[${DateTime.now().hourMinuteSecond}]';
}

extension on DateTime {
  /// Used to format the time in each log.
  String get hourMinuteSecond => '${hour < 10 ? '0$hour' : hour}:'
      '${minute < 10 ? '0$minute' : minute}:'
      '${second < 10 ? '0$second' : second}';
}
