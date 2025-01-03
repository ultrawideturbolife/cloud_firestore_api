import 'package:flutter/foundation.dart';

/// Used to configure the feedback messages of the [FirestoreApi].
@immutable
class TurboConfig {
  /// Creates a new instance of [TurboConfig].
  const TurboConfig({
    this.singularForm = 'item',
    this.pluralForm = 'items',
    this.createSuccessTitle,
    this.createSuccessSingularMessage,
    this.createSuccessPluralMessage,
    this.createFailedTitle,
    this.createFailedSingularMessage,
    this.createFailedPluralMessage,
    this.searchSuccessTitle,
    this.searchSuccessSingularMessage,
    this.searchSuccessPluralMessage,
    this.searchFailedTitle,
    this.searchFailedSingularMessage,
    this.searchFailedPluralMessage,
    this.updateSuccessTitle,
    this.updateSuccessSingularMessage,
    this.updateSuccessPluralMessage,
    this.updateFailedTitle,
    this.updateFailedSingularMessage,
    this.updateFailedPluralMessage,
    this.deleteSuccessTitle,
    this.deleteSuccessSingularMessage,
    this.deleteSuccessPluralMessage,
    this.deleteFailedTitle,
    this.deleteFailedSingularMessage,
    this.deleteFailedPluralMessage,
  });

  /// Used to determine the singular form of the item being handled.
  ///
  /// If not provided, defaults to 'item'.
  final String singularForm;

  /// Used to determine the plural form of the item being handled.
  ///
  /// If not provided, defaults to 'items'.
  final String pluralForm;

  String get _effectiveSingularForm => singularForm.isEmpty ? 'item' : singularForm;
  String get _effectivePluralForm => pluralForm.isEmpty ? 'items' : pluralForm;

  /// Holds the title that's used for displaying 'create' success messages.
  final String? createSuccessTitle;

  /// Holds the message that's used for displaying 'create' success messages in singular form.
  final String? createSuccessSingularMessage;

  /// Holds the message that's used for displaying 'create' success messages in plural form.
  final String? createSuccessPluralMessage;

  /// Holds the title that's used for displaying 'create' failed messages.
  final String? createFailedTitle;

  /// Holds the message that's used for displaying 'create' failed messages in singular form.
  final String? createFailedSingularMessage;

  /// Holds the message that's used for displaying 'create' failed messages in plural form.
  final String? createFailedPluralMessage;

  /// Holds the title that's used for displaying 'search' success messages.
  final String? searchSuccessTitle;

  /// Holds the message that's used for displaying 'search' success messages in singular form.
  final String? searchSuccessSingularMessage;

  /// Holds the message that's used for displaying 'search' success messages in plural form.
  final String? searchSuccessPluralMessage;

  /// Holds the title that's used for displaying 'search' failed messages.
  final String? searchFailedTitle;

  /// Holds the message that's used for displaying 'search' failed messages in singular form.
  final String? searchFailedSingularMessage;

  /// Holds the message that's used for displaying 'search' failed messages in plural form.
  final String? searchFailedPluralMessage;

  /// Holds the title that's used for displaying 'update' success messages.
  final String? updateSuccessTitle;

  /// Holds the message that's used for displaying 'update' success messages in singular form.
  final String? updateSuccessSingularMessage;

  /// Holds the message that's used for displaying 'update' success messages in plural form.
  final String? updateSuccessPluralMessage;

  /// Holds the title that's used for displaying 'update' failed messages.
  final String? updateFailedTitle;

  /// Holds the message that's used for displaying 'update' failed messages in singular form.
  final String? updateFailedSingularMessage;

  /// Holds the message that's used for displaying 'update' failed messages in plural form.
  final String? updateFailedPluralMessage;

  /// Holds the title that's used for displaying 'delete' success messages.
  final String? deleteSuccessTitle;

  /// Holds the message that's used for displaying 'delete' success messages in singular form.
  final String? deleteSuccessSingularMessage;

  /// Holds the message that's used for displaying 'delete' success messages in plural form.
  final String? deleteSuccessPluralMessage;

  /// Holds the title that's used for displaying 'delete' failed messages.
  final String? deleteFailedTitle;

  /// Holds the message that's used for displaying 'delete' failed messages in singular form.
  final String? deleteFailedSingularMessage;

  /// Holds the message that's used for displaying 'delete' failed messages in plural form.
  final String? deleteFailedPluralMessage;

  /// The title that's used for displaying 'create' success messages.
  String get effectiveCreateSuccessTitle => createSuccessTitle ?? 'Create success';

  /// The message that's used for displaying 'create' success messages in singular form.
  String get effectiveCreateSuccessSingularMessage =>
      createSuccessSingularMessage ?? '${_effectiveSingularForm} has been created.';

  /// The message that's used for displaying 'create' success messages in plural form.
  String get effectiveCreateSuccessPluralMessage =>
      createSuccessPluralMessage ?? '${_effectivePluralForm} have been created.';

  /// The title that's used for displaying 'create' failed messages.
  String get effectiveCreateFailedTitle => createFailedTitle ?? 'Create failed';

  /// The message that's used for displaying 'create' failed messages in singular form.
  String get effectiveCreateFailedSingularMessage =>
      createFailedSingularMessage ??
      'Unable to create ${_effectiveSingularForm}, please try again later.';

  /// The message that's used for displaying 'create' failed messages in plural form.
  String get effectiveCreateFailedPluralMessage =>
      createFailedPluralMessage ??
      'Unable to create ${_effectivePluralForm}, please try again later.';

  /// The title that's used for displaying 'search' success messages.
  String get effectiveSearchSuccessTitle => searchSuccessTitle ?? 'Search success';

  /// The message that's used for displaying 'search' success messages in singular form.
  String get effectiveSearchSuccessSingularMessage =>
      searchSuccessSingularMessage ?? '${_effectiveSingularForm} was found.';

  /// The message that's used for displaying 'search' success messages in plural form.
  String get effectiveSearchSuccessPluralMessage =>
      searchSuccessPluralMessage ?? '${_effectivePluralForm} were found.';

  /// The title that's used for displaying 'search' failed messages.
  String get effectiveSearchFailedTitle => searchFailedTitle ?? 'Search failed';

  /// The message that's used for displaying 'search' failed messages in singular form.
  String get effectiveSearchFailedSingularMessage =>
      searchFailedSingularMessage ??
      'Unable to find ${_effectiveSingularForm}, please try again later.';

  /// The message that's used for displaying 'search' failed messages in plural form.
  String get effectiveSearchFailedPluralMessage =>
      searchFailedPluralMessage ??
      'Unable to find ${_effectivePluralForm}, please try again later.';

  /// The title that's used for displaying 'update' success messages.
  String get effectiveUpdateSuccessTitle => updateSuccessTitle ?? 'Update success';

  /// The message that's used for displaying 'update' success messages in singular form.
  String get effectiveUpdateSuccessSingularMessage =>
      updateSuccessSingularMessage ?? '${_effectiveSingularForm} has been updated.';

  /// The message that's used for displaying 'update' success messages in plural form.
  String get effectiveUpdateSuccessPluralMessage =>
      updateSuccessPluralMessage ?? '${_effectivePluralForm} have been updated.';

  /// The title that's used for displaying 'update' failed messages.
  String get effectiveUpdateFailedTitle => updateFailedTitle ?? 'Update failed';

  /// The message that's used for displaying 'update' failed messages in singular form.
  String get effectiveUpdateFailedSingularMessage =>
      updateFailedSingularMessage ??
      'Unable to update ${_effectiveSingularForm}, please try again later.';

  /// The message that's used for displaying 'update' failed messages in plural form.
  String get effectiveUpdateFailedPluralMessage =>
      updateFailedPluralMessage ??
      'Unable to update ${_effectivePluralForm}, please try again later.';

  /// The title that's used for displaying 'delete' success messages.
  String get effectiveDeleteSuccessTitle => deleteSuccessTitle ?? 'Delete success';

  /// The message that's used for displaying 'delete' success messages in singular form.
  String get effectiveDeleteSuccessSingularMessage =>
      deleteSuccessSingularMessage ?? '${_effectiveSingularForm} has been deleted.';

  /// The message that's used for displaying 'delete' success messages in plural form.
  String get effectiveDeleteSuccessPluralMessage =>
      deleteSuccessPluralMessage ?? '${_effectivePluralForm} have been deleted.';

  /// The title that's used for displaying 'delete' failed messages.
  String get effectiveDeleteFailedTitle => deleteFailedTitle ?? 'Delete failed';

  /// The message that's used for displaying 'delete' failed messages in singular form.
  String get effectiveDeleteFailedSingularMessage =>
      deleteFailedSingularMessage ??
      'Unable to delete ${_effectiveSingularForm}, please try again later.';

  /// The message that's used for displaying 'delete' failed messages in plural form.
  String get effectiveDeleteFailedPluralMessage =>
      deleteFailedPluralMessage ??
      'Unable to delete ${_effectivePluralForm}, please try again later.';
}
