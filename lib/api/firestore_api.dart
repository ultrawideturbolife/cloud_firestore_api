import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_api/data/enums/sensitive_log_level.dart';
import 'package:cloud_firestore_api/data/exceptions/invalid_json_exception.dart';
import 'package:cloud_firestore_api/data/models/sensitive_data.dart';
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
    Query<T> collectionReference);

/// Used to perform all Firestore related CRUD tasks and a little bit more.
class FirestoreApi<T extends Object> {
  /// The [FirestoreApi] requires only a [firebaseFirestore] instance and a [collectionPath] to
  /// work initially.
  ///
  /// If you are interested in using the 'WithConverter' methods that automatically convert your
  /// data to specific models of [T] then define both the [toJson] and [fromJson].
  ///
  /// If [tryAddLocalId] is true then your data will have an id field added based on the
  /// [idFieldName]. Add this id field to the model you're serializing to and you
  /// will have easy access to the document id at any time. Any create or update method will by
  /// default try te remove the field again before writing to Firestore (unless specified otherwise
  /// inside the method).
  ///
  /// If you are interested in providing custom feedback to your users then provide your own
  /// instance of the [feedbackConfig]. This config contains specific feedback messages regarding
  /// successful and unsuccessful CRUD operations of a certain collection.
  ///
  /// The [firestoreLogger] is used to provide proper logging when performing any operation inside
  /// the [FirestoreApi]. Implement your own version in order to use to use your own logging system.
  FirestoreApi({
    required FirebaseFirestore firebaseFirestore,
    required String Function() collectionPath,
    Map<String, dynamic> Function(T value)? toJson,
    T Function(Map<String, dynamic> json)? fromJson,
    T Function(Map<String, dynamic> json)? fromJsonError,
    bool tryAddLocalId = false,
    FeedbackConfig feedbackConfig = const FeedbackConfig(),
    FirestoreLogger firestoreLogger = const FirestoreDefaultLogger(),
    String createdFieldName = 'created',
    String updatedFieldName = 'updated',
    String idFieldName = 'id',
    String documentReferenceFieldName = 'documentReference',
    bool isCollectionGroup = false,
    bool tryAddLocalDocumentReference = false,
    GetOptions? getOptions,
    bool logSensitiveData = true,
    SensitiveLogLevel sensitiveLogLevel = SensitiveLogLevel.info,
  })  : _firebaseFirestore = firebaseFirestore,
        _collectionPath = collectionPath,
        _toJson = toJson,
        _fromJson = fromJson,
        _fromJsonError = fromJsonError,
        _tryAddLocalId = tryAddLocalId,
        _responseConfig = feedbackConfig.responseConfig,
        _log = firestoreLogger,
        _createdFieldName = createdFieldName,
        _updatedFieldName = updatedFieldName,
        _idFieldName = idFieldName,
        _documentReferenceFieldName = documentReferenceFieldName,
        _isCollectionGroup = isCollectionGroup,
        _tryAddLocalDocumentReference = tryAddLocalDocumentReference,
        _getOptions = getOptions,
        _sensitiveLogLevel = sensitiveLogLevel;

  /// Whether to include sensitive data in logging.
  final SensitiveLogLevel _sensitiveLogLevel;

  /// Used to performs Firestore operations.
  final FirebaseFirestore _firebaseFirestore;

  /// Used to find the Firestore collection.
  final String Function() _collectionPath;

  /// Used to serialize your data to JSON when using 'WithConverter' methods.
  final Map<String, dynamic> Function(T value)? _toJson;

  /// Used to deserialize your data to JSON when using 'WithConverter' methods.
  final T Function(Map<String, dynamic> json)? _fromJson;

  /// Used to deserialize your data to JSON when using 'WithConverter' methods and a data error occurs.
  ///
  /// Use this to create a default object to show to the user in case parsing your data goes wrong.
  /// This is especially useful when you are working with iterables of the same type.
  /// Because now when an error occurs it will use a default object and parsing of the other objects
  /// that have no errors can continue. Whereas before it would just throw an error and stop parsing.
  final T Function(Map<String, dynamic> json)? _fromJsonError;

  /// Used to add an id field to any of your local Firestore data (so not actually in Firestore).
  ///
  /// If this is true then your data will have an id field added based on the [_idFieldName]
  /// specified in the constructor. Add this id field to the model you're serializing to and you

  /// will have easy access to the document id at any time. Any create or update method will by
  /// default try te remove the field again before writing to Firestore (unless specified otherwise).
  ///
  /// Setting this to true will also try to remove the field when deserializing.
  final bool _tryAddLocalId;

  /// Used to add a [DocumentReference] field to any of your local Firestore data (so not actually in Firestore).
  ///
  /// If this is true then your data will have an id field added based on the [_idFieldName]
  /// specified in the constructor. Add this id field to the model you're serializing to and you
  /// will have easy access to the document id at any time. Any create or update method will by
  /// default try te remove the field again before writing to Firestore (unless specified otherwise).
  ///
  /// Setting this to true will also try to remove the field when deserializing.
  final bool _tryAddLocalDocumentReference;

  /// Used to create responses from the configured [FeedbackConfig].
  final ResponseGenerator _responseConfig;

  /// Used to provide proper logging when performing any operation inside the [FirestoreApi].
  final FirestoreLogger _log;

  /// Used to provide a default 'created' field based on the provided [TimestampType] of create methods.
  final String _createdFieldName;

  /// Used to provide a default 'updated' field based on the provided [TimestampType] of update methods.
  final String _updatedFieldName;

  /// Used to provide an id field to your create/update methods if necessary.
  ///
  /// May also be used to provide an id field to your data from Firestore when fetching data.
  final String _idFieldName;

  /// Used to provide a reference field to your create/update methods if necessary.
  ///
  /// May also be used to provide an id field to your data from Firestore when fetching data.
  final String _documentReferenceFieldName;

  /// Whether the [_collectionPath] refers to a collection group.
  final bool _isCollectionGroup;

  /// An options class that configures the behavior of get() calls on [DocumentReference] and [Query].
  final GetOptions? _getOptions;

  /// Whether to exclude sensitive data in info logging.
  bool get _shouldNotSensitiveInfo => _sensitiveLogLevel.shouldNotInfo;

  /// Whether to exclude sensitive data in warning logging.
  bool get _shouldNotSensitiveWarning => _sensitiveLogLevel.shouldNotWarning;

  /// Whether to exclude sensitive data in error logging.
  bool get _shouldNotSensitiveError => _sensitiveLogLevel.shouldNotError;

  /// Finds a document based on given [id].
  ///
  /// This method returns raw data in the form of a Map<String, dynamic>. If [_tryAddLocalId] is
  /// true then the map will also contain a local id field based on the [_idFieldName]
  /// specified in the constructor so you may retrieve document id's more easily after serialization.
  ///
  /// If you rather want to convert this data into [T] immediately you should use the
  /// [findByIdWithConverter] method instead. Make sure to have specified the [_toJson]
  /// and [_fromJson] methods or else the [FirestoreApi] will not know how to convert the data to [T].
  Future<FeedbackResponse<Map<String, dynamic>>> findById({
    required String id,
    String? collectionPathOverride,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    try {
      _log.info(
        message: 'Finding without converter..',
        sensitiveData: _shouldNotSensitiveInfo
            ? null
            : SensitiveData(
                path: collectionPathOverride ?? _collectionPath(),
                id: id,
              ),
      );
      final result = (await findDocRef(
        id: id,
        collectionPathOverride: collectionPathOverride,
      ).get(_getOptions))
          .data();
      if (result != null) {
        _log.success(
          message: 'Found item!',
          sensitiveData: null,
        );
        return _responseConfig.searchSuccessResponse(
          isPlural: false,
          result: result,
        );
      } else {
        _log.warning(
          message: 'Found nothing!',
          sensitiveData: null,
        );
        return _responseConfig.searchFailedResponse(isPlural: false);
      }
    } catch (error, stackTrace) {
      _log.error(
        message: 'Unable to find document',
        sensitiveData: _shouldNotSensitiveError
            ? null
            : SensitiveData(
                path: collectionPathOverride ?? _collectionPath(),
                id: id,
              ),
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.searchFailedResponse(isPlural: false);
    }
  }

  /// Finds a document based on given [id].
  ///
  /// This method returns data in the form of type [T]. Make sure to have specified the [_toJson] and
  /// [_fromJson] methods or else the [FirestoreApi] will not know how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a Map<String, dynamic> consider using
  /// the [findById] method instead.
  Future<FeedbackResponse<T>> findByIdWithConverter({
    required String id,
    String? collectionPathOverride,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    try {
      _log.info(
        message: 'Finding with converter..',
        sensitiveData: _shouldNotSensitiveInfo
            ? null
            : SensitiveData(
                path: collectionPathOverride ?? _collectionPath(),
                id: id,
              ),
      );
      final result = (await findDocRefWithConverter(
        id: id,
        collectionPathOverride: collectionPathOverride,
      ).get(_getOptions))
          .data();
      if (result != null) {
        _log.success(
          message: 'Found item!',
          sensitiveData: null,
        );
        return _responseConfig.searchSuccessResponse(
            isPlural: false, result: result);
      } else {
        _log.warning(
          message: 'Found nothing!',
          sensitiveData: null,
        );
        return _responseConfig.searchFailedResponse(isPlural: false);
      }
    } catch (error, stackTrace) {
      _log.error(
        message: 'Unable to find document',
        error: error,
        stackTrace: stackTrace,
        sensitiveData: _shouldNotSensitiveError
            ? null
            : SensitiveData(
                path: collectionPathOverride ?? _collectionPath(),
                id: id,
              ),
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
  /// specified in the constructor so you may retrieve document id's more easily after serialization.
  ///
  /// If you rather want to convert this data into a list of [T] immediately you should use the
  /// [findBySearchTermWithConverter] method instead. Make sure to have specified the [_toJson]
  /// and [_fromJson] methods or else the [FirestoreApi] will not know how to convert the data to [T].
  Future<FeedbackResponse<List<Map<String, dynamic>>>> findBySearchTerm({
    required String searchTerm,
    required String searchField,
    required SearchTermType searchTermType,
    bool doSearchNumberEquivalent = false,
    int? limit,
  }) async {
    try {
      _log.info(
        message: 'Searching without converter..',
        sensitiveData: _shouldNotSensitiveError
            ? null
            : SensitiveData(
                path: _collectionPath(),
                searchTerm: searchTerm,
                searchField: searchField,
                searchTermType: searchTermType,
                limit: limit,
              ),
      );
      collectionReferenceQuery(
              Query<Map<String, dynamic>> collectionReference) =>
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
      ).get(_getOptions))
          .docs
          .map(
            (e) => e.data(),
          )
          .toList();
      if (doSearchNumberEquivalent) {
        try {
          final numberSearchTerm = double.tryParse(searchTerm);
          if (numberSearchTerm != null) {
            collectionReferenceQuery(
                    Query<Map<String, dynamic>> collectionReference) =>
                searchTermType.isArray
                    ? limit == null
                        ? collectionReference.where(
                            searchField,
                            arrayContainsAny: [numberSearchTerm],
                          )
                        : collectionReference.where(
                            searchField,
                            arrayContainsAny: [numberSearchTerm],
                          ).limit(limit)
                    : limit == null
                        ? collectionReference.where(
                            searchField,
                            isGreaterThanOrEqualTo: numberSearchTerm,
                            isLessThan: numberSearchTerm + 1,
                          )
                        : collectionReference
                            .where(
                              searchField,
                              isGreaterThanOrEqualTo: numberSearchTerm,
                              isLessThan: numberSearchTerm + 1,
                            )
                            .limit(limit);
            final numberResult = (await collectionReferenceQuery(
              findCollection(),
            ).get(_getOptions))
                .docs
                .map(
                  (e) => e.data(),
                )
                .toList();
            result.addAll(numberResult);
          }
        } catch (error, stackTrace) {
          _log.error(
            message:
                '${error.runtimeType} caught while trying to search for number equivalent',
            sensitiveData: _shouldNotSensitiveError
                ? null
                : SensitiveData(
                    path: _collectionPath(),
                    searchTerm: searchTerm,
                    searchTermType: searchTermType,
                    searchField: searchField,
                  ),
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
      _logResultLength(result);
      return _responseConfig.searchSuccessResponse(
        isPlural: result.isPlural,
        result: result,
      );
    } catch (error, stackTrace) {
      _log.error(
        message: 'Unable to find documents',
        sensitiveData: _shouldNotSensitiveError
            ? null
            : SensitiveData(
                path: _collectionPath(),
                searchTerm: searchTerm,
                searchField: searchField,
                searchTermType: searchTermType,
              ),
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
  /// [_toJson] and [_fromJson] methods or else the [FirestoreApi] will not now how to convert the
  /// data.
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a List<Map<String, dynamic>> consider
  /// using the [findBySearchTerm] method instead.
  Future<FeedbackResponse<List<T>>> findBySearchTermWithConverter({
    required String searchTerm,
    required String searchField,
    required SearchTermType searchTermType,
    bool doSearchNumberEquivalent = false,
    int? limit,
  }) async {
    try {
      _log.info(
        message: 'Searching with converter..',
        sensitiveData: _shouldNotSensitiveInfo
            ? null
            : SensitiveData(
                path: _collectionPath(),
                searchTerm: searchTerm,
                searchField: searchField,
                searchTermType: searchTermType,
                limit: limit,
              ),
      );
      collectionReferenceQuery(Query<T> collectionReference) =>
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
      ).get(_getOptions))
          .docs
          .map((e) => e.data())
          .toList();
      if (doSearchNumberEquivalent) {
        try {
          final numberSearchTerm = double.tryParse(searchTerm);
          if (numberSearchTerm != null) {
            collectionReferenceQuery(Query<T> collectionReference) =>
                searchTermType.isArray
                    ? limit == null
                        ? collectionReference.where(
                            searchField,
                            arrayContainsAny: [numberSearchTerm],
                          )
                        : collectionReference.where(
                            searchField,
                            arrayContainsAny: [numberSearchTerm],
                          ).limit(limit)
                    : limit == null
                        ? collectionReference.where(
                            searchField,
                            isGreaterThanOrEqualTo: numberSearchTerm,
                            isLessThan: numberSearchTerm + 1,
                          )
                        : collectionReference
                            .where(
                              searchField,
                              isGreaterThanOrEqualTo: numberSearchTerm,
                              isLessThan: numberSearchTerm + 1,
                            )
                            .limit(limit);
            final numberResult = (await collectionReferenceQuery(
              findCollectionWithConverter(),
            ).get(_getOptions))
                .docs
                .map(
                  (e) => e.data(),
                )
                .toList();
            result.addAll(numberResult);
          }
        } catch (error, stackTrace) {
          _log.error(
            message: 'Unable to search for number equivalent',
            sensitiveData: _shouldNotSensitiveError
                ? null
                : SensitiveData(
                    path: _collectionPath(),
                    searchTerm: searchTerm,
                    searchField: searchField,
                    searchTermType: searchTermType,
                  ),
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
      _logResultLength(result);
      return _responseConfig.searchSuccessResponse(
          isPlural: result.isPlural, result: result);
    } catch (error, stackTrace) {
      _log.error(
          message: 'Unable to find documents',
          sensitiveData: _shouldNotSensitiveError
              ? null
              : SensitiveData(
                  path: _collectionPath(),
                  searchTerm: searchTerm,
                  searchField: searchField,
                  searchTermType: searchTermType,
                ),
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
  /// specified in the constructor so you may retrieve document id's more easily after serialization.
  ///
  /// If you rather want to convert this data into a list of [T] immediately you should use the
  /// [findByQueryWithConverter] method instead. Make sure to have specified the [_toJson]
  /// and [_fromJson] methods or else the [FirestoreApi] will not know how to convert the data to [T].
  Future<FeedbackResponse<List<Map<String, dynamic>>>> findByQuery({
    required CollectionReferenceQuery<Map<String, dynamic>>
        collectionReferenceQuery,
    required String whereDescription,
  }) async {
    try {
      _log.info(
        message: 'Finding without converter, with custom query..',
        sensitiveData: _shouldNotSensitiveInfo
            ? null
            : SensitiveData(
                path: _collectionPath(),
                whereDescription: whereDescription,
              ),
      );
      final result = (await collectionReferenceQuery(
        findCollection(),
      ).get(_getOptions))
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
        message: 'Unable to find documents with custom query',
        sensitiveData: _shouldNotSensitiveError
            ? null
            : SensitiveData(
                path: _collectionPath(),
                whereDescription: whereDescription,
              ),
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
  /// [_toJson] and [_fromJson] methods or else the [FirestoreApi] will not now how to convert the
  /// data.
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a List<Map<String, dynamic>> consider
  /// using the [findByQuery] method instead.
  Future<FeedbackResponse<List<T>>> findByQueryWithConverter({
    required CollectionReferenceQuery<T> collectionReferenceQuery,
    required String whereDescription,
  }) async {
    try {
      _log.info(
        message: 'Finding with converter, with custom query..',
        sensitiveData: _shouldNotSensitiveInfo
            ? null
            : SensitiveData(
                path: _collectionPath(),
                whereDescription: whereDescription,
              ),
      );
      final result =
          (await collectionReferenceQuery(findCollectionWithConverter())
                  .get(_getOptions))
              .docs
              .map((e) => e.data())
              .toList();
      _logResultLength(result);
      return _responseConfig.searchSuccessResponse(
          isPlural: result.isPlural, result: result);
    } catch (error, stackTrace) {
      _log.error(
        message: 'Unable to find documents with custom query',
        sensitiveData: _shouldNotSensitiveError
            ? null
            : SensitiveData(
                path: _collectionPath(),
                whereDescription: whereDescription,
              ),
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
  /// specified in the constructor so you may retrieve document id's more easily after serialization.
  ///
  /// If you rather want to convert this data into a list of [T] immediately you should use the
  /// [findAllWithConverter] method instead. Make sure to have specified the [_toJson]
  /// and [_fromJson] methods or else the [FirestoreApi] will not know how to convert the data to [T].
  Future<FeedbackResponse<List<Map<String, dynamic>>>> findAll() async {
    try {
      _log.info(
        message: 'Finding all documents without converter..',
        sensitiveData: _shouldNotSensitiveInfo
            ? null
            : SensitiveData(
                path: _collectionPath(),
              ),
      );
      final result = (await findCollection().get(_getOptions))
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
          message: 'Unable to find all documents',
          sensitiveData: _shouldNotSensitiveError
              ? null
              : SensitiveData(
                  path: _collectionPath(),
                ),
          error: error,
          stackTrace: stackTrace);
      return _responseConfig.searchFailedResponse(isPlural: true);
    }
  }

  /// Finds all documents of the specified [_collectionPath].
  ///
  /// This method returns data in the form of a list of [T]. Make sure to have specified the
  /// [_toJson] and [_fromJson] methods or else the [FirestoreApi] will not now how to convert the
  /// data.
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a List<Map<String, dynamic>> consider
  /// using the [findAll] method instead.
  Future<FeedbackResponse<List<T>>> findAllWithConverter() async {
    try {
      _log.info(
        message: 'Finding all documents with converter..',
        sensitiveData: _shouldNotSensitiveInfo
            ? null
            : SensitiveData(
                path: _collectionPath(),
              ),
      );
      final result = (await findCollectionWithConverter().get(_getOptions))
          .docs
          .map((e) => e.data())
          .toList();
      _logResultLength(result);
      return _responseConfig.searchSuccessResponse(
          isPlural: result.isPlural, result: result);
    } catch (error, stackTrace) {
      _log.error(
        message: 'Unable to find all documents',
        sensitiveData: _shouldNotSensitiveError
            ? null
            : SensitiveData(
                path: _collectionPath(),
              ),
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.searchFailedResponse(isPlural: true);
    }
  }

  /// Helper method for logging the length of a List result.
  void _logResultLength(List<dynamic> result) {
    if (result.isNotEmpty) {
      _log.success(
        message: 'Found ${result.length} item(s)!',
        sensitiveData: _shouldNotSensitiveInfo
            ? null
            : SensitiveData(
                path: _collectionPath(),
              ),
      );
    } else {
      _log.warning(
        message: 'Found 0 items!',
        sensitiveData: _shouldNotSensitiveWarning
            ? null
            : SensitiveData(
                path: _collectionPath(),
              ),
      );
    }
  }

  /// Creates/writes data based on given [writeable].
  ///
  /// Passing in an [id] will give your document that [id].
  ///
  /// Passing in a [writeBatch] will close the [WriteBatch] and perform the last commit. If you want
  /// to add more to your [WriteBatch] then use the [batchCreateDoc] method instead.
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
  /// The [mergeFields] determine which fields to upsert, leave blank to upsert the entire object.
  Future<FeedbackResponse<DocumentReference>> createDoc({
    required Writeable writeable,
    String? id,
    WriteBatch? writeBatch,
    TimestampType createTimeStampType = TimestampType.createdAndUpdated,
    TimestampType updateTimeStampType = TimestampType.updated,
    bool merge = false,
    List<FieldPath>? mergeFields,
    String? collectionPathOverride,
    Transaction? transaction,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    try {
      _log.info(
          message: 'Checking if writeable is valid..', sensitiveData: null);
      final isValidResponse = writeable.isValidResponse();
      if (isValidResponse.isSuccess) {
        _log.success(message: 'Writeable is valid!', sensitiveData: null);
        _log.info(
          message: 'Creating document..',
          sensitiveData: _shouldNotSensitiveInfo
              ? null
              : SensitiveData(
                  path: collectionPathOverride ?? _collectionPath(),
                  id: id,
                  isBatch: writeBatch != null,
                  createTimeStampType: createTimeStampType,
                  updateTimeStampType: updateTimeStampType,
                  isMerge: merge,
                  mergeFields: mergeFields,
                  isTransaction: transaction != null,
                ),
        );
        final DocumentReference documentReference;
        if (writeBatch != null) {
          _log.info(
              message: 'WriteBatch was not null! Creating with batch..',
              sensitiveData: null);
          final lastBatchResponse = await batchCreateDoc(
            writeable: writeable,
            id: id,
            writeBatch: writeBatch,
            createTimeStampType: createTimeStampType,
            updateTimeStampType: updateTimeStampType,
            collectionPathOverride: collectionPathOverride,
            merge: merge,
            mergeFields: mergeFields,
          );
          _log.info(
              message: 'Checking if batchCreate was successful..',
              sensitiveData: null);
          if (lastBatchResponse.isSuccess) {
            final writeBatchWithReference = lastBatchResponse.result!;
            _log.info(
                message: 'Last batch was added with success! Committing..',
                sensitiveData: null);
            await writeBatchWithReference.writeBatch.commit();
            _log.success(
                message: 'Committing writeBatch done!', sensitiveData: null);
            documentReference = writeBatchWithReference.documentReference;
          } else {
            _log.error(message: 'Last batch failed!', sensitiveData: null);
            return _responseConfig.createFailedResponse(isPlural: true);
          }
        } else {
          _log.info(
              message: 'WriteBatch was null! Creating without batch..',
              sensitiveData: null);
          documentReference = id != null
              ? findDocRef(
                  id: id,
                  collectionPathOverride: collectionPathOverride,
                )
              : _firebaseFirestore
                  .collection(collectionPathOverride ?? _collectionPath())
                  .doc();
          _log.info(
            message: 'Creating JSON..',
            sensitiveData: null,
          );
          final writeableAsJson = (merge || mergeFields != null) &&
                  (await documentReference.get(_getOptions)).exists
              ? updateTimeStampType.add(
                  writeable.toJson(),
                  updatedFieldName: _updatedFieldName,
                  createdFieldName: _createdFieldName,
                )
              : createTimeStampType.add(
                  writeable.toJson(),
                  createdFieldName: _createdFieldName,
                  updatedFieldName: _updatedFieldName,
                );
          var setOptions = SetOptions(
            merge: mergeFields == null ? merge : null,
            mergeFields: mergeFields,
          );
          if (transaction == null) {
            _log.info(
              message: 'Setting data with documentReference.set..',
              sensitiveData: _shouldNotSensitiveInfo
                  ? null
                  : SensitiveData(
                      path: collectionPathOverride ?? _collectionPath(),
                      id: documentReference.id,
                      data: writeableAsJson,
                    ),
            );
            await documentReference.set(
              writeableAsJson,
              setOptions,
            );
          } else {
            _log.info(
              message: 'Setting data with transaction.set..',
              sensitiveData: _shouldNotSensitiveInfo
                  ? null
                  : SensitiveData(
                      path: collectionPathOverride ?? _collectionPath(),
                      id: documentReference.id,
                      data: writeableAsJson,
                    ),
            );
            transaction.set(
              findDocRef(id: documentReference.id),
              writeableAsJson,
              setOptions,
            );
          }
        }
        _log.success(
          message: 'Setting data done!',
          sensitiveData: null,
        );
        return _responseConfig.createSuccessResponse(
          isPlural: writeBatch != null,
          result: documentReference,
        );
      }
      _log.warning(
        message: 'Writeable was invalid!',
        sensitiveData: null,
      );
      return FeedbackResponse.error(
        title: isValidResponse.title,
        message: isValidResponse.message,
      );
    } catch (error, stackTrace) {
      _log.error(
        message: 'Unable to create document',
        sensitiveData: _shouldNotSensitiveError
            ? null
            : SensitiveData(
                path: collectionPathOverride ?? _collectionPath(),
                id: id,
                isBatch: writeBatch != null,
                createTimeStampType: createTimeStampType,
                updateTimeStampType: updateTimeStampType,
                isMerge: merge,
                mergeFields: mergeFields,
                isTransaction: transaction != null,
              ),
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
  Future<FeedbackResponse<WriteBatchWithReference?>> batchCreateDoc({
    required Writeable writeable,
    String? id,
    WriteBatch? writeBatch,
    TimestampType createTimeStampType = TimestampType.createdAndUpdated,
    TimestampType updateTimeStampType = TimestampType.updated,
    bool merge = false,
    List<FieldPath>? mergeFields,
    String? collectionPathOverride,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    try {
      final isValidResponse = writeable.isValidResponse();
      if (isValidResponse.isSuccess) {
        _log.success(message: 'Writeable is valid!', sensitiveData: null);
        _log.info(
          message: 'Creating document with batch..',
          sensitiveData: _shouldNotSensitiveInfo
              ? null
              : SensitiveData(
                  path: collectionPathOverride ?? _collectionPath(),
                  id: id,
                  isBatch: writeBatch != null,
                  createTimeStampType: createTimeStampType,
                  updateTimeStampType: updateTimeStampType,
                  isMerge: merge,
                  mergeFields: mergeFields,
                ),
        );
        final nullSafeWriteBatch = writeBatch ?? this.writeBatch;
        final documentReference = id != null
            ? findDocRef(id: id, collectionPathOverride: collectionPathOverride)
            : _firebaseFirestore
                .collection(collectionPathOverride ?? _collectionPath())
                .doc();
        _log.info(message: 'Creating JSON..', sensitiveData: null);
        final writeableAsJson = (merge || mergeFields != null) &&
                (await documentReference.get(_getOptions)).exists
            ? updateTimeStampType.add(
                writeable.toJson(),
                updatedFieldName: _updatedFieldName,
                createdFieldName: _createdFieldName,
              )
            : createTimeStampType.add(
                writeable.toJson(),
                createdFieldName: _createdFieldName,
                updatedFieldName: _updatedFieldName,
              );
        _log.info(
          message: 'Setting data with writeBatch.set..',
          sensitiveData: _shouldNotSensitiveInfo
              ? null
              : SensitiveData(
                  path: collectionPathOverride ?? _collectionPath(),
                  id: documentReference.id,
                  data: writeableAsJson,
                ),
        );
        nullSafeWriteBatch.set(
          documentReference,
          writeableAsJson,
          SetOptions(
            merge: mergeFields == null ? merge : null,
            mergeFields: mergeFields,
          ),
        );
        _log.success(
          message:
              'Adding create to batch done! Returning WriteBatchWithReference..',
          sensitiveData: null,
        );
        return FeedbackResponse.successNone(
          result: WriteBatchWithReference(
            writeBatch: nullSafeWriteBatch,
            documentReference: documentReference,
          ),
        );
      }
      _log.warning(
        message: 'Writeable was invalid!',
        sensitiveData: null,
      );
      return FeedbackResponse.error(
          title: isValidResponse.title, message: isValidResponse.message);
    } catch (error, stackTrace) {
      _log.error(
        message: 'Unable to create document with batch',
        sensitiveData: _shouldNotSensitiveError
            ? null
            : SensitiveData(
                path: collectionPathOverride ?? _collectionPath(),
                id: id,
                isBatch: writeBatch != null,
                createTimeStampType: createTimeStampType,
                updateTimeStampType: updateTimeStampType,
                isMerge: merge,
                mergeFields: mergeFields,
              ),
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.createFailedResponse(isPlural: true);
    }
  }

  /// Updates data based on given [writeable] and [id].
  ///
  /// Passing in a [writeBatch] will close the [WriteBatch] and perform the last commit. If you want
  /// to add more to your [WriteBatch] then use the [batchUpdateDoc] method instead.
  ///
  /// The [timestampType] determines the type of automatically added [_createdFieldName] and/or
  /// [_updatedFieldName] field(s) of [Timestamp]. Pass in a [TimestampType.none] to avoid any of
  /// this automatic behaviour.
  Future<FeedbackResponse<DocumentReference>> updateDoc({
    required Writeable writeable,
    required String id,
    WriteBatch? writeBatch,
    TimestampType timestampType = TimestampType.updated,
    String? collectionPathOverride,
    Transaction? transaction,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    try {
      _log.info(
        message: 'Checking if writeable is valid..',
        sensitiveData: null,
      );
      final isValidResponse = writeable.isValidResponse();
      if (isValidResponse.isSuccess) {
        _log.success(message: 'Writeable is valid!', sensitiveData: null);
        _log.info(
          message: 'Updating document..',
          sensitiveData: _shouldNotSensitiveInfo
              ? null
              : SensitiveData(
                  path: collectionPathOverride ?? _collectionPath(),
                  id: id,
                  isBatch: writeBatch != null,
                  isTransaction: transaction != null,
                  updateTimeStampType: timestampType,
                ),
        );
        final DocumentReference documentReference;
        if (writeBatch != null) {
          _log.info(
            message: 'WriteBatch was not null! Updating with batch..',
            sensitiveData: null,
          );
          final lastBatchResponse = await batchUpdateDoc(
            writeable: writeable,
            id: id,
            writeBatch: writeBatch,
            timestampType: timestampType,
            collectionPathOverride: collectionPathOverride,
          );
          _log.info(
            message: 'Checking if batchUpdate was successful..',
            sensitiveData: null,
          );
          if (lastBatchResponse.isSuccess) {
            final writeBatchWithReference = lastBatchResponse.result!;
            _log.info(
              message: 'Last batch was added with success! Committing..',
              sensitiveData: null,
            );
            await writeBatchWithReference.writeBatch.commit();
            _log.success(
              message: 'Committing writeBatch done!',
              sensitiveData: null,
            );
            documentReference = writeBatchWithReference.documentReference;
          } else {
            _log.error(
              message: 'Last batch failed!',
              sensitiveData: null,
            );
            return _responseConfig.updateFailedResponse(isPlural: true);
          }
        } else {
          _log.info(
            message: 'WriteBatch was null! Updating without batch..',
            sensitiveData: null,
          );
          documentReference = findDocRef(
              id: id, collectionPathOverride: collectionPathOverride);
          _log.info(
            message: 'Creating JSON..',
            sensitiveData: null,
          );
          final writeableAsJson = timestampType.add(
            writeable.toJson(),
            createdFieldName: _createdFieldName,
            updatedFieldName: _updatedFieldName,
          );
          if (transaction == null) {
            _log.info(
              message: 'Updating data with documentReference.update..',
              sensitiveData: _shouldNotSensitiveInfo
                  ? null
                  : SensitiveData(
                      path: collectionPathOverride ?? _collectionPath(),
                      id: documentReference.id,
                      data: writeableAsJson,
                    ),
            );
            await documentReference.update(writeableAsJson);
          } else {
            _log.info(
              message: 'Updating data with transaction.update..',
              sensitiveData: _shouldNotSensitiveInfo
                  ? null
                  : SensitiveData(
                      path: collectionPathOverride ?? _collectionPath(),
                      id: documentReference.id,
                      data: writeableAsJson,
                    ),
            );
            transaction.update(
                findDocRef(id: documentReference.id), writeableAsJson);
          }
        }
        _log.success(
          message: 'Updating data done!',
          sensitiveData: null,
        );
        return _responseConfig.updateSuccessResponse(
          isPlural: writeBatch != null,
          result: documentReference,
        );
      }
      _log.warning(
        message: 'Writeable was invalid!',
        sensitiveData: null,
      );
      return FeedbackResponse.error(
        title: isValidResponse.title,
        message: isValidResponse.message,
      );
    } catch (error, stackTrace) {
      _log.error(
        message: 'Unable to update document',
        sensitiveData: _shouldNotSensitiveError
            ? null
            : SensitiveData(
                path: collectionPathOverride ?? _collectionPath(),
                id: id,
                isBatch: writeBatch != null,
                updateTimeStampType: timestampType,
              ),
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
  Future<FeedbackResponse<WriteBatchWithReference?>> batchUpdateDoc({
    required Writeable writeable,
    required String id,
    WriteBatch? writeBatch,
    TimestampType timestampType = TimestampType.updated,
    String? collectionPathOverride,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    final isValidResponse = writeable.isValidResponse();
    try {
      if (isValidResponse.isSuccess) {
        _log.success(
          message: 'Writeable is valid!',
          sensitiveData: null,
        );
        _log.info(
          message: 'Updating document with batch..',
          sensitiveData: _shouldNotSensitiveInfo
              ? null
              : SensitiveData(
                  path: collectionPathOverride ?? _collectionPath(),
                  id: id,
                  isBatch: writeBatch != null,
                  updateTimeStampType: timestampType,
                ),
        );
        final nullSafeWriteBatch = writeBatch ?? this.writeBatch;
        final documentReference = findDocRef(id: id);
        _log.info(
          message: 'Creating JSON..',
          sensitiveData: null,
        );
        final writeableAsJson = timestampType.add(
          writeable.toJson(),
          createdFieldName: _createdFieldName,
          updatedFieldName: _updatedFieldName,
        );
        _log.info(
          message: 'Updating data with writeBatch.update..',
          sensitiveData: _shouldNotSensitiveInfo
              ? null
              : SensitiveData(
                  path: collectionPathOverride ?? _collectionPath(),
                  id: documentReference.id,
                  data: writeableAsJson,
                ),
        );
        nullSafeWriteBatch.update(
          documentReference,
          writeableAsJson,
        );
        _log.success(
          message:
              'Adding update to batch done! Returning WriteBatchWithReference..',
          sensitiveData: null,
        );
        return FeedbackResponse.successNone(
          result: WriteBatchWithReference(
            writeBatch: nullSafeWriteBatch,
            documentReference: documentReference,
          ),
        );
      }
      _log.warning(
        message: 'Writeable was invalid!',
        sensitiveData: null,
      );
      return FeedbackResponse.error(
          title: isValidResponse.title, message: isValidResponse.message);
    } catch (error, stackTrace) {
      _log.error(
        message: 'Unable to update document with batch',
        sensitiveData: _shouldNotSensitiveError
            ? null
            : SensitiveData(
                path: collectionPathOverride ?? _collectionPath(),
                id: id,
              ),
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.updateFailedResponse(isPlural: writeBatch != null);
    }
  }

  /// Deletes data based on given [id].
  ///
  /// Passing in a [writeBatch] will close the [WriteBatch] and perform the last commit. If you want
  /// to add more to your [WriteBatch] then use the [batchDeleteDoc] method instead.
  Future<FeedbackResponse<void>> deleteDoc({
    required String id,
    WriteBatch? writeBatch,
    String? collectionPathOverride,
    Transaction? transaction,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    try {
      _log.info(
        message: 'Deleting document..',
        sensitiveData: _shouldNotSensitiveInfo
            ? null
            : SensitiveData(
                path: collectionPathOverride ?? _collectionPath(),
                id: id,
                isBatch: writeBatch != null,
              ),
      );
      final DocumentReference documentReference;
      if (writeBatch != null) {
        _log.info(
          message: 'WriteBatch was not null! Deleting with batch..',
          sensitiveData: null,
        );
        final lastBatchResponse = await batchDeleteDoc(
          id: id,
          writeBatch: writeBatch,
          collectionPathOverride: collectionPathOverride,
        );
        _log.info(
          message: 'Checking if batchDelete was successful..',
          sensitiveData: null,
        );
        if (lastBatchResponse.isSuccess) {
          final lastBatch = lastBatchResponse.result!;
          _log.info(
            message: 'Last batch was added with success! Committing..',
            sensitiveData: null,
          );
          await lastBatch.writeBatch.commit();
          _log.success(
            message: 'Committing writeBatch done!',
            sensitiveData: null,
          );
          documentReference = lastBatch.documentReference;
        } else {
          _log.error(
            message: 'Last batch failed!',
            sensitiveData: null,
          );
          return _responseConfig.deleteFailedResponse(isPlural: true);
        }
      } else {
        _log.info(
          message: 'WriteBatch was null! Deleting without batch..',
          sensitiveData: null,
        );
        documentReference =
            findDocRef(id: id, collectionPathOverride: collectionPathOverride);
        if (transaction == null) {
          _log.info(
            message: 'Deleting data with documentReference.delete..',
            sensitiveData: null,
          );
          await documentReference.delete();
        } else {
          transaction.delete(findDocRef(id: documentReference.id));
        }
      }
      _log.success(
        message: 'Deleting data done!',
        sensitiveData: null,
      );
      return _responseConfig.deleteSuccessResponse(
          isPlural: writeBatch != null);
    } catch (error, stackTrace) {
      _log.error(
          message: 'Unable to delete document',
          sensitiveData: _shouldNotSensitiveError
              ? null
              : SensitiveData(
                  path: collectionPathOverride ?? _collectionPath(),
                  id: id,
                ),
          error: error,
          stackTrace: stackTrace);
      return _responseConfig.deleteFailedResponse(isPlural: writeBatch != null);
    }
  }

  /// Batch deletes data based on given [id].
  ///
  /// Passing in a [writeBatch] will use that batch to add to it. If no batch is provided this
  /// method will create and return one.
  Future<FeedbackResponse<WriteBatchWithReference?>> batchDeleteDoc({
    required String id,
    WriteBatch? writeBatch,
    String? collectionPathOverride,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    try {
      _log.info(
        message: 'Deleting document with batch..',
        sensitiveData: _shouldNotSensitiveInfo
            ? null
            : SensitiveData(
                path: collectionPathOverride ?? _collectionPath(),
                id: id,
                isBatch: writeBatch != null,
              ),
      );
      final nullSafeWriteBatch = writeBatch ?? this.writeBatch;
      final documentReference =
          findDocRef(id: id, collectionPathOverride: collectionPathOverride);
      _log.info(
        message: 'Deleting data with writeBatch.delete..',
        sensitiveData: null,
      );
      nullSafeWriteBatch.delete(documentReference);
      _log.success(
        message:
            'Adding delete to batch done! Returning WriteBatchWithReference..',
        sensitiveData: null,
      );
      return FeedbackResponse.successNone(
        result: WriteBatchWithReference(
          writeBatch: nullSafeWriteBatch,
          documentReference: documentReference,
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        message: 'Unable to delete document with batch',
        sensitiveData: _shouldNotSensitiveError
            ? null
            : SensitiveData(
                path: collectionPathOverride ?? _collectionPath(),
                id: id,
              ),
        error: error,
        stackTrace: stackTrace,
      );
      return _responseConfig.deleteFailedResponse(isPlural: writeBatch != null);
    }
  }

  /// Finds a [CollectionReference] of type [T] based on specified [_collectionPath].
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreApi]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a List<Map<String, dynamic>> consider
  /// using the [findCollection] method instead.
  Query<T> findCollectionWithConverter() {
    _log.info(
      message: 'Finding collection with converter..',
      sensitiveData: _shouldNotSensitiveInfo
          ? null
          : SensitiveData(
              path: _collectionPath(),
            ),
    );
    return (_isCollectionGroup
            ? _firebaseFirestore.collectionGroup(_collectionPath())
            : _firebaseFirestore.collection(_collectionPath()))
        .withConverter<T>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data() ?? {};
        try {
          return _fromJson!(
            data
                .tryAddLocalId(
                  snapshot.id,
                  idFieldName: _idFieldName,
                  tryAddLocalId: _tryAddLocalId,
                )
                .tryAddLocalDocumentReference(
                  snapshot.reference,
                  referenceFieldName: _documentReferenceFieldName,
                  tryAddLocalDocumentReference: _tryAddLocalDocumentReference,
                ),
          );
        } catch (error, stackTrace) {
          _log.error(
            message:
                'Unexpected error caught while adding local id and document reference',
            sensitiveData: _shouldNotSensitiveError
                ? null
                : SensitiveData(
                    path: _collectionPath(),
                    id: snapshot.id,
                    data: data,
                  ),
            stackTrace: stackTrace,
            error: InvalidJsonException(
              id: snapshot.id,
              path: snapshot.reference.path,
              api: runtimeType.toString(),
              data: data,
            ),
          );
          _log.info(message: 'Returning error response..', sensitiveData: null);
          try {
            return _fromJsonError!(
              data
                  .tryAddLocalId(
                    snapshot.id,
                    idFieldName: _idFieldName,
                    tryAddLocalId: _tryAddLocalId,
                  )
                  .tryAddLocalDocumentReference(
                    snapshot.reference,
                    referenceFieldName: _documentReferenceFieldName,
                    tryAddLocalDocumentReference: _tryAddLocalDocumentReference,
                  ),
            );
          } catch (error, stackTrace) {
            _log.error(
              message:
                  'Unexpected error caught while adding local id and document reference',
              sensitiveData: _shouldNotSensitiveError
                  ? null
                  : SensitiveData(
                      path: _collectionPath(),
                      id: snapshot.id,
                      data: data,
                    ),
              error: error,
              stackTrace: stackTrace,
            );
          }
          rethrow;
        }
      },
      toFirestore: (data, _) {
        try {
          return _toJson!(data)
              .tryRemoveLocalId(
                idFieldName: _idFieldName,
                tryRemoveLocalId: _tryAddLocalId,
              )
              .tryRemoveLocalDocumentReference(
                referenceFieldName: _documentReferenceFieldName,
                tryRemoveLocalDocumentReference: _tryAddLocalDocumentReference,
              );
        } catch (error) {
          _log.error(
            message:
                'Unexpected error caught while removing local id and document reference',
            sensitiveData: _shouldNotSensitiveError
                ? null
                : SensitiveData(
                    path: _collectionPath(),
                    data: data,
                  ),
          );
          rethrow;
        }
      },
    );
  }

  /// Finds a [DocumentReference] of type [T] based on given [id].
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreApi]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a Map<String, dynamic> consider
  /// using the [findDocRef] method instead.
  DocumentReference<T> findDocRefWithConverter({
    required String id,
    String? collectionPathOverride,
  }) {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    _log.info(
      message: 'Finding document with converter..',
      sensitiveData: _shouldNotSensitiveInfo
          ? null
          : SensitiveData(
              path: collectionPathOverride ?? _collectionPath(),
              id: id,
            ),
    );
    return _firebaseFirestore
        .doc('${collectionPathOverride ?? _collectionPath()}/$id')
        .withConverter<T>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data() ?? {};
        try {
          return _fromJson!(
            data
                .tryAddLocalId(
                  snapshot.id,
                  idFieldName: _idFieldName,
                  tryAddLocalId: _tryAddLocalId,
                )
                .tryAddLocalDocumentReference(
                  snapshot.reference,
                  referenceFieldName: _documentReferenceFieldName,
                  tryAddLocalDocumentReference: _tryAddLocalDocumentReference,
                ),
          );
        } catch (error, stackTrace) {
          _log.error(
            message:
                'Unexpected error caught while adding local id and document reference',
            sensitiveData: _shouldNotSensitiveError
                ? null
                : SensitiveData(
                    path: collectionPathOverride ?? _collectionPath(),
                    id: snapshot.id,
                    data: data,
                  ),
            error: InvalidJsonException(
              id: snapshot.id,
              path: snapshot.reference.path,
              api: runtimeType.toString(),
              data: data,
            ),
            stackTrace: stackTrace,
          );
          try {
            return _fromJsonError!(
              data
                  .tryAddLocalId(
                    snapshot.id,
                    idFieldName: _idFieldName,
                    tryAddLocalId: _tryAddLocalId,
                  )
                  .tryAddLocalDocumentReference(
                    snapshot.reference,
                    referenceFieldName: _documentReferenceFieldName,
                    tryAddLocalDocumentReference: _tryAddLocalDocumentReference,
                  ),
            );
          } catch (error, stackTrace) {
            _log.error(
              message:
                  'Unexpected error caught while adding local id and document reference',
              sensitiveData: _shouldNotSensitiveError
                  ? null
                  : SensitiveData(
                      path: collectionPathOverride ?? _collectionPath(),
                      id: snapshot.id,
                      data: data,
                    ),
              error: error,
              stackTrace: stackTrace,
            );
            rethrow;
          }
        }
      },
      toFirestore: (data, _) {
        try {
          return _toJson!(data)
              .tryRemoveLocalId(
                idFieldName: _idFieldName,
                tryRemoveLocalId: _tryAddLocalId,
              )
              .tryRemoveLocalDocumentReference(
                referenceFieldName: _documentReferenceFieldName,
                tryRemoveLocalDocumentReference: _tryAddLocalDocumentReference,
              );
        } catch (error) {
          _log.error(
            message:
                'Unexpected error caught while removing local id and document reference',
            sensitiveData: _shouldNotSensitiveError
                ? null
                : SensitiveData(
                    path: collectionPathOverride ?? _collectionPath(),
                    id: id,
                    data: data,
                  ),
          );
          rethrow;
        }
      },
    );
  }

  /// Finds a [DocumentSnapshot] of type [T] based on given [id].
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreApi]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a Map<String, dynamic> consider
  /// using the [findDocSnapshot] method instead.
  Future<DocumentSnapshot<T>> findDocSnapshotWithConverter({
    required String id,
    String? collectionPathOverride,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    final docRefWithConverter = findDocRefWithConverter(
      id: id,
      collectionPathOverride: collectionPathOverride,
    );
    _log.info(
      message: 'Finding doc snapshot with converter..',
      sensitiveData: _shouldNotSensitiveInfo
          ? null
          : SensitiveData(
              path: collectionPathOverride ?? _collectionPath(),
              id: id,
            ),
    );
    return docRefWithConverter.get(_getOptions);
  }

  /// Finds a [Stream] of list of [T] based on specified [_collectionPath] (all documents).
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreApi]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a List<Map<String, dynamic>> consider
  /// using the [findStream] method instead.
  Stream<List<T>> findStreamWithConverter() {
    _log.info(
      message: 'Finding stream with converter..',
      sensitiveData: _shouldNotSensitiveInfo
          ? null
          : SensitiveData(
              path: _collectionPath(),
            ),
    );
    return findCollectionWithConverter().snapshots().map(
          (event) => event.docs.map((e) => e.data()).toList(),
        );
  }

  /// Finds a [Stream] of list of [T] based on given [collectionReferenceQuery] and [whereDescription].
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreApi]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a List<Map<String, dynamic>> consider
  /// using the [findStreamByQuery] method instead.
  Stream<List<T>> findStreamByQueryWithConverter({
    CollectionReferenceQuery<T>? collectionReferenceQuery,
    required String whereDescription,
  }) {
    _log.info(
      message: 'Finding stream by query with converter..',
      sensitiveData: _shouldNotSensitiveInfo
          ? null
          : SensitiveData(
              path: _collectionPath(),
              whereDescription: whereDescription,
            ),
    );
    return collectionReferenceQuery!(findCollectionWithConverter())
        .snapshots()
        .map(
          (event) => event.docs.map((e) => e.data()).toList(),
        );
  }

  /// Finds a [Stream] of type [T] based on given [id].
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreApi]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the raw form of a Map<String, dynamic> consider
  /// using the [findDocStream] method instead.
  Stream<T?> findDocStreamWithConverter({
    required String id,
    String? collectionPathOverride,
  }) {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    final docRefWithConverter = findDocRefWithConverter(
      id: id,
      collectionPathOverride: collectionPathOverride,
    );
    _log.info(
      message: 'Finding doc stream with converter..',
      sensitiveData: _shouldNotSensitiveInfo
          ? null
          : SensitiveData(
              path: collectionPathOverride ?? _collectionPath(),
              id: id,
            ),
    );
    return docRefWithConverter.snapshots().map((e) => e.data());
  }

  /// Finds a [CollectionReference] of type Map<String, dynamic> based on specified [_collectionPath].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor.
  ///
  /// If you rather want to retrieve data in the form of [T] consider
  /// using the [findCollectionWithConverter] method instead.
  Query<Map<String, dynamic>> findCollection() {
    _log.info(
      message: 'Finding collection..',
      sensitiveData: _shouldNotSensitiveInfo
          ? null
          : SensitiveData(
              path: _collectionPath(),
            ),
    );
    return (_isCollectionGroup
            ? _firebaseFirestore.collectionGroup(_collectionPath())
            : _firebaseFirestore.collection(_collectionPath()))
        .withConverter<Map<String, dynamic>>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data() ?? {};
        try {
          return data
              .tryAddLocalId(
                snapshot.id,
                idFieldName: _idFieldName,
                tryAddLocalId: _tryAddLocalId,
              )
              .tryAddLocalDocumentReference(
                snapshot.reference,
                referenceFieldName: _documentReferenceFieldName,
                tryAddLocalDocumentReference: _tryAddLocalDocumentReference,
              );
        } catch (error) {
          _log.error(
            message:
                'Unexpected error caught while adding local id and document reference',
            sensitiveData: _shouldNotSensitiveError
                ? null
                : SensitiveData(
                    path: _collectionPath(),
                    id: snapshot.id,
                    data: data,
                  ),
          );
          rethrow;
        }
      },
      toFirestore: (data, _) {
        try {
          return data
              .tryRemoveLocalId(
                idFieldName: _idFieldName,
                tryRemoveLocalId: _tryAddLocalId,
              )
              .tryRemoveLocalDocumentReference(
                referenceFieldName: _documentReferenceFieldName,
                tryRemoveLocalDocumentReference: _tryAddLocalDocumentReference,
              );
        } catch (error) {
          _log.error(
            message: 'Could not find collection',
            sensitiveData: _shouldNotSensitiveError
                ? null
                : SensitiveData(
                    path: _collectionPath(),
                  ),
          );
          rethrow;
        }
      },
    );
  }

  /// Finds a [DocumentReference] of type Map<String, dynamic> based on given [id].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the form of [T] consider using the
  /// [findDocRefWithConverter] method instead.
  DocumentReference<Map<String, dynamic>> findDocRef({
    required String id,
    String? collectionPathOverride,
  }) {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    _log.info(
      message: 'Finding document..',
      sensitiveData: _shouldNotSensitiveInfo
          ? null
          : SensitiveData(
              path: collectionPathOverride ?? _collectionPath(),
              id: id,
            ),
    );
    return _firebaseFirestore
        .doc('${collectionPathOverride ?? _collectionPath()}/$id')
        .withConverter<Map<String, dynamic>>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data() ?? {};
        try {
          return data
              .tryAddLocalId(
                snapshot.id,
                idFieldName: _idFieldName,
                tryAddLocalId: _tryAddLocalId,
              )
              .tryAddLocalDocumentReference(
                snapshot.reference,
                referenceFieldName: _documentReferenceFieldName,
                tryAddLocalDocumentReference: _tryAddLocalDocumentReference,
              );
        } catch (error) {
          _log.error(
            message:
                'Unexpected error caught while adding local id and document reference',
            sensitiveData: _shouldNotSensitiveError
                ? null
                : SensitiveData(
                    path: collectionPathOverride ?? _collectionPath(),
                    id: snapshot.id,
                    data: data,
                  ),
          );
          rethrow;
        }
      },
      toFirestore: (data, _) {
        try {
          return data
              .tryRemoveLocalId(
                idFieldName: _idFieldName,
                tryRemoveLocalId: _tryAddLocalId,
              )
              .tryRemoveLocalDocumentReference(
                referenceFieldName: _documentReferenceFieldName,
                tryRemoveLocalDocumentReference: _tryAddLocalDocumentReference,
              );
        } catch (error) {
          _log.error(
            message:
                'Unexpected error caught while removing local id and document reference',
            sensitiveData: _shouldNotSensitiveError
                ? null
                : SensitiveData(
                    path: collectionPathOverride ?? _collectionPath(),
                    id: id,
                    data: data,
                  ),
          );
          rethrow;
        }
      },
    );
  }

  /// Finds a [DocumentSnapshot] of type Map<String, dynamic> based on given [id].
  ///
  /// Make sure to have specified the [_toJson] and [_fromJson] methods or else the [FirestoreApi]
  /// will not now how to convert the data to [T].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the form of [T] consider using the
  /// [findDocSnapshotWithConverter] method instead.
  Future<DocumentSnapshot<Map<String, dynamic>>> findDocSnapshot({
    required String id,
    String? collectionPathOverride,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    final docRef =
        findDocRef(id: id, collectionPathOverride: collectionPathOverride);
    _log.info(
      message: 'Finding document snapshot..',
      sensitiveData: _shouldNotSensitiveInfo
          ? null
          : SensitiveData(
              path: collectionPathOverride ?? _collectionPath(),
              id: id,
            ),
    );
    return docRef.get(_getOptions);
  }

  /// Finds a [Stream] of List<Map<String, dynamic>> based on specified [_collectionPath] (all documents).
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the form of list of [T] consider using the
  /// [findStreamWithConverter] method instead.
  Stream<QuerySnapshot<Map<String, dynamic>>> findStream() {
    _log.info(
      message: 'Finding stream..',
      sensitiveData: _shouldNotSensitiveInfo
          ? null
          : SensitiveData(
              path: _collectionPath(),
            ),
    );
    return findCollection().snapshots();
  }

  /// Finds a [Stream] of List<Map<String, dynamic>> based on given [collectionReferenceQuery] and [whereDescription].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the form of list of [T] consider using the
  /// [findStreamByQueryWithConverter] method instead.
  Stream<List<Map<String, dynamic>>> findStreamByQuery({
    required CollectionReferenceQuery<Map<String, dynamic>>?
        collectionReferenceQuery,
    required String whereDescription,
  }) {
    _log.info(
      message: 'Finding stream by query..',
      sensitiveData: _shouldNotSensitiveInfo
          ? null
          : SensitiveData(
              path: _collectionPath(),
              whereDescription: whereDescription,
            ),
    );
    return collectionReferenceQuery!(findCollection()).snapshots().map(
          (event) => event.docs.map((e) => e.data()).toList(),
        );
  }

  /// Finds a [Stream] of type Map<String, dynamic> based on given [id].
  ///
  /// If [_tryAddLocalId] is true then your data will also contain a local id field based
  /// on the [_idFieldName] specified in the constructor. Add this id field to your [T] and you will
  /// have easy access to the document id at any time.
  ///
  /// If [_tryAddLocalDocumentReference] is true then your data will also contain a local reference field based
  /// on the [_documentReferenceFieldName] specified in the constructor. Add this reference field to your [T] and you will
  /// have easy access to the document reference at any time.
  ///
  /// If you rather want to retrieve data in the form of [T] consider using the
  /// [findDocStreamWithConverter] method instead.
  Stream<DocumentSnapshot<Map<String, dynamic>>> findDocStream({
    required String id,
    String? collectionPathOverride,
  }) {
    final docRef =
        findDocRef(id: id, collectionPathOverride: collectionPathOverride);
    _log.info(
      message: 'Finding doc stream..',
      sensitiveData: _shouldNotSensitiveInfo
          ? null
          : SensitiveData(
              path: collectionPathOverride ?? _collectionPath(),
              id: id,
            ),
    );
    return docRef.snapshots();
  }

  /// Used to determined if a document exists based on given [id].
  Future<bool> docExists({
    required String id,
    String? collectionPathOverride,
  }) async {
    assert(
      _isCollectionGroup == (collectionPathOverride != null),
      'Firestore does not support finding a document by id when communicating with a collection group, '
      'therefore, you must specify the collectionPathOverride containing all parent collection and document ids '
      'in order to make this method work.',
    );
    final docRef =
        findDocRef(id: id, collectionPathOverride: collectionPathOverride);
    _log.info(
      message: 'Checking if document exists..',
      sensitiveData: _shouldNotSensitiveInfo
          ? null
          : SensitiveData(
              path: collectionPathOverride ?? _collectionPath(),
              id: id,
            ),
    );
    return (await docRef.get(_getOptions)).exists;
  }

  /// Helper method to fetch a [WriteBatch] from [_firebaseFirestore]..
  WriteBatch get writeBatch => _firebaseFirestore.batch();

  /// Helper method to run a [Transaction] from [_firebaseFirestore]..
  Future<E> runTransaction<E>(
    TransactionHandler<E> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) =>
      _firebaseFirestore.runTransaction(
        transactionHandler,
        timeout: timeout,
        maxAttempts: maxAttempts,
      );

  /// The current collection
  CollectionReference get collection =>
      _firebaseFirestore.collection(_collectionPath());

  /// A new document
  DocumentReference get doc => collection.doc();
}
