import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ViewIssuesScreen extends StatefulWidget {
  const ViewIssuesScreen({super.key});

  @override
  _ViewIssuesScreenState createState() => _ViewIssuesScreenState();
}

class _ViewIssuesScreenState extends State<ViewIssuesScreen> {
  String _filter = 'ALL';

  // Function to update issue status
  Future<void> _updateIssueStatus(String issueId, String newStatus) async {
    await FirebaseFirestore.instance.collection('issues').doc(issueId).update({
      'status': newStatus,
    });
  }

  // Function to launch call
  void _callUser(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Function to launch WhatsApp chat
  void _whatsappUser(String phoneNumber) async {
    final Uri uri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Function to add an issue with user data
  void _addIssue(AuthProvider authProvider) {
    TextEditingController descriptionController = TextEditingController();

    // Get current user info
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to raise an issue')),
      );
      return;
    }

    // Fetch user data from Firestore to get additional details
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((userDoc) {
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile not found')),
        );
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final String userName = userData['name'] ?? user.displayName ?? 'Unknown User';

      // Get user contact information - check if it exists in the user document
      String? userContact = userData['phoneNumber'];
      TextEditingController contactController = TextEditingController(text: userContact);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Raise an Issue'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Issue Description *'),
                  maxLines: 3,
                ),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact Number *'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                Text('Issue will be raised by: $userName',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (descriptionController.text.trim().isEmpty ||
                      contactController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All fields are required!')),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance.collection('issues').add({
                    'description': descriptionController.text.trim(),
                    'raisedBy': userName,
                    'raisedByUid': user.uid,
                    'contact': contactController.text.trim(),
                    'status': 'RAISED',
                    'timestamp': FieldValue.serverTimestamp(),
                    'userRole': authProvider.userRole,
                  });

                  // If the contact number has changed, update it in the user's profile
                  if (userContact != contactController.text.trim()) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'phoneNumber': contactController.text.trim()});

                    // If role exists, update in role-specific collection too
                    if (authProvider.userRole.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('roles')
                          .doc(authProvider.userRole)
                          .collection('members')
                          .doc(user.uid)
                          .update({'phoneNumber': contactController.text.trim()});
                    }
                  }

                  Navigator.of(context).pop();
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error retrieving user data: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isAdminOrSuperAdmin = authProvider.isAdmin || authProvider.isSuperAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Issues'),
        actions: [
          DropdownButton<String>(
            value: _filter,
            items: ['ALL', 'RAISED', 'ACK', 'FIXED', 'FIXED_ACK']
                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _filter = value!;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issues')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final issues = snapshot.data!.docs.where((doc) {
            if (_filter == 'ALL') return true;
            return (doc.data() as Map<String, dynamic>)['status'] == _filter;
          }).toList();

          if (issues.isEmpty) return const Center(child: Text('No issues found.'));

          return ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              final issueId = issue.id;
              final data = issue.data() as Map<String, dynamic>;
              final String currentUserUid = authProvider.user?.uid ?? '';
              final bool isIssueRaiser = data['raisedByUid'] == currentUserUid;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Issue ID: ${issueId.substring(0, 8)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)
                          ),
                          _getStatusChip(data["status"]),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Description: ${data["description"]}'),
                      Text('Raised By: ${data["raisedBy"]}'),
                      Text('Contact: ${data["contact"]}'),
                      if (data.containsKey('timestamp') && data['timestamp'] != null)
                        Text(
                          'Created: ${_formatTimestamp(data["timestamp"] as Timestamp)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),

                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.call, color: Colors.green),
                            onPressed: () => _callUser(data["contact"]),
                          ),
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.whatsapp),
                            color: Colors.green,
                            onPressed: () => _whatsappUser(data["contact"]),
                          ),
                          const SizedBox(width: 10),

                          // Show buttons based on role and issue status
                          if (isAdminOrSuperAdmin) ...[
                            // Admin/SuperAdmin can only ACK and mark as FIXED
                            if (data["status"] == "RAISED") ...[
                              ElevatedButton(
                                onPressed: () => _updateIssueStatus(issueId, "ACK"),
                                child: const Text("Acknowledge"),
                              ),
                            ],
                            if (data["status"] == "ACK") ...[
                              ElevatedButton(
                                onPressed: () => _updateIssueStatus(issueId, "FIXED"),
                                child: const Text("Mark as Fixed"),
                              ),
                            ],
                          ] else if (isIssueRaiser || !isAdminOrSuperAdmin) ...[
                            // Regular users and the issue raiser can see confirm fix button
                            if (data["status"] == "FIXED") ...[
                              ElevatedButton(
                                onPressed: () => _updateIssueStatus(issueId, "FIXED_ACK"),
                                child: const Text("Confirm Fix"),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addIssue(authProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper to format timestamp
  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Helper to create status chips with colors
  Widget _getStatusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'RAISED':
        chipColor = Colors.red;
        break;
      case 'ACK':
        chipColor = Colors.orange;
        break;
      case 'FIXED':
        chipColor = Colors.blue;
        break;
      case 'FIXED_ACK':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(status),
      backgroundColor: chipColor.withOpacity(0.2),
      labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}