import 'package:turbo_response/turbo_response.dart';

/// Config class to provide usable messages for your [TurboResponse]'s.
///
/// Provide this config in different languages to easily show feedback to your user when certain
/// actions have succeeded or failed. This is an enhanced version of the old FeedbackConfig
/// with better type safety and error handling.
class TurboConfig {
  const TurboConfig({
    String? singularForm,
    String? pluralForm,
    this.createSuccessTitle = 'Create success',
    String createSuccessSingularMessage = '${_Forms._singularForm} has been created.',
    String createSuccessPluralMessage = '${_Forms._pluralForm} have been created.',
    this.createFailedTitle = 'Create failed',
    String createFailedSingularMessage =
        'Unable to create ${_Forms._singularForm}, please try again later.',
    String createFailedPluralMessage =
        'Unable to create ${_Forms._pluralForm}, please try again later.',
    this.searchSuccessTitle = 'Search success',
    String searchSuccessSingularMessage = '${_Forms._singularForm} was found.',
    String searchSuccessPluralMessage = '${_Forms._pluralForm} were found.',
    this.searchFailedTitle = 'Search failed',
    String searchFailedSingularMessage =
        'Unable to find ${_Forms._singularForm}, please try again later.',
    String searchFailedPluralMessage =
        'Unable to find ${_Forms._pluralForm}, please try again later.',
    this.updateSuccessTitle = 'Update success',
    String updateSuccessSingularMessage = '${_Forms._singularForm} has been updated.',
    String updateSuccessPluralMessage = '${_Forms._pluralForm} have been updated.',
    this.updateFailedTitle = 'Update failed',
    String updateFailedSingularMessage =
        'Unable to update ${_Forms._singularForm}, please try again later.',
    String updateFailedPluralMessage =
        'Unable to update ${_Forms._pluralForm}, please try again later.',
    this.deleteSuccessTitle = 'Delete success',
    String deleteSuccessSingularMessage = '${_Forms._singularForm} has been deleted.',
    String deleteSuccessPluralMessage = '${_Forms._pluralForm} have been deleted.',
    this.deleteFailedTitle = 'Delete failed',
    String deleteFailedSingularMessage =
        'Unable to delete ${_Forms._singularForm}, please try again later.',
    String deleteFailedPluralMessage =
        'Unable to delete ${_Forms._pluralForm}, please try again later.',
  })  : _singularForm = singularForm,
        _pluralForm = pluralForm,
        _createSuccessSingularMessage = createSuccessSingularMessage,
        _createSuccessPluralMessage = createSuccessPluralMessage,
        _createFailedSingularMessage = createFailedSingularMessage,
        _createFailedPluralMessage = createFailedPluralMessage,
        _searchSuccessSingularMessage = searchSuccessSingularMessage,
        _searchSuccessPluralMessage = searchSuccessPluralMessage,
        _searchFailedSingularMessage = searchFailedSingularMessage,
        _searchFailedPluralMessage = searchFailedPluralMessage,
        _updateSuccessSingularMessage = updateSuccessSingularMessage,
        _updateSuccessPluralMessage = updateSuccessPluralMessage,
        _updateFailedSingularMessage = updateFailedSingularMessage,
        _updateFailedPluralMessage = updateFailedPluralMessage,
        _deleteSuccessSingularMessage = deleteSuccessSingularMessage,
        _deleteSuccessPluralMessage = deleteSuccessPluralMessage,
        _deleteFailedSingularMessage = deleteFailedSingularMessage,
        _deleteFailedPluralMessage = deleteFailedPluralMessage;

  /// Holds a custom singular form, preferably in lowercase.
  final String? _singularForm;

  /// Holds a custom plural form, preferably in lowercase.
  final String? _pluralForm;

  /// Holds the title that's used for displaying 'create' success messages.
  final String createSuccessTitle;

  /// Holds the raw singular message that's used for displaying 'create' success messages.
  final String _createSuccessSingularMessage;

  /// Holds the raw plural message that's used for displaying 'create' success messages.
  final String _createSuccessPluralMessage;

  /// Holds the singular message that's used for displaying 'create' success messages.
  String get createSuccessSingularMessage => (_singularForm == null
          ? _createSuccessSingularMessage
          : _createSuccessSingularMessage.replaceAll(_Forms._singularForm, _singularForm))
      .capitalize;

  /// Holds the plural message that's used for displaying 'create' success messages.
  String get createSuccessPluralMessage => (_pluralForm == null
          ? _createSuccessPluralMessage
          : _createSuccessPluralMessage.replaceAll(_Forms._pluralForm, _pluralForm))
      .capitalize;

  /// Holds the title that's used for displaying 'create' failed messages.
  final String createFailedTitle;

  /// Holds the raw singular message that's used for displaying 'create' failed messages.
  final String _createFailedSingularMessage;

  /// Holds the raw plural message that's used for displaying 'create' failed messages.
  final String _createFailedPluralMessage;

  /// Holds the singular message that's used for displaying 'create' failed messages.
  String get createFailedSingularMessage => (_singularForm == null
          ? _createFailedSingularMessage
          : _createFailedSingularMessage.replaceAll(_Forms._singularForm, _singularForm))
      .capitalize;

  /// Holds the plural message that's used for displaying 'create' failed messages.
  String get createFailedPluralMessage => (_pluralForm == null
          ? _createFailedPluralMessage
          : _createFailedPluralMessage.replaceAll(_Forms._pluralForm, _pluralForm))
      .capitalize;

  /// Holds the title that's used for displaying 'search' success messages.
  final String searchSuccessTitle;

  /// Holds the raw singular message that's used for displaying 'search' success messages.
  final String _searchSuccessSingularMessage;

  /// Holds the raw plural message that's used for displaying 'search' success messages.
  final String _searchSuccessPluralMessage;

  /// Holds the singular message that's used for displaying 'search' success messages.
  String get searchSuccessSingularMessage => (_singularForm == null
          ? _searchSuccessSingularMessage
          : _searchSuccessSingularMessage.replaceAll(_Forms._singularForm, _singularForm))
      .capitalize;

  /// Holds the plural message that's used for displaying 'search' success messages.
  String get searchSuccessPluralMessage => (_pluralForm == null
          ? _searchSuccessPluralMessage
          : _searchSuccessPluralMessage.replaceAll(_Forms._pluralForm, _pluralForm))
      .capitalize;

  /// Holds the title that's used for displaying 'search' failed messages.
  final String searchFailedTitle;

  /// Holds the raw singular message that's used for displaying 'search' failed messages.
  final String _searchFailedSingularMessage;

  /// Holds the raw plural message that's used for displaying 'search' failed messages.
  final String _searchFailedPluralMessage;

  /// Holds the singular message that's used for displaying 'search' failed messages.
  String get searchFailedSingularMessage => (_singularForm == null
          ? _searchFailedSingularMessage
          : _searchFailedSingularMessage.replaceAll(_Forms._singularForm, _singularForm))
      .capitalize;

  /// Holds the plural message that's used for displaying 'search' failed messages.
  String get searchFailedPluralMessage => (_pluralForm == null
          ? _searchFailedPluralMessage
          : _searchFailedPluralMessage.replaceAll(_Forms._pluralForm, _pluralForm))
      .capitalize;

  /// Holds the title that's used for displaying 'update' success messages.
  final String updateSuccessTitle;

  /// Holds the raw singular message that's used for displaying 'update' success messages.
  final String _updateSuccessSingularMessage;

  /// Holds the raw plural message that's used for displaying 'update' success messages.
  final String _updateSuccessPluralMessage;

  /// Holds the singular message that's used for displaying 'update' success messages.
  String get updateSuccessSingularMessage => (_singularForm == null
          ? _updateSuccessSingularMessage
          : _updateSuccessSingularMessage.replaceAll(_Forms._singularForm, _singularForm))
      .capitalize;

  /// Holds the plural message that's used for displaying 'update' success messages.
  String get updateSuccessPluralMessage => (_pluralForm == null
          ? _updateSuccessPluralMessage
          : _updateSuccessPluralMessage.replaceAll(_Forms._pluralForm, _pluralForm))
      .capitalize;

  /// Holds the title that's used for displaying 'update' failed messages.
  final String updateFailedTitle;

  /// Holds the raw singular message that's used for displaying 'update' failed messages.
  final String _updateFailedSingularMessage;

  /// Holds the raw plural message that's used for displaying 'update' failed messages.
  final String _updateFailedPluralMessage;

  /// Holds the singular message that's used for displaying 'update' failed messages.
  String get updateFailedSingularMessage => (_singularForm == null
          ? _updateFailedSingularMessage
          : _updateFailedSingularMessage.replaceAll(_Forms._singularForm, _singularForm))
      .capitalize;

  /// Holds the plural message that's used for displaying 'update' failed messages.
  String get updateFailedPluralMessage => (_pluralForm == null
          ? _updateFailedPluralMessage
          : _updateFailedPluralMessage.replaceAll(_Forms._pluralForm, _pluralForm))
      .capitalize;

  /// Holds the title that's used for displaying 'delete' success messages.
  final String deleteSuccessTitle;

  /// Holds the raw singular message that's used for displaying 'delete' success messages.
  final String _deleteSuccessSingularMessage;

  /// Holds the raw plural message that's used for displaying 'delete' success messages.
  final String _deleteSuccessPluralMessage;

  /// Holds the singular message that's used for displaying 'delete' success messages.
  String get deleteSuccessSingularMessage => (_singularForm == null
          ? _deleteSuccessSingularMessage
          : _deleteSuccessSingularMessage.replaceAll(_Forms._singularForm, _singularForm))
      .capitalize;

  /// Holds the plural message that's used for displaying 'delete' success messages.
  String get deleteSuccessPluralMessage => (_pluralForm == null
          ? _deleteSuccessPluralMessage
          : _deleteSuccessPluralMessage.replaceAll(_Forms._pluralForm, _pluralForm))
      .capitalize;

  /// Holds the title that's used for displaying 'delete' failed messages.
  final String deleteFailedTitle;

  /// Holds the raw singular message that's used for displaying 'delete' failed messages.
  final String _deleteFailedSingularMessage;

  /// Holds the raw plural message that's used for displaying 'delete' failed messages.
  final String _deleteFailedPluralMessage;

  /// Holds the singular message that's used for displaying 'delete' failed messages.
  String get deleteFailedSingularMessage => (_singularForm == null
          ? _deleteFailedSingularMessage
          : _deleteFailedSingularMessage.replaceAll(_Forms._singularForm, _singularForm))
      .capitalize;

  /// Holds the plural message that's used for displaying 'delete' failed messages.
  String get deleteFailedPluralMessage => (_pluralForm == null
          ? _deleteFailedPluralMessage
          : _deleteFailedPluralMessage.replaceAll(_Forms._pluralForm, _pluralForm))
      .capitalize;
}

/// Private class to hold form constants.
class _Forms {
  static const _singularForm = 'item';
  static const _pluralForm = 'items';
}

/// Extension to capitalize strings.
extension on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
