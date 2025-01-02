import 'package:flutter/material.dart';

import '../models/task_dto.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task});

  final TaskDto? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late int _priority;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _descriptionController = TextEditingController(text: widget.task?.description);
    _priority = widget.task?.priority ?? 1;
    _isCompleted = widget.task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Create Task' : 'Edit Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: List.generate(5, (index) {
                final priority = index + 1;
                return DropdownMenuItem(
                  value: priority,
                  child: Text('Priority $priority'),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Completed'),
              value: _isCompleted,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _isCompleted = value);
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final now = DateTime.now();
      final task = TaskDto(
        id: widget.task?.id ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _priority,
        isCompleted: _isCompleted,
        createdAt: widget.task?.createdAt ?? now,
        updatedAt: now,
        createdBy: widget.task?.createdBy ?? 'user',
        dueDate: widget.task?.dueDate ?? now.add(const Duration(days: 7)),
        tags: widget.task?.tags ?? [],
        subtasks: widget.task?.subtasks ?? [],
        metadata: widget.task?.metadata ?? {},
      );

      Navigator.pop(context, task);
    }
  }
}
