import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

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
    FirebaseFirestore.instance
        .collection('tasks')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        activeTasks = snapshot.docs.length;
      });
    });
  }

  void navigateTo(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Super Admin Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () => navigateTo('/settings'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          children: [
            _buildMenuItem(
              title: "User Management",
              icon: Icons.group,
              color: Colors.blue,
              route: '/user_management',
            ),
            _buildMenuItem(
              title: "Tasks ($activeTasks)",
              icon: Icons.task,
              color: Colors.orange,
              route: '/task_management',
            ),
            _buildMenuItem(
              title: "Resources",
              icon: Icons.link,
              color: Colors.green,
              route: '/resource_management',
            ),
            _buildMenuItem(
              title: "Team Management",
              icon: Icons.people,
              color: Colors.purple,
              route: '/team_management',
            ),
            _buildMenuItem(
              title: "Issues",
              icon: Icons.report,
              color: Colors.red,
              route: '/issue_management',
            ),
            _buildMenuItem(
              title: "Settings",
              icon: Icons.settings,
              color: Colors.grey,
              route: '/settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => navigateTo(route),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}