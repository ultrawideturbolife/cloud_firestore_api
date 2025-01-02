import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_api/cloud_firestore_api.dart';
import 'package:turbo_response/turbo_response.dart';

import '../models/task.dart';

/// API class for handling Task operations using FirestoreApi.
class TaskApi {
  TaskApi({
    required FirebaseFirestore firestore,
    String? collectionPath,
  }) : _api = FirestoreApi<Task>(
          firebaseFirestore: firestore,
          collectionPath: () => collectionPath ?? 'tasks',
          toJson: (task) => task.toFirestore(),
          fromJson: (json) {
            // Create a Task directly from the JSON data
            final data = Map<String, dynamic>.from(json);
            return Task(
              id: data['id'] as String? ?? 'temp',
              title: data['title'] as String,
              description: data['description'] as String,
              priority: data['priority'] as int,
              isCompleted: data['isCompleted'] as bool,
              dueDate: (data['dueDate'] as Timestamp).toDate(),
              createdAt: data['createdAt'] as Timestamp,
              updatedAt: data['updatedAt'] as Timestamp,
              tags: List<String>.from(data['tags'] as List),
              subtasks: List<Map<String, dynamic>>.from(data['subtasks'] as List),
              assigneeRef: data['assigneeRef'] as DocumentReference?,
              metadata: Map<String, dynamic>.from(data['metadata'] as Map),
            );
          },
          tryAddLocalId: true,
          tryAddLocalDocumentReference: true,
        );

  final FirestoreApi<Task> _api;

  /// Create a new task.
  Future<TurboResponse<DocumentReference>> createTask(Task task) async {
    return _api.createDoc(writeable: _TaskWriteable(task));
  }

  /// Find a task by ID.
  Future<TurboResponse<Task>> findTask(String id) async {
    return _api.findByIdWithConverter(id: id);
  }

  /// Find tasks by search term.
  Future<TurboResponse<List<Task>>> findTasksBySearchTerm({
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
    required Task task,
  }) async {
    return _api.updateDoc(
      id: id,
      writeable: _TaskWriteable(task),
    );
  }

  /// Delete a task.
  Future<TurboResponse<void>> deleteTask(String id) async {
    return _api.deleteDoc(id: id);
  }

  /// Create multiple tasks in a batch.
  Future<TurboResponse<List<DocumentReference>>> createTasks(List<Task> tasks) async {
    WriteBatch? batch;
    final results = <DocumentReference>[];

    for (final task in tasks) {
      final response = await _api.batchCreateDoc(
        writeable: _TaskWriteable(task),
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
}

/// Wrapper class to make Task compatible with FirestoreApi's Writeable interface.
class _TaskWriteable implements Writeable {
  const _TaskWriteable(this._task);

  final Task _task;

  @override
  Map<String, dynamic> toJson() => _task.toFirestore();

  @override
  TurboResponse<void> isValidResponse() {
    if (_task.title.isEmpty) {
      return TurboResponse.fail(
        error: Exception('Title cannot be empty'),
        title: 'Invalid Task',
        message: 'The task title cannot be empty',
      );
    }

    if (_task.priority < 1 || _task.priority > 5) {
      return TurboResponse.fail(
        error: Exception('Invalid priority'),
        title: 'Invalid Task',
        message: 'Priority must be between 1 and 5',
      );
    }

    return TurboResponse.emptySuccess();
  }
}
