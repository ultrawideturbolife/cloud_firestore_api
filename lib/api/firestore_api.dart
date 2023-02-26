import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feedback_response/feedback_response.dart';
import 'package:cloud_firestore_api/util/firestore_default_logger.dart';
import 'package:cloud_firestore_api/abstracts/firestore_logger.dart';
import 'package:cloud_firestore_api/util/response_generator.dart';
import 'package:cloud_firestore_api/data/enums/search_term_type.dart';
import 'package:cloud_firestore_api/data/enums/timestamp_type.dart';
import 'package:cloud_firestore_api/data/models/write_batch_with_reference.dart';

import 'package:cloud_firestore_api/abstracts/writeable.dart';
import 'package:cloud_firestore_api/data/models/feedback_config.dart';

part 'package:cloud_firestore_api/data/extensions/extensions.dart';

typedef CollectionReferenceQuery<T> = Query<T> Function(
    CollectionReference<T> collectionReference);
typedef CollectionGroupQuery<T> = Query<T> Function(Query<T> collectionGroup);

/// Used to perform all Firestore related CRUD tasks and a little bit more.
class FirestoreAPI<T extends Object> {
  /// The [FirestoreAPI] requires only a [firebaseFirestore] instance and a [collectionPath] to
  /// work initially.
  ///
  /// If you are interested in using the 'WithConverter' methods that automatically convert your
  /// data to specific models of [T] then define both the [toJson] and [fromJson].
  ///
  /// If [tryAddLocalId] is true then your data will have an id field added based on the
  /// [idFieldName]. Add this id field to the model you're deserializing to and you
  /// will have easy access to the document id at any time. Any create or update method will by
  /// default try te remove the field again before writing to Firestore (unless specified otherwise
  /// inside the method).
  ///
  /// If you are interested in providing custom feedback to your users then provide your own
  /// instance of the [feedbackConfig]. This config contains specific feedback messages regarding
  /// successful and unsuccessful CRUD operations of a certain collection.
  ///
  /// The [firestoreLogger] is used to provide proper logging when performing any operation inside
  /// the [FirestoreAPI]. Implement your own version in order to use to use your own logging system.
  FirestoreAPI({
    required FirebaseFirestore firebaseFirestore,
    required String Function() collectionPath,
    Map<String, dynamic> Function(T value)? toJson,
    T Function(Map<String, dynamic> json)? fromJson,
    bool tryAddLocalId = false,
    FeedbackConfig feedbackConfig = const FeedbackConfig(),
    FirestoreLogger firestoreLogger = const FirestoreDefaultLogger(),
    String createdFieldName = 'created',
    String updatedFieldName = 'updated',
    String idFieldName = 'id',
    bool isCollectionGroup = false,
  })  : _firebaseFirestore = firebaseFirestore,
        _collectionPath = collectionPath,
        _toJson = toJson,
        _fromJson = fromJson,
        _tryAddLocalId = tryAddLocalId,
        _responseConfig = feedbackConfig.responseConfig,
        _log = firestoreLogger,
        _createdFieldName = createdFieldName,
        _updatedFieldName = updatedFieldName,
        _idFieldName = idFieldName,
        _isCollectionGroup = isCollectionGroup;

  /// Used to performs Firestore operations.
  final FirebaseFirestore _firebaseFirestore;

  /// Used to find the Firestore collection.
  final String Function() _collectionPath;

  /// Used to serialize your data to JSON when using 'WithConverter' methods.
  final Map<String, dynamic> Function(T value)? _toJson;

  /// Used to deserialize your data to JSON when using 'WithConverter' methods.
  final T Function(Map<String, dynamic> json)? _fromJson;

  /// Used to add an id field to any of your local Firestore data (so not actually in Firestore).
  ///
  /// If this is true then your data will have an id field added based on the [_idFieldName]
  /// specified in the constructor. Add this id field to the model you're deserializing to and you
  /// will have easy access to the document id at any time. Any create or update method will by
  /// default try te remove the field again before writing to Firestore (unless specified otherwise).
  final bool _tryAddLocalId;

  /// Used to create responses from the configured [FeedbackConfig].
  final ResponseGenerator _responseConfig;

  /// Used to provide proper logging when performing any operation inside the [FirestoreAPI].
  final FirestoreLogger _log;

  /// Used to provide a default 'created' field based on the provided [TimestampType] of create methods.
  final String _createdFieldName;

  /// Used to provide a default 'updated' field based on the provided [TimestampType] of update methods.
  final String _updatedFieldName;

  /// Used to provide an id field to your create/update methods if necessary.
  ///
  /// May also be used to provide an id field to your data from Firestore when fetching data.
  final String _idFieldName;

  /// Whether the [_collectionPath] refers to a collection group.
  final bool _isCollectionGroup;

  /// Finds a document based on given [id].
  ///
  /// This method returns raw data in the form of a Map<String, dynamic>. If [_tryAddLocalId] is
  /// true then the map will also contain a local id field based on the [_idFieldName]
  /// specified in the constructor so you may retrieve document id's more easily after deserialization.
  ///
  /// If you rather want to convert this data into [T] immediately you should use the
  /// [findByIdWithConverter] method instead. Make sure to have specified the [_toJson]
  /// and [_fromJson] methods or else the [FirestoreAPI] will not know how to convert the data to [T].
  Future<FeedbackResponse<Map<String, dynamic>>> findById({
    required String id,
  }) async {
    try {
      _log.info('🔥 Finding ${_collectionPath()} '
          'without converter, '
          'id: $id..');
      final result = (await findDocRef(
        id: id,
      ).get())
          .data();
      if (result != null) {
        _log.success('🔥 Found item!');
        return _responseConfig.searchSuccessResponse(
          isPlural: false,
          result: result,
        );
      } else {
        _log.warning('🔥 Found nothing!');
        return _responseConfig.searchFailedResponse(isPlural: false);
      }
    } catch (error, stackTrace) {
      _log.error(
        '🔥 Unable to find ${_collectionPath()} without converter and id: $id.',
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.searchFailedResponse(isPlural: false);
    }
  }

  /// Finds a document based on given [id].
  ///
  /// This method returns data in the form of type [T]. Make sure to have specified the [_toJson] and
  /// [_fromJson] methods or else the [FirestoreAPI] will not know how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a Map<String, dynamic> consider using
  /// the [findById] method instead.
  Future<FeedbackResponse<T>> findByIdWithConverter({
    required String id,
  }) async {
    try {
      _log.info('🔥 Finding ${_collectionPath()} '
          'with converter, '
          'id: $id..');
      final result = (await findDocRefWithConverter(id: id).get()).data();
      if (result != null) {
        _log.success('🔥 Found item!');
        return _responseConfig.searchSuccessResponse(
            isPlural: false, result: result);
      } else {
        _log.warning('🔥 Found nothing!');
        return _responseConfig.searchFailedResponse(isPlural: false);
      }
    } catch (error, stackTrace) {
      _log.error(
        '🔥 Unable to find ${_collectionPath()} document with converter and id: $id.',
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.searchFailedResponse(isPlural: false);
    }
  }

  /// Finds documents based on a given [searchTerm] and [searchField].
  ///
  /// The [searchTermType] defines the type of field that is specified as [searchField]. You are
  /// able to search a [SearchTermType.startsWith] field for direct hits or for a [SearchTermType.arrayContains]
  /// that may contain the [searchField].
  ///
  /// This method returns raw data in the form of a List<Map<String, dynamic>>. If [_tryAddLocalId] is
  /// true then the map will also contain a local id field based on the [_idFieldName]
  /// specified in the constructor so you may retrieve document id's more easily after deserialization.
  ///
  /// If you rather want to convert this data into a list of [T] immediately you should use the
  /// [findBySearchTermWithConverter] method instead. Make sure to have specified the [_toJson]
  /// and [_fromJson] methods or else the [FirestoreAPI] will not know how to convert the data to [T].
  Future<FeedbackResponse<List<Map<String, dynamic>>>> findBySearchTerm({
    required String searchTerm,
    required String searchField,
    required SearchTermType searchTermType,
    int? limit,
  }) async {
    try {
      _log.info('🔥 Searching ${_collectionPath()} '
          'without converter, '
          'searchTerm: $searchTerm, '
          'searchField: $searchField, '
          'searchTermType: ${searchTermType.name} and '
          'limit: $limit..');
      collectionReferenceQuery(
              CollectionReference<Map<String, dynamic>> collectionReference) =>
          searchTermType.isArray
              ? limit == null
                  ? collectionReference.where(
                      searchField,
                      arrayContainsAny: [searchTerm, ...searchTerm.split(' ')],
                    )
                  : collectionReference.where(
                      searchField,
                      arrayContainsAny: [searchTerm, ...searchTerm.split(' ')],
                    ).limit(limit)
              : limit == null
                  ? collectionReference.where(
                      searchField,
                      isGreaterThanOrEqualTo: searchTerm,
                      isLessThan: '$searchTerm\uf8ff',
                    )
                  : collectionReference
                      .where(
                        searchField,
                        isGreaterThanOrEqualTo: searchTerm,
                        isLessThan: '$searchTerm\uf8ff',
                      )
                      .limit(limit);
      final result = (await collectionReferenceQuery(
        findCollection(),
      ).get())
          .docs
          .map(
            (e) => e.data(),
          )
          .toList();
      _logResultLength(result);
      return _responseConfig.searchSuccessResponse(
        isPlural: result.isPlural,
        result: result,
      );
    } catch (error, stackTrace) {
      _log.error(
        '🔥 '
        'Unable to find ${_collectionPath()} documents with '
        'search term: $searchTerm and '
        'field: $searchField}',
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.searchFailedResponse(isPlural: true);
    }
  }

  /// Finds documents based on a given [searchTerm] and [searchField].
  ///
  /// The [searchTermType] defines the type of field that is specified as [searchField]. You are
  /// able to search a [SearchTermType.startsWith] field for direct hits or for a [SearchTermType.arrayContains]
  /// that may contain the [searchField].
  ///
  /// This method returns data in the form of a list of [T]. Make sure to have specified the
  /// [_toJson] and [_fromJson] methods or else the [FirestoreAPI] will not now how to convert the
  /// data.
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a List<Map<String, dynamic>> consider
  /// using the [findBySearchTerm] method instead.
  Future<FeedbackResponse<List<T>>> findBySearchTermWithConverter({
    required String searchTerm,
    required String searchField,
    required SearchTermType searchTermType,
    int? limit,
  }) async {
    try {
      _log.info('🔥 Searching ${_collectionPath()} '
          'without converter, '
          'searchTerm: $searchTerm, '
          'searchField: $searchField, '
          'searchTermType: ${searchTermType.name} and '
          'limit: $limit..');
      collectionReferenceQuery(CollectionReference<T> collectionReference) =>
          searchTermType.isArray
              ? limit == null
                  ? collectionReference.where(
                      searchField,
                      arrayContainsAny: [searchTerm, ...searchTerm.split(' ')],
                    )
                  : collectionReference.where(
                      searchField,
                      arrayContainsAny: [searchTerm, ...searchTerm.split(' ')],
                    ).limit(limit)
              : limit == null
                  ? collectionReference.where(
                      searchField,
                      isGreaterThanOrEqualTo: searchTerm,
                      isLessThan: '$searchTerm\uf8ff',
                    )
                  : collectionReference
                      .where(
                        searchField,
                        isGreaterThanOrEqualTo: searchTerm,
                        isLessThan: '$searchTerm\uf8ff',
                      )
                      .limit(limit);
      final result = (await collectionReferenceQuery(
        findCollectionWithConverter(),
      ).get())
          .docs
          .map((e) => e.data())
          .toList();
      _logResultLength(result);
      return _responseConfig.searchSuccessResponse(
          isPlural: result.isPlural, result: result);
    } catch (error, stackTrace) {
      _log.error(
          '🔥 '
          'Unable to find ${_collectionPath()} documents with '
          'search term: $searchTerm and '
          'field: $searchField}',
          error: error,
          stackTrace: stackTrace);
      return _responseConfig.searchFailedResponse(isPlural: true);
    }
  }

  /// Finds documents based on a given [collectionReferenceQuery].
  ///
  /// Use the [whereDescription] to describe what your [collectionReferenceQuery] is looking for so that it
  /// shows proper logging in your console.
  ///
  /// This method returns raw data in the form of a List<Map<String, dynamic>>. If [_tryAddLocalId] is
  /// true then the map will also contain a local id field based on the [_idFieldName]
  /// specified in the constructor so you may retrieve document id's more easily after deserialization.
  ///
  /// If you rather want to convert this data into a list of [T] immediately you should use the
  /// [findByQueryWithConverter] method instead. Make sure to have specified the [_toJson]
  /// and [_fromJson] methods or else the [FirestoreAPI] will not know how to convert the data to [T].
  Future<FeedbackResponse<List<Map<String, dynamic>>>> findByQuery({
    required CollectionReferenceQuery<Map<String, dynamic>>
        collectionReferenceQuery,
    required String whereDescription,
  }) async {
    try {
      _log.info('🔥 '
          'Finding ${_collectionPath()} '
          'without converter, with '
          'custom query where $whereDescription..');
      final result = (await collectionReferenceQuery(
        findCollection(),
      ).get())
          .docs
          .map(
            (e) => e.data(),
          )
          .toList();
      _logResultLength(result);
      return _responseConfig.searchSuccessResponse(
        isPlural: result.isPlural,
        result: result,
      );
    } catch (error, stackTrace) {
      _log.error(
        '🔥 '
        'Unable to find ${_collectionPath()} documents without converter, with '
        'custom query where $whereDescription.',
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.searchFailedResponse(isPlural: true);
    }
  }

  /// Finds documents based on a given [searchTerm] and [searchField].
  ///
  /// The [searchTermType] defines the type of field that is specified as [searchField]. You are
  /// able to search a [SearchTermType.startsWith] field for direct hits or for a [SearchTermType.arrayContains]
  /// that may contain the [searchField].
  ///
  /// This method returns data in the form of a list of [T]. Make sure to have specified the
  /// [_toJson] and [_fromJson] methods or else the [FirestoreAPI] will not now how to convert the
  /// data.
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a List<Map<String, dynamic>> consider
  /// using the [findByQuery] method instead.
  Future<FeedbackResponse<List<T>>> findByQueryWithConverter({
    required CollectionReferenceQuery<T> collectionReferenceQuery,
    required String whereDescription,
  }) async {
    try {
      _log.info('🔥 '
          'Finding ${_collectionPath()} '
          'with converter, with '
          'custom query where $whereDescription..');
      final result =
          (await collectionReferenceQuery(findCollectionWithConverter()).get())
              .docs
              .map((e) => e.data())
              .toList();
      _logResultLength(result);
      return _responseConfig.searchSuccessResponse(
          isPlural: result.isPlural, result: result);
    } catch (error, stackTrace) {
      _log.error(
        '🔥 '
        'Unable to find ${_collectionPath()} documents with converter, with '
        'custom query where $whereDescription.',
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.searchFailedResponse(isPlural: true);
    }
  }

  /// Finds all documents of the specified [_collectionPath].
  ///
  /// This method returns raw data in the form of a List<Map<String, dynamic>>. If [_tryAddLocalId] is
  /// true then the map will also contain a local id field based on the [_idFieldName]
  /// specified in the constructor so you may retrieve document id's more easily after deserialization.
  ///
  /// If you rather want to convert this data into a list of [T] immediately you should use the
  /// [findAllWithConverter] method instead. Make sure to have specified the [_toJson]
  /// and [_fromJson] methods or else the [FirestoreAPI] will not know how to convert the data to [T].
  Future<FeedbackResponse<List<Map<String, dynamic>>>> findAll() async {
    try {
      _log.info('🔥 Finding all ${_collectionPath()} '
          'without converter..');
      final result = (await findCollection().get())
          .docs
          .map(
            (e) => e.data(),
          )
          .toList();
      _logResultLength(result);
      return _responseConfig.searchSuccessResponse(
          isPlural: result.isPlural, result: result);
    } catch (error, stackTrace) {
      _log.error(
          '🔥 Unable to find ${_collectionPath()} all documents per findAll query',
          error: error,
          stackTrace: stackTrace);
      return _responseConfig.searchFailedResponse(isPlural: true);
    }
  }

  /// Finds all documents of the specified [_collectionPath].
  ///
  /// This method returns data in the form of a list of [T]. Make sure to have specified the
  /// [_toJson] and [_fromJson] methods or else the [FirestoreAPI] will not now how to convert the
  /// data.
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a List<Map<String, dynamic>> consider
  /// using the [findAll] method instead.
  Future<FeedbackResponse<List<T>>> findAllWithConverter() async {
    try {
      _log.info('🔥 Finding all ${_collectionPath()} '
          'with converter..');
      final result = (await findCollectionWithConverter().get())
          .docs
          .map((e) => e.data())
          .toList();
      _logResultLength(result);
      return _responseConfig.searchSuccessResponse(
          isPlural: result.isPlural, result: result);
    } catch (error, stackTrace) {
      _log.error(
          '🔥 Unable to find ${_collectionPath()} all documents per findAll query',
          error: error,
          stackTrace: stackTrace);
      return _responseConfig.searchFailedResponse(isPlural: true);
    }
  }

  /// Helper method for logging the length of a List result.
  void _logResultLength(List<dynamic> result) {
    if (result.isNotEmpty) {
      _log.success('🔥 Found ${result.length} item(s)!');
    } else {
      _log.warning('🔥 Found 0 items!');
    }
  }

  /// Creates/writes data based on given [writeable].
  ///
  /// Passing in an [id] will give your document that [id].
  ///
  /// Passing in a [writeBatch] will close the [WriteBatch] and perform the last commit. If you want
  /// to add more to your [WriteBatch] then use the [batchCreate] method instead.
  ///
  /// The [createTimeStampType] determines the type of automatically added [_createdFieldName] and/or
  /// [_updatedFieldName] field(s) of [Timestamp] when [merge] is false. Pass in a [TimestampType.none]
  /// to avoid any of this automatic behaviour.
  ///
  /// The [updateTimeStampType] determines the type of automatically added [_createdFieldName] and/or
  /// [_updatedFieldName] field(s) of [Timestamp] when [merge] is true or [mergeFields] != null.
  /// Pass in a [TimestampType.none] to avoid any of this automatic behaviour.
  ///
  /// When [merge] is true this method will attempt an upsert if the document exists. If the
  /// document does not exist it will default to a regular create.
  ///
  /// If [addIdAsField] is true it will automatically add the ID (given as [id] or generated) as a
  /// field to your document. The field name will be what's specified in [_idFieldName].
  ///
  /// If [removeLocalId] is true and [addIdAsField] is false, then it will attempt to remove any
  /// local [_idFieldName] from the [writeable].
  ///
  /// The [mergeFields] determine which fields to upsert, leave blank to upsert the entire object.
  Future<FeedbackResponse<DocumentReference>> create({
    required Writeable writeable,
    String? id,
    WriteBatch? writeBatch,
    TimestampType createTimeStampType = TimestampType.createdAndUpdated,
    TimestampType updateTimeStampType = TimestampType.updated,
    bool merge = false,
    bool addIdAsField = false,
    bool removeLocalId = false,
    List<FieldPath>? mergeFields,
  }) async {
    try {
      _log.info('🔥 Checking if writeable is valid..');
      final isValidResponse = writeable.isValidResponse();
      if (isValidResponse.isSuccess) {
        _log.success('🔥 Writeable is valid!');
        _log.info(
          '🔥 '
          'Creating ${_collectionPath()} document with '
          'writeable: $writeable, '
          'id: $id, '
          'writeBatch: $writeBatch, '
          'createTimeStampType: ${createTimeStampType.name}, '
          'updateTimeStampType: ${updateTimeStampType.name}, '
          'merge: $merge, '
          'addIdAsAField: $addIdAsField, '
          'mergeFields: $mergeFields..',
        );
        final DocumentReference documentReference;
        if (writeBatch != null) {
          _log.info('🔥 WriteBatch was not null! Creating with batch..');
          final lastBatchResponse = await batchCreate(
            writeable: writeable,
            id: id,
            writeBatch: writeBatch,
            createTimeStampType: createTimeStampType,
            updateTimeStampType: updateTimeStampType,
            addIdAsField: addIdAsField,
          );
          _log.info('🔥 Checking if batchCreate was successful..');
          if (lastBatchResponse.isSuccess) {
            final writeBatchWithReference = lastBatchResponse.result!;
            _log.info('🔥 Last batch was added with success! Committing..');
            await writeBatchWithReference.writeBatch.commit();
            _log.success('🔥 Committing writeBatch done!');
            documentReference = writeBatchWithReference.documentReference;
          } else {
            _log.error('🔥 Last batch failed!');
            return _responseConfig.createFailedResponse(isPlural: true);
          }
        } else {
          _log.info('🔥 WriteBatch was null! Creating without batch..');
          documentReference =
              id != null ? findDocRef(id: id) : findCollection().doc();
          _log.value(documentReference.id, '🔥 Document ID');
          _log.info('🔥 Creating JSON..');
          final writeableAsJson = (merge || mergeFields != null) &&
                  (await documentReference.get()).exists
              ? updateTimeStampType.add(
                  writeable.toJson(),
                  updatedFieldName: _updatedFieldName,
                )
              : createTimeStampType.add(
                  writeable.toJson(),
                  createdFieldName: _createdFieldName,
                  updatedFieldName: _updatedFieldName,
                );
          if (addIdAsField) {
            writeableAsJson.withId(
              documentReference.id,
              idFieldName: _idFieldName,
            );
          } else if (removeLocalId) {
            writeableAsJson.tryRemoveLocalId(idFieldName: _idFieldName);
          }
          _log.value(writeableAsJson, '🔥 JSON');
          _log.info('🔥 Setting data with documentReference.set..');
          await documentReference.set(
            writeableAsJson,
            SetOptions(
              merge: mergeFields == null ? merge : null,
              mergeFields: mergeFields,
            ),
          );
        }
        _log.success('🔥 Setting data done!');
        return _responseConfig.createSuccessResponse(
            isPlural: writeBatch != null, result: documentReference);
      }
      _log.warning('🔥 Writeable was invalid!');
      return FeedbackResponse.error(
          title: isValidResponse.title, message: isValidResponse.message);
    } catch (error, stackTrace) {
      _log.error(
        '🔥 '
        'Unable to create ${_collectionPath()} document with '
        'writeable: $writeable, '
        'id: $id, '
        'writeBatch: $writeBatch, '
        'createTimeStampType: ${createTimeStampType.name}, '
        'updateTimeStampType: ${updateTimeStampType.name}, '
        'merge: $merge, '
        'addIdAsAField: $addIdAsField, '
        'mergeFields: $mergeFields..',
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.createFailedResponse(isPlural: writeBatch != null);
    }
  }

  /// Batch creates/writes data based on given [writeable].
  ///
  /// Passing in an [id] will give your document that [id].
  ///
  /// Passing in a [writeBatch] will use that batch to add to it. If no batch is provided this
  /// method will create and return one.
  ///
  /// The [createTimeStampType] determines the type of automatically added [_createdFieldName] and/or
  /// [_updatedFieldName] field(s) of [Timestamp] when [merge] is false. Pass in a [TimestampType.none]
  /// to avoid any of this automatic behaviour.
  ///
  /// The [updateTimeStampType] determines the type of automatically added [_createdFieldName] and/or
  /// [_updatedFieldName] field(s) of [Timestamp] when [merge] is true or [mergeFields] != null.
  /// Pass in a [TimestampType.none] to avoid any of this automatic behaviour.
  ///
  /// When [merge] is true this method will attempt an upsert if the document exists. If the
  /// document does not exist it will default to a regular create.
  ///
  /// If [addIdAsField] is true it will automatically add the ID (given as [id] or generated) as a
  /// field to your document. The field name will be what's specified in [_idFieldName].
  ///
  /// The [mergeFields] determine which fields to upsert, leave blank to upsert the entire object.
  Future<FeedbackResponse<WriteBatchWithReference?>> batchCreate({
    required Writeable writeable,
    String? id,
    WriteBatch? writeBatch,
    TimestampType createTimeStampType = TimestampType.createdAndUpdated,
    TimestampType updateTimeStampType = TimestampType.updated,
    bool merge = false,
    bool addIdAsField = false,
    List<FieldPath>? mergeFields,
  }) async {
    try {
      final isValidResponse = writeable.isValidResponse();
      if (isValidResponse.isSuccess) {
        _log.success('🔥 Writeable is valid!');
        _log.info(
          '🔥 '
          'Batch creating ${_collectionPath()} document with '
          'writeable: $writeable, '
          'id: $id, '
          'writeBatch: $writeBatch, '
          'createTimeStampType: ${createTimeStampType.name}, '
          'updateTimeStampType: ${updateTimeStampType.name}, '
          'merge: $merge, '
          'addIdAsAField: $addIdAsField, '
          'mergeFields: $mergeFields..',
        );
        final nullSafeWriteBatch = writeBatch ?? this.writeBatch;
        final documentReference =
            id != null ? findDocRef(id: id) : findCollection().doc();
        _log.value(documentReference.id, '🔥 Document ID');
        _log.info('🔥 Creating JSON..');
        final writeableAsJson = (merge || mergeFields != null) &&
                (await documentReference.get()).exists
            ? updateTimeStampType.add(
                writeable.toJson(),
                updatedFieldName: _updatedFieldName,
              )
            : createTimeStampType.add(
                writeable.toJson(),
                createdFieldName: _createdFieldName,
                updatedFieldName: _updatedFieldName,
              );
        if (addIdAsField) {
          writeableAsJson.withId(
            documentReference.id,
            idFieldName: _idFieldName,
          );
        }
        _log.value(writeableAsJson, '🔥 JSON');
        _log.info('🔥 Setting data with writeBatch.set..');
        nullSafeWriteBatch.set(
          documentReference,
          writeableAsJson,
          SetOptions(
            merge: mergeFields == null ? merge : null,
            mergeFields: mergeFields,
          ),
        );
        _log.success(
            '🔥 Adding create to batch done! Returning WriteBatchWithReference..');
        return FeedbackResponse.successNone(
          result: WriteBatchWithReference(
            writeBatch: nullSafeWriteBatch,
            documentReference: documentReference,
          ),
        );
      }
      _log.warning('🔥 Writeable was invalid!');
      return FeedbackResponse.error(
          title: isValidResponse.title, message: isValidResponse.message);
    } catch (error, stackTrace) {
      _log.error(
        '🔥 '
        'Unable to create ${_collectionPath()} document with '
        'writeable: $writeable, '
        'id: $id, '
        'writeBatch: $writeBatch, '
        'createTimeStampType: ${createTimeStampType.name}, '
        'updateTimeStampType: ${updateTimeStampType.name}, '
        'merge: $merge, '
        'addIdAsAField: $addIdAsField, '
        'mergeFields: $mergeFields..',
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.createFailedResponse(isPlural: true);
    }
  }

  /// Updates data based on given [writeable] and [id].
  ///
  /// Passing in a [writeBatch] will close the [WriteBatch] and perform the last commit. If you want
  /// to add more to your [WriteBatch] then use the [batchUpdate] method instead.
  ///
  /// The [timestampType] determines the type of automatically added [_createdFieldName] and/or
  /// [_updatedFieldName] field(s) of [Timestamp]. Pass in a [TimestampType.none] to avoid any of
  /// this automatic behaviour.
  Future<FeedbackResponse<DocumentReference>> update({
    required Writeable writeable,
    required String id,
    WriteBatch? writeBatch,
    TimestampType timestampType = TimestampType.updated,
  }) async {
    try {
      _log.info('🔥 Checking if writeable is valid..');
      final isValidResponse = writeable.isValidResponse();
      if (isValidResponse.isSuccess) {
        _log.success('🔥 Writeable is valid!');
        _log.info('🔥 '
            'Updating ${_collectionPath()} document with '
            'writeable: $writeable, '
            'id: $id, '
            'writeBatch: $writeBatch, '
            'timestampType: ${timestampType.name}..');
        final DocumentReference documentReference;
        if (writeBatch != null) {
          _log.info('🔥 WriteBatch was not null! Updating with batch..');
          final lastBatchResponse = await batchUpdate(
            writeable: writeable,
            id: id,
            writeBatch: writeBatch,
            timestampType: timestampType,
          );
          _log.info('🔥 Checking if batchUpdate was successful..');
          if (lastBatchResponse.isSuccess) {
            final writeBatchWithReference = lastBatchResponse.result!;
            _log.info('🔥 Last batch was added with success! Committing..');
            await writeBatchWithReference.writeBatch.commit();
            _log.success('🔥 Committing writeBatch done!');
            documentReference = writeBatchWithReference.documentReference;
          } else {
            _log.error('🔥 Last batch failed!');
            return _responseConfig.updateFailedResponse(isPlural: true);
          }
        } else {
          _log.info('🔥 WriteBatch was null! Updating without batch..');
          documentReference = findDocRef(id: id);
          _log.value(documentReference.id, '🔥 Document ID');
          _log.info('🔥 Creating JSON..');
          final writeableAsJson = timestampType.add(
            writeable.toJson(),
            createdFieldName: _createdFieldName,
            updatedFieldName: _updatedFieldName,
          );
          _log.value(writeableAsJson, 'JSON');
          _log.info('🔥 Updating data with documentReference.update..');
          await documentReference.update(writeableAsJson);
        }
        _log.success('🔥 Updating data done!');
        return _responseConfig.updateSuccessResponse(
            isPlural: writeBatch != null, result: documentReference);
      }
      _log.warning('🔥 Writeable was invalid!');
      return FeedbackResponse.error(
          title: isValidResponse.title, message: isValidResponse.message);
    } catch (error, stackTrace) {
      _log.error(
        '🔥 '
        'Unable to update ${_collectionPath()} document with '
        'writeable: $writeable, '
        'id: $id, '
        'writeBatch: $writeBatch, '
        'timeStampType: ${timestampType.name}..',
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.updateFailedResponse(isPlural: writeBatch != null);
    }
  }

  /// Batch updates data based on given [writeable] and [id].
  ///
  /// Passing in a [writeBatch] will use that batch to add to it. If no batch is provided this
  /// method will create and return one.
  ///
  /// The [timestampType] determines the type of automatically added [_createdFieldName] and/or
  /// [_updatedFieldName] field(s) of [Timestamp]. Pass in a [TimestampType.none] to avoid any of
  /// this automatic behaviour.
  Future<FeedbackResponse<WriteBatchWithReference?>> batchUpdate({
    required Writeable writeable,
    required String id,
    WriteBatch? writeBatch,
    TimestampType timestampType = TimestampType.updated,
  }) async {
    final isValidResponse = writeable.isValidResponse();
    try {
      if (isValidResponse.isSuccess) {
        _log.success('🔥 Writeable is valid!');
        _log.info('🔥 Batch updating ${_collectionPath()} document with '
            'writeable: $writeable, '
            'id: $id, '
            'writeBatch: $writeBatch, '
            'timestampType: ${timestampType.name}..');
        final nullSafeWriteBatch = writeBatch ?? this.writeBatch;
        final documentReference = findDocRef(id: id);
        _log.value(documentReference.id, '🔥 Document ID');
        _log.info('🔥 Creating JSON..');
        final writeableAsJson = timestampType.add(
          writeable.toJson(),
          createdFieldName: _createdFieldName,
          updatedFieldName: _updatedFieldName,
        );
        _log.value(writeableAsJson, '🔥 JSON');
        _log.info('🔥 Updating data with writeBatch.update..');
        nullSafeWriteBatch.update(
          documentReference,
          writeableAsJson,
        );
        _log.success(
            '🔥 Adding update to batch done! Returning WriteBatchWithReference..');
        return FeedbackResponse.successNone(
          result: WriteBatchWithReference(
            writeBatch: nullSafeWriteBatch,
            documentReference: documentReference,
          ),
        );
      }
      _log.warning('🔥 Writeable was invalid!');
      return FeedbackResponse.error(
          title: isValidResponse.title, message: isValidResponse.message);
    } catch (error, stackTrace) {
      _log.error(
        '🔥 Unable to batch update ${_collectionPath()} document with id: $id',
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.updateFailedResponse(isPlural: writeBatch != null);
    }
  }

  /// Deletes data based on given [id].
  ///
  /// Passing in a [writeBatch] will close the [WriteBatch] and perform the last commit. If you want
  /// to add more to your [WriteBatch] then use the [batchDelete] method instead.
  Future<FeedbackResponse<void>> delete({
    required String id,
    WriteBatch? writeBatch,
  }) async {
    try {
      _log.info('🔥 Deleting ${_collectionPath()} document with '
          'id: $id, '
          'writeBatch: $writeBatch..');
      final DocumentReference documentReference;
      if (writeBatch != null) {
        _log.info('🔥 WriteBatch was not null! Deleting with batch..');
        final lastBatchResponse = await batchDelete(
          id: id,
          writeBatch: writeBatch,
        );
        _log.info('🔥 Checking if batchDelete was successful..');
        if (lastBatchResponse.isSuccess) {
          final lastBatch = lastBatchResponse.result!;
          _log.info('🔥 Last batch was added with success! Committing..');
          await lastBatch.writeBatch.commit();
          _log.success('🔥 Committing writeBatch done!');
          documentReference = lastBatch.documentReference;
        } else {
          _log.error('🔥 Last batch failed!');
          return _responseConfig.deleteFailedResponse(isPlural: true);
        }
      } else {
        _log.info('🔥 WriteBatch was null! Deleting without batch..');
        documentReference = findDocRef(id: id);
        _log.value(documentReference.id, '🔥 Document ID');
        _log.info('🔥 Deleting data with documentReference.delete..');
        await documentReference.delete();
      }
      _log.success('🔥 Deleting data done!');
      return _responseConfig.deleteSuccessResponse(
          isPlural: writeBatch != null);
    } catch (error, stackTrace) {
      _log.error('🔥 Unable to update ${_collectionPath()} document',
          error: error, stackTrace: stackTrace);
      return _responseConfig.deleteFailedResponse(isPlural: writeBatch != null);
    }
  }

  /// Batch deletes data based on given [id].
  ///
  /// Passing in a [writeBatch] will use that batch to add to it. If no batch is provided this
  /// method will create and return one.
  Future<FeedbackResponse<WriteBatchWithReference?>> batchDelete({
    required String id,
    WriteBatch? writeBatch,
  }) async {
    try {
      _log.info('🔥 Batch deleting ${_collectionPath()} document with '
          'id: $id, '
          'writeBatch: $writeBatch..');
      final nullSafeWriteBatch = writeBatch ?? this.writeBatch;
      final documentReference = findDocRef(id: id);
      _log.value(documentReference.id, '🔥 Document ID');
      _log.info('🔥 Deleting data with writeBatch.delete..');
      nullSafeWriteBatch.delete(documentReference);
      _log.success(
          '🔥 Adding delete to batch done! Returning WriteBatchWithReference..');
      return FeedbackResponse.successNone(
        result: WriteBatchWithReference(
          writeBatch: nullSafeWriteBatch,
          documentReference: documentReference,
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🔥 Unable to batch delete ${_collectionPath()} document with id: $id',
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.deleteFailedResponse(isPlural: writeBatch != null);
    }
  }

  /// Finds a [CollectionReference] of type [T] based on specified [_collectionPath].
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreAPI]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a List<Map<String, dynamic>> consider
  /// using the [findCollection] method instead.
  CollectionReference<T> findCollectionWithConverter() {
    _log.info(
        '🔥 Finding ${_collectionPath()} CollectionReference with converter..');
    return _firebaseFirestore.collection(_collectionPath()).withConverter<T>(
          fromFirestore: _tryAddLocalId
              ? (snapshot, _) => _fromJson!(
                    (snapshot.data() ?? {}).tryAddLocalId(
                      snapshot.id,
                      idFieldName: _idFieldName,
                    ),
                  )
              : (snapshot, _) => _fromJson!((snapshot.data() ?? {})),
          toFirestore: (value, _) => _toJson!(value),
        );
  }

  /// Finds a [Query] of type [T] based on specified [_collectionPath].
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreAPI]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a List<Map<String, dynamic>> consider
  /// using the [findCollectionGroup] method instead.
  Query<T> findCollectionGroupWithConverter() {
    _log.info('🔥 Finding ${_collectionPath()} Query with converter..');
    return _firebaseFirestore
        .collectionGroup(_collectionPath())
        .withConverter<T>(
          fromFirestore: _tryAddLocalId
              ? (snapshot, _) => _fromJson!(
                    (snapshot.data() ?? {}).tryAddLocalId(
                      snapshot.id,
                      idFieldName: _idFieldName,
                    ),
                  )
              : (snapshot, _) => _fromJson!((snapshot.data() ?? {})),
          toFirestore: (value, _) => _toJson!(value),
        );
  }

  /// Finds a [DocumentReference] of type [T] based on given [id].
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreAPI]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a Map<String, dynamic> consider
  /// using the [findDocRef] method instead.
  DocumentReference<T> findDocRefWithConverter({required String id}) {
    _log.info(
        '🔥 Finding ${_collectionPath()} DocumentReference with converter and id: $id..');
    return _firebaseFirestore.doc('${_collectionPath()}/$id').withConverter<T>(
          fromFirestore: _tryAddLocalId
              ? (snapshot, _) => _fromJson!(
                    (snapshot.data() ?? {}).tryAddLocalId(
                      snapshot.id,
                      idFieldName: _idFieldName,
                    ),
                  )
              : (snapshot, _) => _fromJson!((snapshot.data() ?? {})),
          toFirestore: (value, _) => _toJson!(value),
        );
  }

  /// Finds a [DocumentSnapshot] of type [T] based on given [id].
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreAPI]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a Map<String, dynamic> consider
  /// using the [findDocSnapshot] method instead.
  Future<DocumentSnapshot<T>> findDocSnapshotWithConverter({
    required String id,
  }) async {
    final docRefWithConverter = findDocRefWithConverter(id: id);
    _log.info(
        '🔥 Finding ${_collectionPath()} DocumentSnapshot with converter and id: $id..');
    return docRefWithConverter.get();
  }

  /// Finds a [Stream] of list of [T] based on specified [_collectionPath] (all documents).
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreAPI]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a List<Map<String, dynamic>> consider
  /// using the [findStream] method instead.
  Stream<List<T>> findStreamWithConverter() {
    _log.info(
        '🔥 Finding ${_collectionPath()} Collection Stream with converter..');
    return !_isCollectionGroup
        ? findCollectionWithConverter().snapshots().map(
              (event) => event.docs.map((e) => e.data()).toList(),
            )
        : findCollectionGroupWithConverter().snapshots().map(
              (event) => event.docs.map((e) => e.data()).toList(),
            );
  }

  /// Finds a [Stream] of list of [T] based on given [collectionReferenceQuery] and [whereDescription].
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreAPI]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a List<Map<String, dynamic>> consider
  /// using the [findStreamByQuery] method instead.
  Stream<List<T>> findStreamByQueryWithConverter({
    CollectionReferenceQuery<T>? collectionReferenceQuery,
    CollectionGroupQuery<T>? collectionGroupQuery,
    required String whereDescription,
  }) {
    assert((collectionGroupQuery != null) == _isCollectionGroup,
        'Use a collectionGroupQuery when working with a collection group.');
    _log.info(
        '🔥 Finding ${_collectionPath()} Stream with converter where $whereDescription..');
    return !_isCollectionGroup
        ? collectionReferenceQuery!(findCollectionWithConverter())
            .snapshots()
            .map(
              (event) => event.docs.map((e) => e.data()).toList(),
            )
        : collectionGroupQuery!(findCollectionGroupWithConverter())
            .snapshots()
            .map(
              (event) => event.docs.map((e) => e.data()).toList(),
            );
  }

  /// Finds a [Stream] of type [T] based on given [id].
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreAPI]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a Map<String, dynamic> consider
  /// using the [findDocStream] method instead.
  Stream<T?> findDocStreamWithConverter({
    required String id,
  }) {
    final docRefWithConverter = findDocRefWithConverter(id: id);
    _log.info(
        '🔥 Finding ${_collectionPath()} DocumentReference Stream with converter and id: $id..');
    return docRefWithConverter.snapshots().map((e) => e.data());
  }

  /// Finds a [CollectionReference] of type Map<String, dynamic> based on specified [_collectionPath].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor.
  ///
  /// If you rather want to retrieve data in the form of [T] consider
  /// using the [findCollectionWithConverter] method instead.
  CollectionReference<Map<String, dynamic>> findCollection() {
    _log.info(
        '🔥 Finding ${_collectionPath()} CollectionReference without converter..');
    return _tryAddLocalId
        ? _firebaseFirestore
            .collection(_collectionPath())
            .withConverter<Map<String, dynamic>>(
              fromFirestore: (snapshot, _) =>
                  (snapshot.data() ?? {}).tryAddLocalId(
                snapshot.id,
                idFieldName: _idFieldName,
              ),
              toFirestore: (value, _) => value,
            )
        : _firebaseFirestore.collection(_collectionPath());
  }

  /// Finds a [Query] of type Map<String, dynamic> based on specified [_collectionPath].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor.
  ///
  /// If you rather want to retrieve data in the form of [T] consider
  /// using the [findCollectionGroupWithConverter] method instead.
  Query<Map<String, dynamic>> findCollectionGroup() {
    _log.info('🔥 Finding ${_collectionPath()} Query with converter..');
    return _firebaseFirestore
        .collectionGroup(_collectionPath())
        .withConverter<Map<String, dynamic>>(
          fromFirestore: _tryAddLocalId
              ? (snapshot, _) => (snapshot.data() ?? {}).tryAddLocalId(
                    snapshot.id,
                    idFieldName: _idFieldName,
                  )
              : (snapshot, _) => (snapshot.data() ?? {}),
          toFirestore: (value, _) => value,
        );
  }

  /// Finds a [DocumentReference] of type Map<String, dynamic> based on given [id].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the form of [T] consider using the
  /// [findDocRefWithConverter] method instead.
  DocumentReference<Map<String, dynamic>> findDocRef({
    required String id,
  }) {
    _log.info(
        '🔥 Finding ${_collectionPath()} DocumentReference without converter and id: $id..');
    return _tryAddLocalId
        ? _firebaseFirestore
            .doc('${_collectionPath()}/$id')
            .withConverter<Map<String, dynamic>>(
              fromFirestore: (snapshot, _) =>
                  (snapshot.data() ?? {}).tryAddLocalId(
                snapshot.id,
                idFieldName: _idFieldName,
              ),
              toFirestore: (value, _) => value,
            )
        : _firebaseFirestore.doc('${_collectionPath()}/$id');
  }

  /// Finds a [DocumentSnapshot] of type Map<String, dynamic> based on given [id].
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreAPI]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the form of [T] consider using the
  /// [findDocSnapshotWithConverter] method instead.
  Future<DocumentSnapshot<Map<String, dynamic>>> findDocSnapshot({
    required String id,
  }) async {
    final docRef = findDocRef(id: id);
    _log.info(
        '🔥 Finding ${_collectionPath()} DocumentSnapshot without converter and id: $id..');
    return docRef.get();
  }

  /// Finds a [Stream] of List<Map<String, dynamic>> based on specified [_collectionPath] (all documents).
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the form of list of [T] consider using the
  /// [findStreamWithConverter] method instead.
  Stream<QuerySnapshot<Map<String, dynamic>>> findStream() {
    _log.info(
        '🔥 Finding ${_collectionPath()} CollectionReference Stream without converter..');
    return !_isCollectionGroup
        ? findCollection().snapshots()
        : findCollectionGroup().snapshots();
  }

  /// Finds a [Stream] of List<Map<String, dynamic>> based on given [collectionReferenceQuery] and [whereDescription].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the form of list of [T] consider using the
  /// [findStreamByQueryWithConverter] method instead.
  Stream<List<Map<String, dynamic>>> findStreamByQuery({
    required CollectionReferenceQuery<Map<String, dynamic>>?
        collectionReferenceQuery,
    CollectionGroupQuery<Map<String, dynamic>>? collectionGroupQuery,
    required String whereDescription,
  }) {
    assert((collectionGroupQuery != null) == _isCollectionGroup,
        'Use a collectionGroupQuery when working with a collection group.');
    _log.info(
        '🔥 Finding ${_collectionPath()} Stream without converter where $whereDescription..');
    return !_isCollectionGroup
        ? collectionReferenceQuery!(findCollection()).snapshots().map(
              (event) => event.docs.map((e) => e.data()).toList(),
            )
        : collectionGroupQuery!(findCollectionGroup()).snapshots().map(
              (event) => event.docs.map((e) => e.data()).toList(),
            );
  }

  /// Finds a [Stream] of type Map<String, dynamic> based on given [id].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If you rather want to retrieve data in the form of [T] consider using the
  /// [findDocStreamWithConverter] method instead.
  Stream<DocumentSnapshot<Map<String, dynamic>>> findDocStream({
    required String id,
  }) {
    final docRef = findDocRef(id: id);
    _log.info(
        '🔥 Finding ${_collectionPath()} DocumentReference Stream without converter and id: $id..');
    return docRef.snapshots();
  }

  /// Used to determined if a document exists based on given [id].
  Future<bool> docExists({
    required String id,
  }) async {
    final docRef = findDocRef(id: id);
    _log.info('🔥 Checking if document exists with id: $id');
    return (await docRef.get()).exists;
  }

  /// Helper method to fetch a [WriteBatch] from [_firebaseFirestore]..
  WriteBatch get writeBatch => _firebaseFirestore.batch();
}
