// task_model && provider

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';


class TaskModel {
  final String taskId;
  final String title;
  final String description;
  final List<Map<String, String>> resources;
  final String deadline;
  final String role;
  final DateTime createdAt;
  final String status; // New field

  TaskModel({
    required this.taskId,
    required this.title,
    required this.description,
    required this.resources,
    required this.deadline,
    required this.role,
    required this.createdAt,
    required this.status, // Add status to constructor
  });

  factory TaskModel.fromMap(Map<String, dynamic> data, String id) {
    return TaskModel(
      taskId: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      resources: List<Map<String, String>>.from(
          (data['resources'] ?? []).map((resource) => Map<String, String>.from(resource))),
      deadline: data['deadline'] ?? '',
      role: data['role'] ?? 'All',
      createdAt: (data['createdAt'] as Timestamp?) != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: data['status'] ?? 'ASSIGNED', // Default to 'ASSIGNED' if not present
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'resources': resources,
      'deadline': deadline,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status, // Add status to map
    };
  }

  TaskModel copyWith({
    String? taskId,
    String? title,
    String? description,
    List<Map<String, String>>? resources,
    String? deadline,
    String? role,
    DateTime? createdAt,
    String? status, // Add status to copyWith
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      resources: resources ?? this.resources,
      deadline: deadline ?? this.deadline,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status, // Include status
    );
  }
}

class TaskProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  String _selectedRole = 'All';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TaskModel> get tasks => _tasks;
  String get selectedRole => _selectedRole;

  void setSelectedRole(String role) {
    _selectedRole = role;
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      QuerySnapshot snapshot;
      if (_selectedRole == 'All') {
        snapshot = await _firestore.collection('generaltasks')
            .where('status', whereIn: ['ASSIGNED', 'ACK', 'SUBMITTED']) // Filter by status
            .orderBy('createdAt', descending: true)
            .get();
      } else {
        snapshot = await _firestore
            .collection('roles')
            .doc(_selectedRole)
            .collection('tasks')
            .where('status', whereIn: ['ASSIGNED', 'ACK', 'SUBMITTED']) // Filter by status
            .orderBy('createdAt', descending: true)
            .get();
      }

      _tasks = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return TaskModel.fromMap(data, doc.id);
      }).toList();

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching tasks: $e');
      }
      rethrow;
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      // Creating a new task always with status 'ASSIGNED'
      final taskWithStatus = task.copyWith(status: 'ASSIGNED');

      if (task.role == 'All') {
        await _firestore.collection('generaltasks').add(taskWithStatus.toMap());
      } else {
        await _firestore
            .collection('roles')
            .doc(task.role)
            .collection('tasks')
            .add(taskWithStatus.toMap());
      }
      fetchTasks();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding task: $e');
      }
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      if (task.role == 'All') {
        await _firestore.collection('generaltasks').doc(task.taskId).update(task.toMap());
      } else {
        await _firestore
            .collection('roles')
            .doc(task.role)
            .collection('tasks')
            .doc(task.taskId)
            .update(task.toMap());
      }
      fetchTasks();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating task: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      if (_selectedRole == 'All') {
        await _firestore.collection('generaltasks').doc(taskId).delete();
      } else {
        await _firestore
            .collection('roles')
            .doc(_selectedRole)
            .collection('tasks')
            .doc(taskId)
            .delete();
      }
      fetchTasks();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting task: $e');
      }
      rethrow;
    }
  }

  // New method to acknowledge a task
  Future<void> acknowledgeTask(String taskId) async {
    try {
      if (_selectedRole == 'All') {
        await _firestore.collection('generaltasks').doc(taskId).update({'status': 'COMPLETED'});
      } else {
        await _firestore
            .collection('roles')
            .doc(_selectedRole)
            .collection('tasks')
            .doc(taskId)
            .update({'status': 'COMPLETED'});
      }
      fetchTasks();
    } catch (e) {
      if (kDebugMode) {
        print('Error acknowledging task: $e');
      }
      rethrow;
    }
  }
}