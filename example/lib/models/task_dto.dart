import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_api/cloud_firestore_api.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_response/turbo_response.dart';

import 'document_reference_converter.dart';
import 'timestamp_converter.dart';

part 'task_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TaskDto implements Writeable {
  TaskDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.priority,
    required this.isCompleted,
    required this.dueDate,
    required this.tags,
    required this.subtasks,
    this.assigneeRef,
    required this.metadata,
  });

  final String id;

  @TimestampConverter()
  final DateTime createdAt;

  @TimestampConverter()
  final DateTime updatedAt;

  final String createdBy;
  final String title;
  final String description;
  final int priority;
  final bool isCompleted;

  @TimestampConverter()
  final DateTime dueDate;

  final List<String> tags;
  final List<Map<String, dynamic>> subtasks;

  @DocumentReferenceConverter()
  final DocumentReference? assigneeRef;

  final Map<String, dynamic> metadata;

  factory TaskDto.fromJson(Map<String, dynamic> json) => _$TaskDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TaskDtoToJson(this);

  @override
  TurboResponse<void> isValidResponse() {
    if (title.isEmpty) {
      return TurboResponse.fail(
        error: Exception('Title cannot be empty'),
        title: 'Invalid Task',
        message: 'The task title cannot be empty',
      );
    }

    if (priority < 1 || priority > 5) {
      return TurboResponse.fail(
        error: Exception('Invalid priority'),
        title: 'Invalid Task',
        message: 'Priority must be between 1 and 5',
      );
    }

    return TurboResponse.emptySuccess();
  }
}
