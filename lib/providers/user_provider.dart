  // user_provider.dart
  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

  class UserModel {
    final String uid;
    final String name;
    final String email;
    final String role;
    final String? team;
    final String? profilePic;
    final DateTime createdAt;

    UserModel({
      required this.uid,
      required this.name,
      required this.email,
      required this.role,
      this.team,
      this.profilePic,
      required this.createdAt,
    });

    factory UserModel.fromMap(Map<String, dynamic> data) {
      return UserModel(
        uid: data['uid'] ?? '',
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? '',
        team: data['team'],
        profilePic: data['profilePic'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'team': team,
        'profilePic': profilePic,
        'createdAt': Timestamp.fromDate(createdAt),
      };
    }
  }

  class UserProvider with ChangeNotifier {
    List<UserModel> _users = [];
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    List<UserModel> get users => _users;

    Future<void> fetchUsers() async {
      try {
        final snapshot = await _firestore.collection('users').get();
        _users = snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
        notifyListeners();
      } catch (e) {
        print('Error fetching users: $e');
        rethrow;
      }
    }

    Future<void> addUser(UserModel user) async {
      try {
        await _firestore.collection('users').doc(user.uid).set(user.toMap());
        _users.add(user);
        notifyListeners();
      } catch (e) {
        print('Error adding user: $e');
        rethrow;
      }
    }

    Future<void> updateUser(UserModel user) async {
      try {
        await _firestore.collection('users').doc(user.uid).update(user.toMap());
        final index = _users.indexWhere((u) => u.uid == user.uid);
        if (index != -1) {
          _users[index] = user;
          notifyListeners();
        }
      } catch (e) {
        print('Error updating user: $e');
        rethrow;
      }
    }

    Future<void> deleteUser(String uid) async {
      try {
        await _firestore.collection('users').doc(uid).delete();
        _users.removeWhere((user) => user.uid == uid);
        notifyListeners();
      } catch (e) {
        print('Error deleting user: $e');
        rethrow;
      }
    }

    List<UserModel> getAdmins() {
      return _users.where((user) => user.role == 'Admin' || user.role == 'Super Admin').toList();
    }

    List<UserModel> getMembers() {
      return _users.where((user) => user.role == 'Member').toList();
    }

    List<UserModel> getTeamMembers(String team) {
      return _users.where((user) => user.team == team).toList();
    }
  }