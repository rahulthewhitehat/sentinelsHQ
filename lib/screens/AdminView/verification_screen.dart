import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to verify user
  void _verifyUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isVerified': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User verified successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Verification')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('isVerified', isEqualTo: false) // Fetch only unverified users
            .orderBy('createdAt', descending: true) // Newest users first
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return Center(child: Text('No users pending verification'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(userData['name'] ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${userData['email']}'),
                      Text('Role: ${userData['role']}'),
                      Text(
                        'Joined: ${DateTime.fromMillisecondsSinceEpoch(userData['createdAt'].seconds * 1000)}',
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _verifyUser(user.id),
                    child: Text('Verify'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}