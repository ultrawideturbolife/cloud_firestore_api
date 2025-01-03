import 'package:turbo_response/turbo_response.dart';

import '../data/models/turbo_config.dart';

/// Used to create and fetch [TurboResponse]'s based on a [TurboConfig].
/// This class maintains similar method signatures to the old ResponseGenerator
/// for easier migration, while providing enhanced type-safety and error handling.
class TurboResponseGenerator {
  const TurboResponseGenerator({
    required TurboConfig config,
  }) : _config = config;

  /// Contains titles and messages for the responses.
  final TurboConfig _config;

  /// Creates a successful 'create' [TurboResponse] with a [result].
  ///
  /// Define [isPlural] to show the proper type of message.
  /// Returns a type-safe response with proper error handling.
  TurboResponse<E> createSuccessResponse<E>({
    required bool isPlural,
    required E result,
  }) =>
      TurboResponse.success(
        result: result,
        title: _config.effectiveCreateSuccessTitle,
        message: isPlural
            ? _config.effectiveCreateSuccessPluralMessage
            : _config.effectiveCreateSuccessSingularMessage,
      );

  /// Creates a failed 'create' [TurboResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  /// Optionally provide an [error] for enhanced error handling.
  TurboResponse<E> createFailedResponse<E>({
    required bool isPlural,
    Object? error,
  }) =>
      TurboResponse.fail(
        error: error ?? Exception('Create operation failed'),
        title: _config.effectiveCreateFailedTitle,
        message: isPlural
            ? _config.effectiveCreateFailedPluralMessage
            : _config.effectiveCreateFailedSingularMessage,
      );

  /// Creates a successful search [TurboResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  TurboResponse<E> searchSuccessResponse<E>({
    required bool isPlural,
    required E result,
  }) =>
      TurboResponse.success(
        result: result,
        title: _config.effectiveSearchSuccessTitle,
        message: isPlural
            ? _config.effectiveSearchSuccessPluralMessage
            : _config.effectiveSearchSuccessSingularMessage,
      );

  /// Creates a failed search [TurboResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  /// Optionally provide an [error] for enhanced error handling.
  TurboResponse<E> searchFailedResponse<E>({
    required bool isPlural,
    Object? error,
  }) =>
      TurboResponse.fail(
        error: error ?? Exception('Search operation failed'),
        title: _config.effectiveSearchFailedTitle,
        message: isPlural
            ? _config.effectiveSearchFailedPluralMessage
            : _config.effectiveSearchFailedSingularMessage,
      );

  /// Creates a successful update [TurboResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  TurboResponse<E> updateSuccessResponse<E>({
    required bool isPlural,
    required E result,
  }) =>
      TurboResponse.success(
        result: result,
        title: _config.effectiveUpdateSuccessTitle,
        message: isPlural
            ? _config.effectiveUpdateSuccessPluralMessage
            : _config.effectiveUpdateSuccessSingularMessage,
      );

  /// Creates a failed update [TurboResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  /// Optionally provide an [error] for enhanced error handling.
  TurboResponse<E> updateFailedResponse<E>({
    required bool isPlural,
    Object? error,
  }) =>
      TurboResponse.fail(
        error: error ?? Exception('Update operation failed'),
        title: _config.effectiveUpdateFailedTitle,
        message: isPlural
            ? _config.effectiveUpdateFailedPluralMessage
            : _config.effectiveUpdateFailedSingularMessage,
      );

  /// Creates a successful delete [TurboResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  TurboResponse<void> deleteSuccessResponse({
    required bool isPlural,
  }) =>
      TurboResponse.success(
        result: null,
        title: _config.effectiveDeleteSuccessTitle,
        message: isPlural
            ? _config.effectiveDeleteSuccessPluralMessage
            : _config.effectiveDeleteSuccessSingularMessage,
      );

  /// Creates a failed delete [TurboResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  /// Optionally provide an [error] for enhanced error handling.
  TurboResponse<E> deleteFailedResponse<E>({
    required bool isPlural,
    Object? error,
  }) =>
      TurboResponse.fail(
        error: error ?? Exception('Delete operation failed'),
        title: _config.effectiveDeleteFailedTitle,
        message: isPlural
            ? _config.effectiveDeleteFailedPluralMessage
            : _config.effectiveDeleteFailedSingularMessage,
      );

  /// Creates an empty success [TurboResponse].
  ///
  /// Useful for operations that don't return a value.
  TurboResponse<void> emptySuccessResponse() => TurboResponse.success(result: null);

  /// Creates an empty fail [TurboResponse].
  ///
  /// Useful for operations that don't return a value.
  /// Optionally provide an [error] for enhanced error handling.
  TurboResponse<void> emptyFailResponse({Object? error}) =>
      TurboResponse.fail(error: error ?? Exception('Operation failed'));
}
