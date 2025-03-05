import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
          bottom: TabBar(
            tabs: [Tab(text: "Profile"), Tab(text: "About")],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProfileTab(context),
            _buildAboutTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {}, // Placeholder for View/Edit Profile
            child: Text("View/Edit Profile"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _confirmLogout(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return Center(
      child: ElevatedButton(
        onPressed: () {}, // Placeholder for About Section
        child: Text("About"),
      ),
    );
  }
}