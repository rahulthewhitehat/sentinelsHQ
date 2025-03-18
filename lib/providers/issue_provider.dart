// issue_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IssueModel {
  final String issueId;
  final String raisedBy;
  final String raisedByUid; // Added field
  final String contact;     // Added field
  final String description; // Renamed from issueText to match your Firestore structure
  final String status;
  final DateTime timestamp; // Renamed from createdAt to match your Firestore structure
  final String? resolution;
  final String userRole;    // Added field

  IssueModel({
    required this.issueId,
    required this.raisedBy,
    required this.raisedByUid,
    required this.contact,
    required this.description,
    required this.status,
    required this.timestamp,
    this.resolution,
    required this.userRole,
  });

  factory IssueModel.fromMap(Map<String, dynamic> data, String id) {
    return IssueModel(
      issueId: id,
      raisedBy: data['raisedBy'] ?? '',
      raisedByUid: data['raisedByUid'] ?? '',
      contact: data['contact'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'RAISED',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      resolution: data['resolution'],
      userRole: data['userRole'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'raisedBy': raisedBy,
      'raisedByUid': raisedByUid,
      'contact': contact,
      'description': description,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'resolution': resolution,
      'userRole': userRole,
    };
  }

  IssueModel copyWith({
    String? issueId,
    String? raisedBy,
    String? raisedByUid,
    String? contact,
    String? description,
    String? status,
    DateTime? timestamp,
    String? resolution,
    String? userRole,
  }) {
    return IssueModel(
      issueId: issueId ?? this.issueId,
      raisedBy: raisedBy ?? this.raisedBy,
      raisedByUid: raisedByUid ?? this.raisedByUid,
      contact: contact ?? this.contact,
      description: description ?? this.description,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      resolution: resolution ?? this.resolution,
      userRole: userRole ?? this.userRole,
    );
  }
}

class IssueProvider with ChangeNotifier {
  List<IssueModel> _issues = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<IssueModel> get issues => _issues;

  Future<void> fetchIssues() async {
    try {
      final snapshot = await _firestore.collection('issues').orderBy('createdAt', descending: true).get();
      _issues = snapshot.docs.map((doc) => IssueModel.fromMap(doc.data(), doc.id)).toList();
      notifyListeners();
    } catch (e) {
      //print('Error fetching issues: $e');
      rethrow;
    }
  }

  Future<void> addIssue(IssueModel issue) async {
    try {
      final docRef = await _firestore.collection('issues').add(issue.toMap());
      final newIssue = issue.copyWith(issueId: docRef.id);
      _issues.add(newIssue);
      notifyListeners();
    } catch (e) {
      //print('Error adding issue: $e');
      rethrow;
    }
  }

  Future<void> updateIssueStatus(String issueId, String status, {String? resolution}) async {
    try {
      final updateData = {
        'status': status,
      };

      if (resolution != null) {
        updateData['resolution'] = resolution;
      }

      await _firestore.collection('issues').doc(issueId).update(updateData);

      final index = _issues.indexWhere((i) => i.issueId == issueId);
      if (index != -1) {
        _issues[index] = _issues[index].copyWith(
          status: status,
          resolution: resolution ?? _issues[index].resolution,
        );
        notifyListeners();
      }
    } catch (e) {
      //print('Error updating issue status: $e');
      rethrow;
    }
  }

  int getOpenIssueCount() {
    return _issues.where((issue) => issue.status == 'open').length;
  }

  List<IssueModel> getIssuesByStatus(String status) {
    return _issues.where((issue) => issue.status == status).toList();
  }

  // Add this method to your existing IssueProvider class
  Future<void> fetchUserIssues(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('issues')
          .where('raisedByUid', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      _issues = snapshot.docs.map((doc) => IssueModel.fromMap(doc.data(), doc.id)).toList();
      notifyListeners();
    } catch (e) {
      //print('Error fetching user issues: $e');
      rethrow;
    }
  }

// Add this utility method to get filtered issues without refetching
  List<IssueModel> getIssuesByUserId(String userId) {
    return _issues.where((issue) => issue.raisedByUid == userId).toList();
  }
}