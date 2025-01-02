// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskDto _$TaskDtoFromJson(Map<String, dynamic> json) => TaskDto(
      id: json['id'] as String,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp),
      updatedAt:
          const TimestampConverter().fromJson(json['updatedAt'] as Timestamp),
      createdBy: json['createdBy'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: (json['priority'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool,
      dueDate:
          const TimestampConverter().fromJson(json['dueDate'] as Timestamp),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      subtasks: (json['subtasks'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      assigneeRef: const DocumentReferenceConverter()
          .fromJson(json['assigneeRef'] as String?),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TaskDtoToJson(TaskDto instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'createdBy': instance.createdBy,
      'title': instance.title,
      'description': instance.description,
      'priority': instance.priority,
      'isCompleted': instance.isCompleted,
      'dueDate': const TimestampConverter().toJson(instance.dueDate),
      'tags': instance.tags,
      'subtasks': instance.subtasks,
      'assigneeRef':
          const DocumentReferenceConverter().toJson(instance.assigneeRef),
      'metadata': instance.metadata,
    };
