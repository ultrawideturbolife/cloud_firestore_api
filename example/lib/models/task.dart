import 'package:cloud_firestore/cloud_firestore.dart';

/// A test model representing a task with various field types to test different Firestore features.
class Task {
  /// The unique identifier of the task.
  final String id;

  /// The title of the task.
  final String title;

  /// The description of the task.
  final String description;

  /// The priority level of the task (1-5).
  final int priority;

  /// Whether the task is completed.
  final bool isCompleted;

  /// The due date of the task.
  final DateTime dueDate;

  /// The creation timestamp of the task.
  final Timestamp createdAt;

  /// The last update timestamp of the task.
  final Timestamp updatedAt;

  /// Tags associated with the task (for array queries).
  final List<String> tags;

  /// Subtasks within this task (for nested data).
  final List<Map<String, dynamic>> subtasks;

  /// The assignee reference (for document reference testing).
  final DocumentReference? assigneeRef;

  /// Custom metadata for the task (for map field testing).
  final Map<String, dynamic> metadata;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.isCompleted,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.subtasks,
    this.assigneeRef,
    required this.metadata,
  });

  /// Creates a Task from a Firestore document.
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
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
  }

  /// Converts the Task to a Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'isCompleted': isCompleted,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'tags': tags,
      'subtasks': subtasks,
      'assigneeRef': assigneeRef,
      'metadata': metadata,
    };
  }

  /// Creates a copy of this Task with the given fields replaced with new values.
  Task copyWith({
    String? id,
    String? title,
    String? description,
    int? priority,
    bool? isCompleted,
    DateTime? dueDate,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    List<String>? tags,
    List<Map<String, dynamic>>? subtasks,
    DocumentReference? assigneeRef,
    Map<String, dynamic>? metadata,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? List.from(this.tags),
      subtasks: subtasks ?? List.from(this.subtasks),
      assigneeRef: assigneeRef ?? this.assigneeRef,
      metadata: metadata ?? Map.from(this.metadata),
    );
  }
}
