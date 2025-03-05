  // user_provider.dart
  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

  class UserModel {
    final String uid;
    final String fullName;
    final String email;
    final String role;
    final String department;
    final String? section;
    final int? year;
    final DateTime? dateOfBirth;
    final String? profilePic;
    final String phoneNumber;
    final String whatsappNumber;
    final Map<String, dynamic>? socialLinks;
    final bool isVerified;

    UserModel({
      required this.uid,
      required this.fullName,
      required this.email,
      required this.role,
      required this.department,
      this.section,
      this.year,
      this.dateOfBirth,
      this.profilePic,
      required this.phoneNumber,
      required this.whatsappNumber,
      this.socialLinks,
      this.isVerified = false,
    });

    factory UserModel.fromMap(Map<String, dynamic> data) {
      return UserModel(
        uid: data['uid'] ?? '',
        fullName: data['fullName'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? '',
        department: data['department'] ?? '',
        section: data['section'],
        year: data['year'],
        dateOfBirth: data['dateOfBirth'] != null
            ? DateTime.parse(data['dateOfBirth'])
            : null,
        profilePic: data['profilePicture'] ?? '',
        phoneNumber: data['phoneNumber'] ?? '',
        whatsappNumber: data['whatsappNumber'] ?? '',
        socialLinks: data['socialLinks'] ?? {},
        isVerified: data['isVerified'] ?? false,
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'role': role,
        'department': department,
        'section': section,
        'year': year,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'profilePicture': profilePic,
        'phoneNumber': phoneNumber,
        'whatsappNumber': whatsappNumber,
        'socialLinks': socialLinks,
        'isVerified': isVerified,
      };
    }
  }


  class UserProvider with ChangeNotifier {
    List<UserModel> _users = [];
    bool isLoading = false;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    List<UserModel> get users => _users;

    Future<void> fetchUsersByRole(String role) async {
      isLoading = true;
      notifyListeners();
      try {
        final snapshot = await _firestore.collection('roles')
            .doc(role)
            .collection('members')
            .get();
        _users =
            snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
      } catch (e) {
        print('Error fetching users by role: $e');
      }
      isLoading = false;
      notifyListeners();
    }

    Future<void> fetchAllUsers() async {
      isLoading = true;
      notifyListeners();
      List<UserModel> allUsers = [];

      try {
        final rolesSnapshot = await _firestore.collection('roles').get();
        for (var roleDoc in rolesSnapshot.docs) {
          final membersSnapshot = await _firestore.collection('roles').doc(roleDoc.id).collection('members').get();
          allUsers.addAll(membersSnapshot.docs.map((doc) => UserModel.fromMap(doc.data())));
        }
        _users = allUsers;
      } catch (e) {
        print('Error fetching all users: $e');
      }

      isLoading = false;
      notifyListeners();
    }
  }