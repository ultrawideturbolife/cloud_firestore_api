import 'package:cloud_firestore/cloud_firestore.dart';

import 'task_dto.dart';

/// Factory class for creating test tasks.
class TaskFactory {
  /// Create a basic task with minimal data.
  static TaskDto createBasicTask({
    String? id,
    String title = 'Test Task',
    String description = 'This is a test task',
  }) {
    final now = DateTime.now();
    return TaskDto(
      id: id ?? '',
      title: title,
      description: description,
      priority: 1,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
      createdBy: 'test-user',
      dueDate: now.add(const Duration(days: 7)),
      tags: const [],
      subtasks: const [],
      metadata: const {},
    );
  }

  /// Create a task with full data.
  static TaskDto createFullTask({
    String? id,
    String title = 'Full Test Task',
    String description = 'This is a test task with all fields populated',
    int priority = 3,
    bool isCompleted = false,
    List<String> tags = const ['test', 'example'],
    List<Map<String, dynamic>> subtasks = const [
      {'title': 'Subtask 1', 'completed': false},
      {'title': 'Subtask 2', 'completed': true},
    ],
    Map<String, dynamic> metadata = const {
      'category': 'test',
      'importance': 'high',
    },
  }) {
    final now = DateTime.now();
    return TaskDto(
      id: id ?? '',
      title: title,
      description: description,
      priority: priority,
      isCompleted: isCompleted,
      createdAt: now,
      updatedAt: now,
      createdBy: 'test-user',
      dueDate: now.add(const Duration(days: 7)),
      tags: tags,
      subtasks: subtasks,
      metadata: metadata,
    );
  }

  /// Create a list of test tasks.
  static List<TaskDto> createBatchTasks({
    int count = 5,
    bool withFullData = false,
  }) {
    return List.generate(
      count,
      (index) => withFullData
          ? createFullTask(
              title: 'Task ${index + 1}',
              description: 'Description for task ${index + 1}',
            )
          : createBasicTask(
              title: 'Task ${index + 1}',
              description: 'Description for task ${index + 1}',
            ),
    );
  }

  /// Create a task with searchable content.
  static TaskDto createSearchableTask({
    required String searchableTitle,
    required String searchableDescription,
    List<String> searchableTags = const [],
  }) {
    final now = DateTime.now();
    return TaskDto(
      id: '',
      title: searchableTitle,
      description: searchableDescription,
      priority: 1,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
      createdBy: 'test-user',
      dueDate: now.add(const Duration(days: 7)),
      tags: searchableTags,
      subtasks: const [],
      metadata: const {},
    );
  }
}
