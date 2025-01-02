import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_api/cloud_firestore_api.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/task_dto.dart';
import '../services/tasks_service.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _tasksService = GetIt.I<TasksService>();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: StreamBuilder<List<TaskDto>>(
        stream: _tasksService.findStreamWithConverter(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks found'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskCard(task);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToTaskForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskCard(TaskDto task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(task.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToTaskForm(task: task),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteTask(task),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToTaskForm({TaskDto? task}) async {
    final result = await Navigator.push<TaskDto>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );

    if (result != null) {
      if (task != null) {
        await _updateTask(task.id, result);
      } else {
        await _createTask(result);
      }
    }
  }

  Future<void> _createTask(TaskDto task) async {
    final response = await _tasksService.createTask(task);
    response.when(
      success: (_) => _showSnackBar('Task created successfully'),
      fail: (failure) => _showSnackBar('Failed to create task: ${failure.message}'),
    );
  }

  Future<void> _updateTask(String id, TaskDto task) async {
    final response = await _tasksService.updateTask(id: id, task: task);
    response.when(
      success: (_) => _showSnackBar('Task updated successfully'),
      fail: (failure) => _showSnackBar('Failed to update task: ${failure.message}'),
    );
  }

  Future<void> _deleteTask(TaskDto task) async {
    final response = await _tasksService.deleteTask(task.id);
    response.when(
      success: (_) => _showSnackBar('Task deleted successfully'),
      fail: (failure) => _showSnackBar('Failed to delete task: ${failure.message}'),
    );
  }

  Future<void> _showSearchDialog() async {
    final searchTerm = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Tasks'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter search term',
          ),
          onChanged: (value) => _searchQuery = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _searchQuery),
            child: const Text('Search'),
          ),
        ],
      ),
    );

    if (searchTerm != null && searchTerm.isNotEmpty) {
      final response = await _tasksService.findTasksBySearchTerm(
        searchTerm: searchTerm,
        searchField: 'title',
        searchTermType: SearchTermType.startsWith,
      );

      response.when(
        success: (tasks) {
          if (tasks.result.isEmpty) {
            _showSnackBar('No tasks found matching "$searchTerm"');
          }
        },
        fail: (failure) => _showSnackBar('Search failed: ${failure.message}'),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
