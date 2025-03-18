import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/user_provider.dart';
import 'user_detail_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String? _selectedRole;
  List<String> _roles = [];
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchRoles() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('roles').get();
      setState(() {
        _roles = snapshot.docs.map((doc) => doc.id).toList();
        _selectedRole = _roles.isNotEmpty ? _roles.first : null;
      });
      if (_selectedRole != null) {
        Provider.of<UserProvider>(context, listen: false).fetchUsersByRole(_selectedRole!);
      }
    } catch (e) {
      //print('Error fetching roles: $e');
    }
  }

  void _onRoleChanged(String? newRole) {
    if (newRole != null) {
      setState(() {
        _selectedRole = newRole;
      });
      Provider.of<UserProvider>(context, listen: false).fetchUsersByRole(newRole);
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      } else {
        // Delay to ensure the search field is rendered before requesting focus
        Future.delayed(Duration(milliseconds: 100), () {
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  void _callUser(String phoneNumber) async {
    final status = await Permission.phone.request();
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final Uri callUri = Uri(scheme: 'tel', path: cleanPhone);
    if (status.isGranted) {
      try {
        if (await canLaunchUrl(callUri)) {
          await launchUrl(callUri);
        } else {
          throw 'Could not launch phone call';
        }
      } catch (e) {
        debugPrint('Error making phone call: $e');
      }
    } else {
      //print("No Permission");
    }
  }

  void _whatsappUser(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      //print("Could not launch WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Filtered users based on role and search query
    final filteredUsers = userProvider.users.where((user) =>
        user.fullName.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_isSearching ? 100 : 60),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .appBarTheme
                  .backgroundColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2)
                )
              ]
          ),
          child: SafeArea(
            child: _isSearching
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: _toggleSearch,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: "Search users...",
                            border: InputBorder.none,
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                                : null,
                          ),
                          style: TextStyle(fontSize: 18),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
                : AppBar(
              title: Text("User Management"),
              actions: [
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _toggleSearch
                ),
              ],
            ),
          ),
        ),
      ),

      body: Column(

        children: [
          // Role Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedRole,
              items: _roles.map((role) =>
                  DropdownMenuItem(
                      value: role,
                      child: Text(role)
                  )
              ).toList(),
              onChanged: _onRoleChanged,
              decoration: InputDecoration(
                labelText: "Select Role",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
          ),

          // User List
          Expanded(
            child: userProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return _buildUserCard(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserDetailScreen(user: user)
            )
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
        ),
        elevation: 3,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
              user.fullName,
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          subtitle: Text(
              user.department,
              style: TextStyle(color: Colors.grey[600])
          ),

          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  icon: Icon(Icons.call, color: Colors.teal),
                  onPressed: () => _callUser(user.phoneNumber)
              ),
              IconButton(
                  icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                  onPressed: () => _whatsappUser(user.whatsappNumber)
              ),
            ],
          ),
        ),
      ),
    );
  }
}