import 'package:feedback_response/feedback_response.dart';

import '../data/models/feedback_config.dart';

/// Used to create and fetch [FeedbackResponse]'s based on a [FeedbackConfig].
class ResponseGenerator {
  const ResponseGenerator({
    required FeedbackConfig feedbackConfig,
  }) : _feedbackConfig = feedbackConfig;

  /// Contains titles and messages for the feedback responses.
  final FeedbackConfig _feedbackConfig;

  /// Creates a successful 'create' [FeedbackResponse] with a [result].
  ///
  /// Define [isPlural] to show the proper type of message.
  FeedbackResponse<E> createSuccessResponse<E>({
    required isPlural,
    required E result,
  }) =>
      FeedbackResponse.success(
        title: _feedbackConfig.createSuccessTitle,
        message: isPlural
            ? _feedbackConfig.createSuccessPluralMessage
            : _feedbackConfig.createSuccessSingularMessage,
        result: result,
      );

  /// Creates a failed 'create' [FeedbackResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  FeedbackResponse<E> createFailedResponse<E>({
    required isPlural,
  }) =>
      FeedbackResponse.error(
        title: _feedbackConfig.createFailedTitle,
        message: isPlural
            ? _feedbackConfig.createFailedPluralMessage
            : _feedbackConfig.createFailedSingularMessage,
      );

  /// Creates a successful search [FeedbackResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  FeedbackResponse<E> searchSuccessResponse<E>({
    required isPlural,
    required E result,
  }) =>
      FeedbackResponse.success(
        title: _feedbackConfig.searchSuccessTitle,
        message: isPlural
            ? _feedbackConfig.searchSuccessPluralMessage
            : _feedbackConfig.searchSuccessSingularMessage,
        result: result,
      );

  /// Creates a failed search [FeedbackResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  FeedbackResponse<E> searchFailedResponse<E>({
    required isPlural,
  }) =>
      FeedbackResponse.error(
        title: _feedbackConfig.searchFailedTitle,
        message: isPlural
            ? _feedbackConfig.searchFailedPluralMessage
            : _feedbackConfig.searchFailedSingularMessage,
      );

  /// Creates a successful update [FeedbackResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  FeedbackResponse<E> updateSuccessResponse<E>({
    required isPlural,
    required E result,
  }) =>
      FeedbackResponse.success(
        title: _feedbackConfig.updateSuccessTitle,
        message: isPlural
            ? _feedbackConfig.updateSuccessPluralMessage
            : _feedbackConfig.updateSuccessSingularMessage,
        result: result,
      );

  /// Creates a failed update [FeedbackResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  FeedbackResponse<E> updateFailedResponse<E>({
    required isPlural,
  }) =>
      FeedbackResponse.error(
        title: _feedbackConfig.updateFailedTitle,
        message: isPlural
            ? _feedbackConfig.updateFailedPluralMessage
            : _feedbackConfig.updateFailedSingularMessage,
      );

  /// Creates a successful update [FeedbackResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  FeedbackResponse<void> deleteSuccessResponse({
    required isPlural,
  }) =>
      FeedbackResponse.success(
        title: _feedbackConfig.deleteSuccessTitle,
        message: isPlural
            ? _feedbackConfig.deleteSuccessPluralMessage
            : _feedbackConfig.deleteSuccessSingularMessage,
      );

  /// Creates a failed delete [FeedbackResponse].
  ///
  /// Define [isPlural] to show the proper type of message.
  FeedbackResponse<E> deleteFailedResponse<E>({
    required isPlural,
  }) =>
      FeedbackResponse.error(
        title: _feedbackConfig.deleteFailedTitle,
        message: isPlural
            ? _feedbackConfig.deleteFailedPluralMessage
            : _feedbackConfig.deleteFailedSingularMessage,
      );
}
