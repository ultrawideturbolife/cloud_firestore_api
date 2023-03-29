part of '../../api/firestore_api.dart';

extension on TimestampType {
  /// Used to automatically add a 'created' and/or 'updated' field to any map of data.
  Map<E, T> add<E, T>(
    Map<E, T> map, {
    String? createdFieldName,
    String? updatedFieldName,
  }) {
    switch (this) {
      case TimestampType.created:
        return map.withCreated(
          createdFieldName: createdFieldName!,
        );
      case TimestampType.updated:
        return map.withUpdated(
          updatedFieldName: updatedFieldName!,
        );
      case TimestampType.createdAndUpdated:
        return map.withCreatedAndUpdated(
          createdFieldName: createdFieldName!,
          updatedFieldName: updatedFieldName!,
        );
      case TimestampType.none:
        return map;
    }
  }
}

extension on Map {
  /// Used to try and add a local [FirestoreApi._referenceFieldName] field.
  ///
  /// We may do this so we have access to a reference field in DTO's and models without actually having
  /// the reference field in Firestore.
  Map<T, E> tryAddLocalDocumentReference<T, E>(
    DocumentReference documentReference, {
    required String referenceFieldName,
    required bool tryAddLocalDocumentReference,
  }) =>
      tryAddLocalDocumentReference && containsKey(referenceFieldName)
          ? this as Map<T, E>
          : (this..[referenceFieldName] = documentReference) as Map<T, E>;

  /// Used to try and remove a local [FirestoreApi._referenceFieldName] field.
  Map<T, E> tryRemoveLocalDocumentReference<T, E>({
    required String referenceFieldName,
    required bool tryRemoveLocalDocumentReference,
  }) =>
      tryRemoveLocalDocumentReference && containsKey(referenceFieldName)
          ? (this..remove(referenceFieldName)) as Map<T, E>
          : this as Map<T, E>;

  /// Used to try and add a local [FirestoreApi._idFieldName] field.
  ///
  /// We may do this so we have access to an id field in DTO's and models without actually having
  /// an ID field in Firestore.
  Map<T, E> tryAddLocalId<T, E>(
    String id, {
    required String idFieldName,
    required bool tryAddLocalId,
  }) =>
      tryAddLocalId && containsKey(idFieldName)
          ? this as Map<T, E>
          : (this..[idFieldName] = id) as Map<T, E>;

  /// Used to try and remove a local [FirestoreApi._idFieldName] field.
  Map<T, E> tryRemoveLocalId<T, E>({
    required String idFieldName,
    required bool tryRemoveLocalId,
  }) =>
      tryRemoveLocalId && containsKey(idFieldName)
          ? (this..remove(idFieldName)) as Map<T, E>
          : this as Map<T, E>;

  /// Used to add a [FirestoreApi._updatedFieldName] to a map.
  ///
  /// We may use this to automatically add [FirestoreApi._updatedFieldName] fields to our Firestore
  /// data when saving the documents. This field is configurable through the [FirestoreApi.setUp]
  /// method.
  Map<T, E> withUpdated<T, E>({required String updatedFieldName}) =>
      (this..[updatedFieldName] = Timestamp.now()) as Map<T, E>;

  /// Used to add a [FirestoreApi._createdFieldName] to a map.
  ///
  /// We may use this to automatically add [FirestoreApi._createdFieldName] fields to our Firestore
  /// data when saving the documents. This field is configurable through the [FirestoreApi.setUp]
  /// method.
  Map<T, E> withCreated<T, E>({required String createdFieldName}) =>
      (this..[createdFieldName] = Timestamp.now()) as Map<T, E>;

  /// Used to add [FirestoreApi._createdFieldName] and [FirestoreApi._updatedFieldName] fields to a map.
  ///
  /// We may use this to automatically add [FirestoreApi._createdFieldName] and
  /// [FirestoreApi._updatedFieldName] fields to our Firestore data when saving the documents. These
  /// fields are configurable through the [FirestoreApi.setUp] method.
  Map<T, E> withCreatedAndUpdated<T, E>({
    required String createdFieldName,
    required String updatedFieldName,
  }) {
    final now = Timestamp.now();
    return (this
      ..[createdFieldName] = now
      ..[updatedFieldName] = now) as Map<T, E>;
  }
}

extension on List {
  /// Helper method to decide whether a result containing a list should show a plural feedback message.
  bool get isPlural => length > 1;
}

extension on SearchTermType {
  /// Helper method to decide whether a [SearchTermType] is a [SearchTermType.arrayContains].
  bool get isArray => this == SearchTermType.arrayContains;
}
