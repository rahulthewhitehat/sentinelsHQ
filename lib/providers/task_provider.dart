// task_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String taskId;
  final String title;
  final String description;
  final List<String> assignedTo;
  final String status;
  final DateTime createdAt;
  final String createdBy;

  TaskModel({
    required this.taskId,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.status,
    required this.createdAt,
    required this.createdBy,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data, String id) {
    return TaskModel(
      taskId: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignedTo: List<String>.from(data['assignedTo'] ?? []),
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  TaskModel copyWith({
    String? taskId,
    String? title,
    String? description,
    List<String>? assignedTo,
    String? status,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

class TaskProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TaskModel> get tasks => _tasks;

  Future<void> fetchTasks() async {
    try {
      final snapshot = await _firestore.collection('tasks').orderBy('createdAt', descending: true).get();
      _tasks = snapshot.docs.map((doc) => TaskModel.fromMap(doc.data(), doc.id)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
      rethrow;
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      final docRef = await _firestore.collection('tasks').add(task.toMap());
      final newTask = task.copyWith(taskId: docRef.id);
      _tasks.add(newTask);
      notifyListeners();
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _firestore.collection('tasks').doc(task.taskId).update(task.toMap());
      final index = _tasks.indexWhere((t) => t.taskId == task.taskId);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      _tasks.removeWhere((task) => task.taskId == taskId);
      notifyListeners();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({'status': status});
      final index = _tasks.indexWhere((t) => t.taskId == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating task status: $e');
      rethrow;
    }
  }

  int getActiveTaskCount() {
    return _tasks.where((task) => task.status == 'active').length;
  }

  List<TaskModel> getTasksByAssignee(String assignee) {
    return _tasks.where((task) => task.assignedTo.contains(assignee)).toList();
  }

  List<TaskModel> getTasksByStatus(String status) {
    return _tasks.where((task) => task.status == status).toList();
  }
}