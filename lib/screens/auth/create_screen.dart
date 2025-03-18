import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sentinelshq/DataBase/handle_DB.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';


class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _profilePictureUrl = TextEditingController();

  // Dropdown values
  String? _selectedDepartment;
  String? _selectedSection;
  int? _selectedYear;
  String? _selectedRole;

  // Date of Birth
  DateTime? _selectedDateOfBirth;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Dropdown options
  final List<String> _departments = [
    'CSE',
    'IT',
    'CSBS',
    'CSE-CS',
    'CSD',
    'AIML',
    'AIDS',
    'ECE',
    'EEE',
    'OTHERS'
  ];

  final List<String> _sections = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
  final List<int> _years = [1, 2, 3, 4];

  List<String> _roles = [];

  Future<void> loadRoles() async {
    List<String> roles = await handleDB.fetchRoles();
    setState(() {
      _roles = roles;
    });
  }

  // Fetch roles from Firestore during initialization
  @override
  void initState() {
    super.initState();
    loadRoles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _rollNumberController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    super.dispose();
  }


  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      // Modify this part to use .text instead of passing controllers
      final userData = {
        'fullName': _nameController.text.trim(),
        'rollNumber': _rollNumberController.text.trim(),
        'department': _selectedDepartment,
        'section': _selectedSection,
        'year': _selectedYear,
        'profilePicture': _profilePictureUrl.text.trim().isEmpty
            ? null
            : _profilePictureUrl.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'whatsappNumber': _whatsappController.text.trim(),
        'isVerified': false,
        'dateOfBirth': _selectedDateOfBirth?.toIso8601String(), // Add DOB
        'socialLinks': {
          if (_instagramController.text.trim().isNotEmpty)
            'instagram': _instagramController.text.trim(),
          if (_linkedinController.text.trim().isNotEmpty)
            'linkedin': _linkedinController.text.trim(),
          if (_githubController.text.trim().isNotEmpty)
            'github': _githubController.text.trim(),
        },
      };

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.createAccount(
        _emailController.text.trim(),
        _passwordController.text,
        userData,
        role: _selectedRole, // Pass the selected role
      );

      if (success) {
        // Show verification message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created! Please check your email to verify your account.'),
            duration: Duration(seconds: 5),
          ),
        );

        // Navigate back to login screen
        Navigator.of(context).pop();
      }
    }
  }

  // Function to show date picker
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        elevation: 0,
      ),
      body: authProvider.isLoading
          ? LoadingIndicator()
          : SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SentinelsHQ Welcomes You!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your account to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Select Role',
                      prefixIcon: Icon(Icons.group, color: Colors.grey),
                    ),
                    items: _roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a role';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // Personal Information Section
                  _buildSectionTitle('Personal Information'),
                  SizedBox(height: 16),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person, color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Date of Birth
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                    ),
                    controller: TextEditingController(
                      text: _selectedDateOfBirth != null
                          ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                          : '',
                    ),
                    onTap: () => _selectDateOfBirth(context),
                    validator: (value) {
                      if (_selectedDateOfBirth == null) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@rajalakshmi.edu.in')) {
                        return 'Please enter your valid college email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // Academic Information Section
                  _buildSectionTitle('Academic Information'),
                  SizedBox(height: 16),

                  // Roll Number
                  TextFormField(
                    controller: _rollNumberController,
                    decoration: InputDecoration(
                      labelText: 'Roll Number',
                      prefixIcon: Icon(Icons.numbers, color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your roll number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Department Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.business, color: Colors.grey),
                    ),
                    items: _departments.map((department) {
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
                  ),
                  SizedBox(height: 16),

                  // Row for Section and Year
                  Row(
                    children: [
                      // Section Dropdown
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSection,
                          decoration: InputDecoration(
                            labelText: 'Section',
                            prefixIcon: Icon(Icons.group, color: Colors.grey),
                          ),
                          items: _sections.map((section) {
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
                          ),
                          items: _years.map((year) {
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
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Contact Information Section
                  _buildSectionTitle('Contact Information'),
                  SizedBox(height: 16),

                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone, color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // WhatsApp Number
                  TextFormField(
                    controller: _whatsappController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'WhatsApp Number',
                      prefixIcon: Icon(FontAwesomeIcons.whatsapp, color: Colors.green.shade800,),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Social Media Section
                  _buildSectionTitle('Social Media (Optional)'),
                  SizedBox(height: 16),

                  // Instagram
                  TextFormField(
                    controller: _instagramController,
                    decoration: InputDecoration(
                      labelText: 'Instagram Profile URL',
                      prefixIcon: Icon(Icons.camera_alt, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),

                  // LinkedIn
                  TextFormField(
                    controller: _linkedinController,
                    decoration: InputDecoration(
                      labelText: 'LinkedIn Profile URL',
                      prefixIcon: Icon(Icons.work, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),

                  // GitHub
                  TextFormField(
                    controller: _githubController,
                    decoration: InputDecoration(
                      labelText: 'GitHub Profile URL',
                      prefixIcon: Icon(Icons.code, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Profile Pic Link
                  TextFormField(
                    controller: _profilePictureUrl,
                    decoration: InputDecoration(
                      labelText: 'Profile Picture URL',
                      prefixIcon: Icon(Icons.photo, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Create Account Button
                  CustomButton(
                    text: 'Create Account',
                    onPressed: _createAccount,
                    isFullWidth: true,
                  ),

                  // Error Message
                  if (authProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        authProvider.errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  SizedBox(height: 24),

                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}