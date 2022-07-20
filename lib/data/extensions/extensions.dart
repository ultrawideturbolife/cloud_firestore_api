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
  /// Used to try and add a local [FirestoreAPI._idFieldName] field.
  ///
  /// We may do this so we have access to an id field in DTO's and models without actually having
  /// an ID field in Firestore.
  Map<T, E> tryAddLocalId<T, E>(String id, {required String idFieldName}) =>
      containsKey(idFieldName)
          ? this as Map<T, E>
          : (this..[idFieldName] = id) as Map<T, E>;

  /// Used to try and remove a local [FirestoreAPI._idFieldName] field.
  Map<T, E> tryRemoveLocalId<T, E>({required String idFieldName}) =>
      containsKey(idFieldName)
          ? (this..remove(idFieldName)) as Map<T, E>
          : this as Map<T, E>;

  /// Used to add a [FirestoreAPI._idFieldName] to a map.
  ///
  /// We may use this to automatically add [FirestoreAPI._idFieldName] fields to our Firestore
  /// data when saving the documents. Some may consider this a bad practice so be cautious using
  /// this.
  Map<T, E> withId<T, E>(String id, {required String idFieldName}) =>
      (this..[idFieldName] = id) as Map<T, E>;

  /// Used to add a [FirestoreAPI._updatedFieldName] to a map.
  ///
  /// We may use this to automatically add [FirestoreAPI._updatedFieldName] fields to our Firestore
  /// data when saving the documents. This field is configurable through the [FirestoreAPI.setUp]
  /// method.
  Map<T, E> withUpdated<T, E>({required String updatedFieldName}) =>
      (this..[updatedFieldName] = Timestamp.now()) as Map<T, E>;

  /// Used to add a [FirestoreAPI._createdFieldName] to a map.
  ///
  /// We may use this to automatically add [FirestoreAPI._createdFieldName] fields to our Firestore
  /// data when saving the documents. This field is configurable through the [FirestoreAPI.setUp]
  /// method.
  Map<T, E> withCreated<T, E>({required String createdFieldName}) =>
      (this..[createdFieldName] = Timestamp.now()) as Map<T, E>;

  /// Used to add [FirestoreAPI._createdFieldName] and [FirestoreAPI._updatedFieldName] fields to a map.
  ///
  /// We may use this to automatically add [FirestoreAPI._createdFieldName] and
  /// [FirestoreAPI._updatedFieldName] fields to our Firestore data when saving the documents. These
  /// fields are configurable through the [FirestoreAPI.setUp] method.
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
  /// Helper method to decide whether a [SearchTermType] is a [SearchTermType.array].
  bool get isArray => this == SearchTermType.array;
}
