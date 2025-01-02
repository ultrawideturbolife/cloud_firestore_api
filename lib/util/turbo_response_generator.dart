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
        title: _config.createSuccessTitle,
        message:
            isPlural ? _config.createSuccessPluralMessage : _config.createSuccessSingularMessage,
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
        title: _config.createFailedTitle,
        message: isPlural ? _config.createFailedPluralMessage : _config.createFailedSingularMessage,
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
        title: _config.searchSuccessTitle,
        message:
            isPlural ? _config.searchSuccessPluralMessage : _config.searchSuccessSingularMessage,
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
        title: _config.searchFailedTitle,
        message: isPlural ? _config.searchFailedPluralMessage : _config.searchFailedSingularMessage,
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
        title: _config.updateSuccessTitle,
        message:
            isPlural ? _config.updateSuccessPluralMessage : _config.updateSuccessSingularMessage,
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
        title: _config.updateFailedTitle,
        message: isPlural ? _config.updateFailedPluralMessage : _config.updateFailedSingularMessage,
      );

  /// Creates a successful delete [TurboResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  TurboResponse<void> deleteSuccessResponse({
    required bool isPlural,
  }) =>
      TurboResponse.success(
        result: null,
        title: _config.deleteSuccessTitle,
        message:
            isPlural ? _config.deleteSuccessPluralMessage : _config.deleteSuccessSingularMessage,
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
        title: _config.deleteFailedTitle,
        message: isPlural ? _config.deleteFailedPluralMessage : _config.deleteFailedSingularMessage,
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
