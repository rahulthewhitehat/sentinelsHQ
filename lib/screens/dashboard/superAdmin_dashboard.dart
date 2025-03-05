import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuperAdminDashboard extends StatefulWidget {
  @override
  _SuperAdminDashboardState createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int activeTasks = 0;

  @override
  void initState() {
    super.initState();
    fetchActiveTasks();
  }

  Future<void> fetchActiveTasks() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('status', isEqualTo: 'active')
        .get();

    setState(() {
      activeTasks = snapshot.docs.length;
    });
  }

  void navigateTo(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Super Admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => navigateTo('/settings'),
          )
        ],
      ),
      body: GridView(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        children: [
          _buildMenuItem(
              "User Management", Icons.group, Colors.blue, '/user_management'),
          _buildMenuItem("Tasks ($activeTasks)", Icons.task,
              Colors.orange, '/task_management'),
          _buildMenuItem("Resources", Icons.link, Colors.green,
              '/resource_management'),
          _buildMenuItem(
              "Team Management", Icons.people, Colors.purple, '/team_management'),
          _buildMenuItem(
              "Issues", Icons.report, Colors.red, '/issue_management'),
          _buildMenuItem("Settings", Icons.settings, Colors.grey, '/settings'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => navigateTo(route),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: color.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}