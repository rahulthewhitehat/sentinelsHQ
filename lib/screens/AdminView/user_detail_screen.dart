import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../providers/user_provider.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late bool _isEditing;
  late UserModel _currentUser;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _instagramController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;
  late TextEditingController _profilePictureController;

  // Dropdown values
  String? _selectedDepartment;
  String? _selectedSection;
  int? _selectedYear;

  // Date of Birth
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _isEditing = false;
    _currentUser = widget.user;

    // Initialize controllers
    _nameController = TextEditingController(text: _currentUser.fullName);
    _emailController = TextEditingController(text: _currentUser.email);
    _phoneController = TextEditingController(text: _currentUser.phoneNumber);
    _whatsappController =
        TextEditingController(text: _currentUser.whatsappNumber);
    _instagramController = TextEditingController(
        text: _currentUser.socialLinks?['instagram'] ?? ''
    );
    _linkedinController = TextEditingController(
        text: _currentUser.socialLinks?['linkedin'] ?? ''
    );
    _githubController = TextEditingController(
        text: _currentUser.socialLinks?['github'] ?? ''
    );
    _profilePictureController = TextEditingController(
        text: _currentUser.profilePic ?? ''
    );

    _selectedDepartment = _currentUser.department;
    _selectedSection = _currentUser.section;
    _selectedYear = _currentUser.year;
    _selectedDateOfBirth = _currentUser.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _profilePictureController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    // Implement save logic
    final updatedUserData = {
      'fullName': _nameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'whatsappNumber': _whatsappController.text.trim(),
      'department': _selectedDepartment,
      'section': _selectedSection,
      'year': _selectedYear,
      'profilePicture': _profilePictureController.text.trim(),
      'socialLinks': {
        if (_instagramController.text
            .trim()
            .isNotEmpty)
          'instagram': _instagramController.text.trim(),
        if (_linkedinController.text
            .trim()
            .isNotEmpty)
          'linkedin': _linkedinController.text.trim(),
        if (_githubController.text
            .trim()
            .isNotEmpty)
          'github': _githubController.text.trim(),
      },
    };

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateUserProfile(
        widget.user.uid,
        updatedUserData,
        widget.user.role
    );

    if (success) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  // Date of Birth picker
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  // New method to handle launching URLs or apps
  Future<void> _launchAction(String url,
      {LaunchMode mode = LaunchMode.platformDefault}) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: mode);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching $url: $e')),
      );
    }
  }

  // Method to initiate a phone call
  Future<void> _callUser(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final Uri callUri = Uri(scheme: 'tel', path: cleanPhone);

    try {
      final status = await Permission.phone.request();
      if (status.isGranted) {
        await _launchAction(
            callUri.toString(), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phone call permission denied')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making phone call: $e')),
      );
    }
  }

  // Method to open WhatsApp
  void _whatsappUser(String phoneNumber) {
    final Uri whatsappUri = Uri.parse("https://wa.me/+91$phoneNumber");
    _launchAction(whatsappUri.toString(), mode: LaunchMode.externalApplication);
  }

  // Modify the phone number field to include call and WhatsApp icons
  Widget _buildContactField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? actionType, // 'call', 'whatsapp', or null
    bool showActionIcon = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: Colors.grey),
                enabled: _isEditing,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),
          if (!_isEditing && showActionIcon && controller.text.isNotEmpty)
            Row(
              children: [
                if (actionType == 'call')
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.green),
                    onPressed: () => _callUser(controller.text),
                  ),
                if (actionType == 'whatsapp')
                  IconButton(
                    icon: FaIcon(
                        FontAwesomeIcons.whatsapp, color: Colors.green),
                    onPressed: () => _whatsappUser(controller.text),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // Modify social media fields to include link opening
  Widget _buildSocialMediaField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) urlValidator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: Colors.grey),
                enabled: _isEditing,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: urlValidator,
            ),
          ),
          if (!_isEditing && controller.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.open_in_browser, color: Colors.blue),
              onPressed: () => _launchAction(controller.text),
            ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View / Edit Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 60,
                backgroundImage: _currentUser.profilePic != null &&
                    _currentUser.profilePic!.isNotEmpty
                    ? NetworkImage(_currentUser.profilePic!)
                    : null,
                child: _currentUser.profilePic == null ||
                    _currentUser.profilePic!.isEmpty
                    ? Icon(Icons.person, size: 60)
                    : null,
              ),
              SizedBox(height: 16),
              Text(
                _currentUser.fullName,
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge,
              ),
              Text(
                _currentUser.role,
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
              SizedBox(height: 24),

              // Phone Number with Call Icon
              _buildContactField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                actionType: 'call',
                showActionIcon: true,
              ),

              // WhatsApp Number with WhatsApp Icon
              _buildContactField(
                controller: _whatsappController,
                label: 'WhatsApp Number',
                icon: FontAwesomeIcons.whatsapp,
                actionType: 'whatsapp',
                showActionIcon: true,
              ),

              // Email Field with Mail Icon
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: Colors.grey),
                          enabled: false,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (!_isEditing && _emailController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.mail_outline, color: Colors.blue),
                        onPressed: () =>
                            _launchAction('mailto:${_emailController.text}'),
                      ),
                  ],
                ),
              ),

              // Social Media Fields with Link Icons
              _buildSocialMediaField(
                controller: _instagramController,
                label: 'Instagram Profile URL',
                icon: FontAwesomeIcons.instagram,
                urlValidator: (value) {
                  if (value != null && value.isNotEmpty &&
                      !value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              _buildSocialMediaField(
                controller: _linkedinController,
                label: 'LinkedIn Profile URL',
                icon: FontAwesomeIcons.linkedin,
                urlValidator: (value) {
                  if (value != null && value.isNotEmpty &&
                      !value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              _buildSocialMediaField(
                controller: _githubController,
                label: 'GitHub Profile URL',
                icon: FontAwesomeIcons.github,
                urlValidator: (value) {
                  if (value != null && value.isNotEmpty &&
                      !value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),

              // Editable Fields
              _buildEditableField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                isEditable: _isEditing,
              ),

              _buildDateOfBirthField(context),
              /*
              _buildEditableField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                isEditable: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              _buildEditableField(
                controller: _whatsappController,
                label: 'WhatsApp Number',
                icon: FontAwesomeIcons.whatsapp,
                isEditable: _isEditing,
                keyboardType: TextInputType.phone,
              ), */
              _buildDepartmentSection(),
              // _buildSocialMediaSection(),

              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CustomButton(
                    text: 'Save Changes',
                    onPressed: _saveChanges,
                    isFullWidth: true,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isEditable = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          enabled: isEditable,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildDateOfBirthField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: Icon(Icons.calendar_today, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        controller: TextEditingController(
          text: _selectedDateOfBirth != null
              ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!
              .month}/${_selectedDateOfBirth!.year}'
              : '',
        ),
        onTap: _isEditing ? () => _selectDateOfBirth(context) : null,
      ),
    );
  }

  Widget _buildDepartmentSection() {
    // Dropdown options (you might want to move these to a constants file)
    final List<String> departments = [
      'CSE', 'IT', 'CSBS', 'CSE-CS', 'CSD',
      'AIML', 'AIDS', 'ECE', 'EEE', 'OTHERS'
    ];
    final List<String> sections = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
    final List<int> years = [1, 2, 3, 4];

    if (!_isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department Details',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium,
            ),
            SizedBox(height: 8),
            // Department Read-only Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Text(
                'Department: $_selectedDepartment',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 16),
            // Section and Year Row
            Row(
              children: [
                // Section Read-only Box
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: Text(
                      'Section: $_selectedSection',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Year Read-only Box
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: Text(
                      'Year: $_selectedYear',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Department Dropdown
        DropdownButtonFormField<String>(
          value: _selectedDepartment,
          decoration: InputDecoration(
            labelText: 'Department',
            prefixIcon: Icon(Icons.business, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: departments.map((department) {
            return DropdownMenuItem(
              value: department,
              child: Text(department),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDepartment = value!;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a department';
            }
            return null;
          },
        ),
        SizedBox(height: 16),

        // Section and Year Row
        Row(
          children: [
            // Section Dropdown
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSection,
                decoration: InputDecoration(
                  labelText: 'Section',
                  prefixIcon: Icon(Icons.group, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: sections.map((section) {
                  return DropdownMenuItem(
                    value: section,
                    child: Text(section),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSection = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a section';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),

            // Year Dropdown
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: InputDecoration(
                  labelText: 'Year',
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: years.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text('Year $year'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a year';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}