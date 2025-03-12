import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'about_screen.dart'; // Import your About screen

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _confirmLogout(BuildContext context) {
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
                //    subtitle: const Text("Coming soon...", style: TextStyle(color: Colors.grey)),
                    onTap: () {}, // Placeholder
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
                onTap: () => _confirmLogout(context),
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