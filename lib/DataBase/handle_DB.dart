import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class handleDB {

  static Future<List<String>> fetchRoles() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('roles')
          .get();
      List<String> roles = snapshot.docs.map((doc) => doc.id).toList();
      return roles;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching roles: $e");
      }
      return [];
    }
  }

  static Future<List<String>> fetchRolesWithAll() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('roles')
          .get();
      List<String> roles = snapshot.docs.map((doc) => doc.id).toList();
      roles.insert(0, 'All'); // Add "All" at the beginning
      return roles;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching roles: $e");
      }
      return [];
    }
  }

   static Future<String?> getUserRole() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    if (user == null) return null; // No user logged in

    DocumentSnapshot userDoc = await firestore.collection("users").doc(user.uid).get();

    if (userDoc.exists) {
      return userDoc['role']; // Get the role field
    }
    return null; // Role not found
  }

}