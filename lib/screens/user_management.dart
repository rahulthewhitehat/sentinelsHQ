import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).fetchUsers();
  }

  void _showUserDialog({UserModel? user}) {
    final _nameController = TextEditingController(text: user?.name ?? '');
    final _emailController = TextEditingController(text: user?.email ?? '');
    String _selectedRole = user?.role ?? 'Member';
    String? _team = user?.team;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? "Add User" : "Edit User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: InputDecoration(labelText: "Name")),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                onChanged: (val) => setState(() => _selectedRole = val!),
                items: ["Super Admin", "Admin", "Member"]
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
              ),
              if (_selectedRole == "Member")
                TextField(
                  decoration: InputDecoration(labelText: "Team (Optional)"),
                  onChanged: (val) => _team = val,
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                if (user == null) {
                  userProvider.addUser(UserModel(
                    uid: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    email: _emailController.text,
                    role: _selectedRole,
                    team: _team,
                    createdAt: DateTime.now(),
                  ));
                } else {
                  userProvider.updateUser(user);
                }
                Navigator.pop(context);
              },
              child: Text(user == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String uid) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to remove this user?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).deleteUser(uid);
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("User Management"),
          bottom: TabBar(
            tabs: [Tab(text: "Admins"), Tab(text: "Members")],
          ),
        ),
        body: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return TabBarView(
              children: [
                _buildUserList(userProvider.getAdmins()),
                _buildUserList(userProvider.getMembers()),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showUserDialog(),
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text(user.name),
          subtitle: Text(user.role),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: Icon(Icons.edit), onPressed: () => _showUserDialog(user: user)),
              IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteUser(user.uid)),
            ],
          ),
        );
      },
    );
  }
}