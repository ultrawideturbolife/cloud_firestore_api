import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_api/cloud_firestore_api.dart';
import 'package:turbo_response/turbo_response.dart';

import '../api/tasks_api.dart';
import '../models/task_dto.dart';

/// Service class for handling Task business logic.
class TasksService {
  TasksService({
    required FirebaseFirestore firestore,
  }) : _api = TasksApi(firestore: firestore);

  final TasksApi _api;

  /// Create a new task.
  Future<TurboResponse<DocumentReference>> createTask(TaskDto task) async {
    return _api.createTask(task);
  }

  /// Find a task by ID.
  Future<TurboResponse<TaskDto>> findTask(String id) async {
    return _api.findTask(id);
  }

  /// Find tasks by search term.
  Future<TurboResponse<List<TaskDto>>> findTasksBySearchTerm({
    required String searchTerm,
    required String searchField,
    required SearchTermType searchTermType,
  }) async {
    return _api.findTasksBySearchTerm(
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
    return _api.updateTask(
      id: id,
      task: task,
    );
  }

  /// Delete a task.
  Future<TurboResponse<void>> deleteTask(String id) async {
    return _api.deleteTask(id);
  }

  /// Create multiple tasks in a batch.
  Future<TurboResponse<List<DocumentReference>>> createTasks(List<TaskDto> tasks) async {
    return _api.createTasks(tasks);
  }

  /// Get a stream of all tasks.
  Stream<List<TaskDto>> findStreamWithConverter() {
    return _api.findStreamWithConverter();
  }
}
