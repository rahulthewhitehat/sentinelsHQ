import 'package:cloud_firestore/cloud_firestore.dart';
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

}