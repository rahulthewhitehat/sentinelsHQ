// resource_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResourceModel {
  final String resourceId;
  final String title;
  final String link;
  final DateTime createdAt;

  ResourceModel({
    required this.resourceId,
    required this.title,
    required this.link,
    required this.createdAt,
  });

  factory ResourceModel.fromMap(Map<String, dynamic> data, String id) {
    return ResourceModel(
      resourceId: id,
      title: data['title'] ?? '',
      link: data['link'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'link': link,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class ResourceProvider with ChangeNotifier {
  List<ResourceModel> _resources = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ResourceModel> get resources => _resources;

  Future<void> fetchResources() async {
    try {
      final snapshot = await _firestore.collection('resources').orderBy('createdAt', descending: true).get();
      _resources = snapshot.docs.map((doc) => ResourceModel.fromMap(doc.data(), doc.id)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching resources: $e');
      rethrow;
    }
  }

  Future<void> addResource(ResourceModel resource) async {
    try {
      final docRef = await _firestore.collection('resources').add(resource.toMap());
      final newResource = ResourceModel(
        resourceId: docRef.id,
        title: resource.title,
        link: resource.link,
        createdAt: resource.createdAt,
      );
      _resources.add(newResource);
      notifyListeners();
    } catch (e) {
      print('Error adding resource: $e');
      rethrow;
    }
  }

  Future<void> updateResource(ResourceModel resource) async {
    try {
      await _firestore.collection('resources').doc(resource.resourceId).update(resource.toMap());
      final index = _resources.indexWhere((r) => r.resourceId == resource.resourceId);
      if (index != -1) {
        _resources[index] = resource;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating resource: $e');
      rethrow;
    }
  }

  Future<void> deleteResource(String resourceId) async {
    try {
      await _firestore.collection('resources').doc(resourceId).delete();
      _resources.removeWhere((resource) => resource.resourceId == resourceId);
      notifyListeners();
    } catch (e) {
      print('Error deleting resource: $e');
      rethrow;
    }
  }
}