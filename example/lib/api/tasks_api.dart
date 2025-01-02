import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_api/cloud_firestore_api.dart';
import 'package:turbo_response/turbo_response.dart';

import '../models/firestore_collection.dart';
import '../models/task_dto.dart';

/// API class for handling Task operations using FirestoreApi.
class TasksApi {
  TasksApi({
    required FirebaseFirestore firestore,
  }) : _api = FirestoreApi<TaskDto>(
          firebaseFirestore: firestore,
          collectionPath: () => FirestoreCollection.tasks.path,
          toJson: (task) => task.toJson(),
          fromJson: (json) => TaskDto.fromJson(json),
          tryAddLocalId: true,
          tryAddLocalDocumentReference: true,
        );

  final FirestoreApi<TaskDto> _api;

  /// Create a new task.
  Future<TurboResponse<DocumentReference>> createTask(TaskDto task) async {
    return _api.createDoc(writeable: task);
  }

  /// Find a task by ID.
  Future<TurboResponse<TaskDto>> findTask(String id) async {
    return _api.findByIdWithConverter(id: id);
  }

  /// Find tasks by search term.
  Future<TurboResponse<List<TaskDto>>> findTasksBySearchTerm({
    required String searchTerm,
    required String searchField,
    required SearchTermType searchTermType,
  }) async {
    return _api.findBySearchTermWithConverter(
      searchTerm: searchTerm,
      searchField: searchField,
      searchTermType: searchTermType,
    );
  }

  /// Update a task.
  Future<TurboResponse<DocumentReference>> updateTask({
    required String id,
    required TaskDto task,
  }) async {
    return _api.updateDoc(
      id: id,
      writeable: task,
    );
  }

  /// Delete a task.
  Future<TurboResponse<void>> deleteTask(String id) async {
    return _api.deleteDoc(id: id);
  }

  /// Create multiple tasks in a batch.
  Future<TurboResponse<List<DocumentReference>>> createTasks(List<TaskDto> tasks) async {
    WriteBatch? batch;
    final results = <DocumentReference>[];

    for (final task in tasks) {
      final response = await _api.batchCreateDoc(
        writeable: task,
        writeBatch: batch,
      );

      final batchWithRef = response.when(
        success: (success) => success.result,
        fail: (_) => null,
      );

      if (batchWithRef == null) {
        return TurboResponse.fail(
          error: Exception('Failed to add task to batch'),
          title: 'Batch Creation Failed',
          message: 'Failed to add one or more tasks to the batch',
        );
      }

      batch = batchWithRef.writeBatch;
      results.add(batchWithRef.documentReference);
    }

    if (batch != null) {
      await batch.commit();
      return TurboResponse.success(result: results);
    }

    return TurboResponse.fail(
      error: Exception('No tasks to create'),
      title: 'Batch Creation Failed',
      message: 'No tasks were provided for batch creation',
    );
  }

  /// Get a stream of all tasks.
  Stream<List<TaskDto>> findStreamWithConverter() {
    return _api.findStreamWithConverter();
  }
}
