import 'task_dto.dart';

/// Extension on TaskDto for easier task creation.
extension TaskDtoExtension on TaskDto {
  /// Create a copy of this task with updated fields.
  TaskDto copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? title,
    String? description,
    int? priority,
    bool? isCompleted,
    DateTime? dueDate,
    List<String>? tags,
    List<Map<String, dynamic>>? subtasks,
    Map<String, dynamic>? metadata,
  }) {
    return TaskDto(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      subtasks: subtasks ?? this.subtasks,
      metadata: metadata ?? this.metadata,
    );
  }
}
