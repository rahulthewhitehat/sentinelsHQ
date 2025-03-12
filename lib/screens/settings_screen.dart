import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sentinelshq/screens/AdminView/user_detail_screen.dart';
import 'package:sentinelshq/providers/user_provider.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout", style: TextStyle(color: Colors.blue)),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushReplacementNamed('/login'); // Redirect to login
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchAndNavigateToUserDetail(BuildContext context) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to view your profile')),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Get user role first
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        // Close loading indicator
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile not found')),
        );
        return;
      }

      final String role = userDoc.data()?['role'] ?? '';

      // Fetch the detailed user data from the roles collection
      final memberDoc = await FirebaseFirestore.instance
          .collection('roles')
          .doc(role)
          .collection('members')
          .doc(currentUser.uid)
          .get();

      // Close loading indicator
      Navigator.of(context).pop();

      if (!memberDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User details not found in role members')),
        );
        return;
      }

      // Create UserModel from data
      final userData = memberDoc.data()!;
      userData['uid'] = currentUser.uid; // Ensure UID is included

      final UserModel user = UserModel.fromMap(userData);

      // Navigate to user detail screen
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserDetailScreen(user: user)
          )
      );
    } catch (e) {
      // Close loading indicator if still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: const Text("View/Edit Profile", style: TextStyle(color: Colors.blue)),
                    onTap: () => _fetchAndNavigateToUserDetail(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout", style: TextStyle(color: Colors.red)),
                onTap: () => confirmLogout(context),
              ),
            ),
            const SizedBox(height: 5),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: const Text("About", style: TextStyle(color: Colors.blue)),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}