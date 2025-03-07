import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../DataBase/handle_DB.dart';


class ResourceModel {
  final String resourceId;
  final String title;
  final String description;
  final List<Map<String, String>> links;
  final List<String> roles;
  final DateTime createdAt;

  ResourceModel({
    required this.resourceId,
    required this.title,
    required this.description,
    required this.links,
    this.roles = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'links': links,
      'roles': roles,
      'createdAt': createdAt,
    };
  }

  factory ResourceModel.fromMap(String id, Map<String, dynamic> map) {
    return ResourceModel(
      resourceId: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      links: List<Map<String, String>>.from(
        (map['links'] ?? []).map((link) => Map<String, String>.from(link)),
      ),
      roles: List<String>.from(map['roles'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
}

class ResourceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ResourceModel> _resources = [];
  String _selectedRole = 'All';
  bool _isLoading = false;

  List<ResourceModel> get resources => _resources;
  String get selectedRole => _selectedRole;
  bool get isLoading => _isLoading;

  void setSelectedRole(String role) {
    _selectedRole = role;
    fetchResources();
  }

  Future<void> fetchResources() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<ResourceModel> loadedResources = [];

      if (_selectedRole == 'All') {
        // Fetch general resources
        final generalSnapshot = await _firestore.collection('generalResources').get();
        for (var doc in generalSnapshot.docs) {
          loadedResources.add(ResourceModel.fromMap(doc.id, doc.data()));
        }
      } else {
        // Fetch role-specific resources
        final roleSnapshot = await _firestore
            .collection('roles')
            .doc(_selectedRole)
            .collection('resources')
            .get();

        for (var doc in roleSnapshot.docs) {
          loadedResources.add(ResourceModel.fromMap(doc.id, doc.data()));
        }

        // Also fetch general resources that should be shown to all roles
        final generalSnapshot = await _firestore.collection('generalResources').get();
        for (var doc in generalSnapshot.docs) {
          loadedResources.add(ResourceModel.fromMap(doc.id, doc.data()));
        }
      }

      // Sort by created date (newest first)
      loadedResources.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _resources = loadedResources;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching resources: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addResource(ResourceModel resource) async {
    try {
      Map<String, dynamic> resourceData = resource.toMap();

      // Handle different scenarios for roles
      if (resource.roles.contains('All')) {
        // Store in generalResources collection
        final docRef = await _firestore.collection('generalResources').add(resourceData);

        final newResource = ResourceModel(
          resourceId: docRef.id,
          title: resource.title,
          description: resource.description,
          links: resource.links,
          roles: resource.roles,
          createdAt: resource.createdAt,
        );

        _resources.add(newResource);
      } else {
        // Create a list to track new resources for UI update
        final List<ResourceModel> newResources = [];

        // Add to each selected role's collection
        for (String role in resource.roles) {
          final docRef = await _firestore
              .collection('roles')
              .doc(role)
              .collection('resources')
              .add(resourceData);

          final newResource = ResourceModel(
            resourceId: docRef.id,
            title: resource.title,
            description: resource.description,
            links: resource.links,
            roles: [role], // Store only the specific role it was saved to
            createdAt: resource.createdAt,
          );

          // Only add to UI resources if the current selected role matches
          if (_selectedRole == 'All' || _selectedRole == role) {
            newResources.add(newResource);
          }
        }

        // Update UI with new resources if they should be visible in current view
        if (newResources.isNotEmpty) {
          _resources.addAll(newResources);
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding resource: $e');
      }
      rethrow;
    }
  }

  Future<void> updateResource(ResourceModel resource) async {
    try {
      Map<String, dynamic> resourceData = resource.toMap();

      if (_selectedRole == 'All' || resource.resourceId.startsWith('general_')) {
        // Update in generalResources collection
        await _firestore
            .collection('generalResources')
            .doc(resource.resourceId)
            .update(resourceData);
      } else {
        // Update in specific role collection
        await _firestore
            .collection('roles')
            .doc(_selectedRole)
            .collection('resources')
            .doc(resource.resourceId)
            .update(resourceData);
      }

      // Update local state
      final index = _resources.indexWhere((r) => r.resourceId == resource.resourceId);
      if (index != -1) {
        _resources[index] = resource;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating resource: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteResource(String resourceId) async {
    try {
      if (_selectedRole == 'All') {
        // Check if it's a general resource
        try {
          await _firestore.collection('generalResources').doc(resourceId).delete();
        } catch (e) {
          // If not found in generalResources, need to find which role it belongs to
          final roles = await handleDB.fetchRoles();

          for (String role in roles) {
            try {
              await _firestore
                  .collection('roles')
                  .doc(role)
                  .collection('resources')
                  .doc(resourceId)
                  .delete();
              break; // Found and deleted, no need to continue
            } catch (e) {
              // Continue trying other roles
            }
          }
        }
      } else {
        // Delete from specific role collection
        await _firestore
            .collection('roles')
            .doc(_selectedRole)
            .collection('resources')
            .doc(resourceId)
            .delete();
      }

      // Update local state
      _resources.removeWhere((resource) => resource.resourceId == resourceId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting resource: $e');
      }
      rethrow;
    }
  }
}


