// issue_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IssueModel {
  final String issueId;
  final String raisedBy;
  final String issueText;
  final String status;
  final DateTime createdAt;
  final String? resolution;

  IssueModel({
    required this.issueId,
    required this.raisedBy,
    required this.issueText,
    required this.status,
    required this.createdAt,
    this.resolution,
  });

  factory IssueModel.fromMap(Map<String, dynamic> data, String id) {
    return IssueModel(
      issueId: id,
      raisedBy: data['raisedBy'] ?? '',
      issueText: data['issueText'] ?? '',
      status: data['status'] ?? 'open',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      resolution: data['resolution'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'raisedBy': raisedBy,
      'issueText': issueText,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolution': resolution,
    };
  }

  IssueModel copyWith({
    String? issueId,
    String? raisedBy,
    String? issueText,
    String? status,
    DateTime? createdAt,
    String? resolution,
  }) {
    return IssueModel(
      issueId: issueId ?? this.issueId,
      raisedBy: raisedBy ?? this.raisedBy,
      issueText: issueText ?? this.issueText,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolution: resolution ?? this.resolution,
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
      print('Error fetching issues: $e');
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
      print('Error adding issue: $e');
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
      print('Error updating issue status: $e');
      rethrow;
    }
  }

  int getOpenIssueCount() {
    return _issues.where((issue) => issue.status == 'open').length;
  }

  List<IssueModel> getIssuesByStatus(String status) {
    return _issues.where((issue) => issue.status == status).toList();
  }
}