import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Overview", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Task Overview (Pending / Completed)
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                var tasks = snapshot.data!.docs;
                int pendingTasks = tasks.where((t) => t['status'] == 'Pending').length;
                int completedTasks = tasks.where((t) => t['status'] == 'Completed').length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard("Pending Tasks", pendingTasks.toString(), Colors.red),
                    _buildStatCard("Completed Tasks", completedTasks.toString(), Colors.green),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Button Navigation
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildDashboardButton(context, "Manage Tasks", Icons.task, Colors.blue, () {
                    Navigator.pushNamed(context, '/manageTasks');
                  }),
                  _buildDashboardButton(context, "Resources", Icons.folder, Colors.orange, () {
                    Navigator.pushNamed(context, '/resources');
                  }),
                  _buildDashboardButton(context, "Issues", Icons.report_problem, Colors.red, () {
                    Navigator.pushNamed(context, '/issues');
                  }),
                  _buildDashboardButton(context, "Announcements", Icons.announcement, Colors.purple, () {
                    Navigator.pushNamed(context, '/announcements');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 140,
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 5),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}