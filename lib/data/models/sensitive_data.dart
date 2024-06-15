import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_api/cloud_firestore_api.dart';

/// Sensitive data model
class SensitiveData {
  const SensitiveData({
    required this.path,
    this.id,
    this.whereDescription,
    this.createTimeStampType,
    this.field,
    this.isBatch,
    this.isMerge,
    this.isTransaction,
    this.limit,
    this.mergeFields,
    this.searchField,
    this.searchTerm,
    this.searchTermType,
    this.type,
    this.updateTimeStampType,
    this.data,
  });

  final String path;
  final String? id;
  final String? whereDescription;
  final List<FieldPath>? mergeFields;
  final String? field;
  final String? searchField;
  final String? searchTerm;
  final SearchTermType? searchTermType;
  final String? type;
  final TimestampType? createTimeStampType;
  final TimestampType? updateTimeStampType;
  final bool? isBatch;
  final bool? isMerge;
  final bool? isTransaction;
  final int? limit;
  final Object? data;

  @override
  String toString() {
    return 'SensitiveData{'
        'path: $path, '
        '${id != null ? 'id: $id, ' : ''}'
        '${whereDescription != null ? 'whereDescription: $whereDescription, ' : ''}'
        '${createTimeStampType != null ? 'createTimeStampType: $createTimeStampType, ' : ''}'
        '${field != null ? 'field: $field, ' : ''}'
        '${isBatch != null ? 'isBatch: $isBatch, ' : ''}'
        '${isMerge != null ? 'isMerge: $isMerge, ' : ''}'
        '${isTransaction != null ? 'isTransaction: $isTransaction, ' : ''}'
        '${limit != null ? 'limit: $limit, ' : ''}'
        '${mergeFields != null ? 'mergeFields: $mergeFields, ' : ''}'
        '${searchField != null ? 'searchField: $searchField, ' : ''}'
        '${searchTerm != null ? 'searchTerm: $searchTerm, ' : ''}'
        '${searchTermType != null ? 'searchTermType: $searchTermType, ' : ''}'
        '${type != null ? 'type: $type, ' : ''}'
        '${updateTimeStampType != null ? 'updateTimeStampType: $updateTimeStampType, ' : ''}'
        '${data != null ? 'data: $data, ' : ''}}';
  }
}
