import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int activeTasks = 0;
  int pendingIssues = 0;

  @override
  void initState() {
    super.initState();
    fetchActiveTasks();
    fetchPendingIssues();
  }

  Future<void> fetchActiveTasks() async {
    FirebaseFirestore.instance
        .collection('generalTasks')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        activeTasks = snapshot.docs.length;
      });
    });
  }

  Future<void> fetchPendingIssues() async {
    FirebaseFirestore.instance
        .collection('issues')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        pendingIssues = snapshot.docs.length;
      });
    });
  }

  void navigateTo(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size to calculate proper item sizes
    final _ = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        actions: [
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            // Significantly increased height for each item
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          children: [  /*
            _buildMenuItem(
              title: "Analytics",
              icon: Icons.bar_chart,
              color: Colors.teal,
              route: '/analytics',
              iconSize: 36,
            ), */
            _buildMenuItem(
              title: "Manage Team",
              icon: Icons.group,
              color: Colors.blue,
              route: '/user_management',
              iconSize: 36, // Slightly reduced icon size
            ),
            _buildMenuItemWithBadge(
              title: "Manage Tasks",
              icon: Icons.task,
              color: Colors.orange,
              route: '/task_management',
              badgeCount: activeTasks,
              iconSize: 36,
            ),
            _buildMenuItem(
              title: "Manage Resources",
              icon: Icons.folder_shared,
              color: Colors.green,
              route: '/resource_management',
              iconSize: 36,
            ),
            _buildMenuItem(
              title: "Manage Events",
              icon: Icons.event,
              color: Colors.amber,
              route: '/events_calendar',
              iconSize: 36,
            ),
            _buildMenuItemWithBadge(
              title: "View Issue Reports",
              icon: Icons.report_problem,
              color: Colors.red,
              route: '/issue_screen',
              badgeCount: pendingIssues,
              iconSize: 36,
            ),
            _buildMenuItem(
              title: "Settings",
              icon: Icons.settings,
              color: Colors.grey,
              route: '/settings',
              iconSize: 36,
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
    double iconSize = 40,
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
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate sizes based on available constraints
              return Column(
                mainAxisSize: MainAxisSize.min, // Use minimum space needed
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: iconSize, color: Colors.white),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemWithBadge({
    required String title,
    required IconData icon,
    required Color color,
    required String route,
    required int badgeCount,
    double iconSize = 36,
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
          padding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main content - exactly like regular menu items
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: iconSize, color: Colors.white),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              // Badge overlay in top-right corner
              if (badgeCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}