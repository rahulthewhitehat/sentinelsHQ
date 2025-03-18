// event_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import '/../../providers/event_provider.dart';


class EventCalendarScreen2 extends StatefulWidget {
  const EventCalendarScreen2({super.key});

  @override
  _EventCalendarScreen2State createState() => _EventCalendarScreen2State();
}

class _EventCalendarScreen2State extends State<EventCalendarScreen2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchEvents();
    });
  }

  // Launch URL helper
  Future<void> _launchURL(String url, {LaunchMode mode = LaunchMode.platformDefault}) async {
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



  // Show add/edit event dialog
  void _showEventDialog(BuildContext context, {Map<String, dynamic>? event}) {
    showDialog(
      context: context,
      builder: (context) => EventFormDialog(initialEvent: event),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PROPOSED':
        return Colors.red.shade600;
      case 'CORE_APPROVED':
        return Colors.orange.shade700;
      case 'FACULTY_APPROVED':
        return Colors.yellow.shade600;
      case 'VENUE_BOOKED':
        return Colors.green.shade700;
      case 'CONFIRMED':
        return Colors.blue.shade600;
      case 'IN_PROGRESS':
        return Colors.indigo.shade600;
      case 'COMPLETED':
        return Colors.deepPurple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  // Format date
  String _formatDate(String? dateString) {
    if (dateString == null) return 'TBD';
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Event Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<EventProvider>(context, listen: false).fetchEvents();
            },
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (eventProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    eventProvider.errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: () => eventProvider.fetchEvents(),
                  ),
                ],
              ),
            );
          }

          if (eventProvider.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_busy, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No events found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Event'),
                    onPressed: () => _showEventDialog(context),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ListView.builder(
              itemCount: eventProvider.events.length,
              itemBuilder: (context, index) {
                final event = eventProvider.events[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Title & Status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event["name"] ?? "Untitled Event",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700, // Bold Title
                                  letterSpacing: 0.8,
                                  color: Colors.black87,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black12,
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Chip(
                              backgroundColor: _getStatusColor(event["status"] ?? "PROPOSED"),
                              label: Text(
                                event["status"] ?? "PROPOSED",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Event Description
                        if (event["description"] != null && event["description"].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              event["description"],
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.5,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),

                        // Event Date
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              "Proposed Date: ${_formatDate(event["dates"])}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Chief Guests
                        if (event["chiefGuests"] != null && (event["chiefGuests"] as List).isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.star, size: 18, color: Colors.amber),
                              const SizedBox(width: 8),
                              const Text("Chief Guests:", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ..._buildGuestList(event["chiefGuests"]),
                        ],

                        // Speakers
                        if (event["speakers"] != null && (event["speakers"] as List).isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.mic, size: 18, color: Colors.green),
                              const SizedBox(width: 8),
                              const Text("Speakers:", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ..._buildGuestList(event["speakers"]),
                        ],

                        // Links
                        if (event["links"] != null && (event["links"] as List).isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.link, size: 18, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text("Links:", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _buildLinks(event["links"]),
                        ],

                        const SizedBox(height: 12),

                        // Actions
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _showEventDialog(context),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

// Helper method to build guest lists
  List<Widget> _buildGuestList(List<dynamic> guests) {
    return guests.map((guest) {
      return Padding(
        padding: const EdgeInsets.only(left: 24, bottom: 4),
        child:Text(
          "${guest["name"]} - ${guest["designation"]}, ${guest["organization"]}",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      );
    }).toList();
  }

// Helper method to build event links
  Widget _buildLinks(List<dynamic> links) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: links.map((link) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: GestureDetector(
              onTap: () => _launchURL(link["url"]),
              child: Text(
                link["title"],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class EventFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialEvent;

  const EventFormDialog({super.key, this.initialEvent});

  @override
  _EventFormDialogState createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  late List<Map<String, dynamic>> _chiefGuests;
  late List<Map<String, dynamic>> _speakers;
  late List<Map<String, dynamic>> _links;

  DateTime? _proposedDate;
  String _status = 'PROPOSED';

  final List<String> _statusOptions = [
    'PROPOSED',
  ];

  bool _isEditing = false;
  String? _eventId;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initialEvent != null;
    _eventId = _isEditing ? widget.initialEvent!["id"] : null;

    // Initialize controllers and lists
    if (_isEditing) {
      _nameController.text = widget.initialEvent!["name"] ?? '';
      _descriptionController.text = widget.initialEvent!["description"] ?? '';

      _status = widget.initialEvent!["status"] ?? 'PROPOSED';

      if (widget.initialEvent!["dates"] != null) {
        try {
          _proposedDate = DateTime.parse(widget.initialEvent!["dates"]);
        } catch (e) {
          _proposedDate = null;
        }
      }

      // Initialize lists from initial event
      _chiefGuests = List<Map<String, dynamic>>.from(
          widget.initialEvent!["chiefGuests"] ?? []);
      _speakers =
      List<Map<String, dynamic>>.from(widget.initialEvent!["speakers"] ?? []);
      _links =
      List<Map<String, dynamic>>.from(widget.initialEvent!["links"] ?? []);
    } else {
      // Initialize empty lists for new event
      _chiefGuests = [];
      _speakers = [];
      _links = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Save event
  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final eventData = {
      "name": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "chiefGuests": _chiefGuests,
      "speakers": _speakers,
      "links": _links,
      "dates": _proposedDate?.toIso8601String(),
      "status": _status,
    };

    bool success;
    if (_isEditing) {
      success = await Provider.of<EventProvider>(context, listen: false)
          .updateEvent(_eventId!, eventData);
    } else {
      success = await Provider.of<EventProvider>(context, listen: false)
          .addEvent(eventData);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final bool isIOS = Platform.isIOS;
    final DateTime now = DateTime.now();

    if (isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: CupertinoDatePicker(
                initialDateTime: _proposedDate ?? now,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    _proposedDate = newDate;
                  });
                },
              ),
            ),
          );
        },
      );
    } else {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _proposedDate ?? now,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 5),
      );
      if (picked != null && picked != _proposedDate) {
        setState(() {
          _proposedDate = picked;
        });
      }
    }
  }

  // Add/edit chief guest
  void _editChiefGuest(BuildContext context, [Map<String, dynamic>? guest, int? index]) {
    final nameController = TextEditingController(text: guest?["name"] ?? '');
    final designationController = TextEditingController(text: guest?["designation"] ?? '');
    final organizationController = TextEditingController(text: guest?["organization"] ?? '');
    final contactController = TextEditingController(text: guest?["contact"] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            guest == null ? 'Add Chief Guest' : 'Edit Chief Guest',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(nameController, 'Name *', Icons.person, true),
                  const SizedBox(height: 10),
                  _buildTextField(designationController, 'Designation', Icons.badge),
                  const SizedBox(height: 10),
                  _buildTextField(organizationController, 'Organization', Icons.business),
                  const SizedBox(height: 10),
                  _buildTextField(contactController, 'Contact Info', Icons.phone),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is required')),
                  );
                  return;
                }

                final newGuest = {
                  "name": nameController.text.trim(),
                  "designation": designationController.text.trim(),
                  "organization": organizationController.text.trim(),
                  "contact": contactController.text.trim(),
                };

                setState(() {
                  if (index != null) {
                    _chiefGuests[index] = newGuest;
                  } else {
                    _chiefGuests.add(newGuest);
                  }
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Add/edit speaker
  void _editSpeaker(BuildContext context, [Map<String, dynamic>? speaker, int? index]) {
    final nameController = TextEditingController(text: speaker?["name"] ?? '');
    final designationController = TextEditingController(text: speaker?["designation"] ?? '');
    final organizationController = TextEditingController(text: speaker?["organization"] ?? '');
    final contactController = TextEditingController(text: speaker?["contact"] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            speaker == null ? 'Add Speaker' : 'Edit Speaker',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(nameController, 'Name *', Icons.person, true),
                  const SizedBox(height: 10),
                  _buildTextField(designationController, 'Designation', Icons.badge),
                  const SizedBox(height: 10),
                  _buildTextField(organizationController, 'Organization', Icons.business),
                  const SizedBox(height: 10),
                  _buildTextField(contactController, 'Contact Info', Icons.phone),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is required')),
                  );
                  return;
                }

                final newSpeaker = {
                  "name": nameController.text.trim(),
                  "designation": designationController.text.trim(),
                  "organization": organizationController.text.trim(),
                  "contact": contactController.text.trim(),
                };

                setState(() {
                  if (index != null) {
                    _speakers[index] = newSpeaker;
                  } else {
                    _speakers.add(newSpeaker);
                  }
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editLink(BuildContext context, [Map<String, dynamic>? link, int? index]) {
    final titleController = TextEditingController(text: link?["title"] ?? '');
    final urlController = TextEditingController(text: link?["url"] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            link == null ? 'Add Link' : 'Edit Link',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(titleController, 'Title *', Icons.title, true),
                  const SizedBox(height: 10),
                  _buildTextField(urlController, 'URL *', Icons.link),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (titleController.text.trim().isEmpty || urlController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title and URL are required')),
                  );
                  return;
                }

                final newLink = {
                  "title": titleController.text.trim(),
                  "url": urlController.text.trim(),
                };

                setState(() {
                  if (index != null) {
                    _links[index] = newLink;
                  } else {
                    _links.add(newLink);
                  }
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Reusable Input Field Widget
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, [bool isRequired = false]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        hintText: isRequired ? '$hint (Required)' : hint,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 600),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditing ? 'Edit Event' : 'Add New Event',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(Icons.event, color: Colors.blue, size: 26),
                  ],
                ),
                const SizedBox(height: 16),

                // Name Field
                _buildInputField(
                    _nameController, 'Event Name *', Icons.event, true),
                const SizedBox(height: 16),

                // Description Field
                _buildInputField(
                    _descriptionController, 'Description', Icons.description,
                    false, maxLines: 3),
                const SizedBox(height: 16),

                // Status Dropdown
                _buildDropdown(
                    'Status', _status, _statusOptions, Icons.flag, (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _status = newValue;
                    });
                  }
                }),
                const SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                        'Proposed Date', Icons.calendar_today),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _proposedDate == null
                              ? 'Select a date'
                              : DateFormat('MMM dd, yyyy').format(
                              _proposedDate!),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sections (Chief Guests, Speakers, Links)
                _buildSectionHeader(
                    'Chief Guests', Icons.star, Colors.amber, () {
                  _editChiefGuest(context);
                }),
                _buildPersonList(_chiefGuests, onEdit: (index) =>
                    _editChiefGuest(context, _chiefGuests[index], index),
                    onDelete: (index) =>
                        setState(() => _chiefGuests.removeAt(index))),
                const SizedBox(height: 16),

                _buildSectionHeader('Speakers', Icons.mic, Colors.green, () {
                  _editSpeaker(context);
                }),
                _buildPersonList(_speakers, onEdit: (index) =>
                    _editSpeaker(context, _speakers[index], index),
                    onDelete: (index) =>
                        setState(() => _speakers.removeAt(index))),
                const SizedBox(height: 16),

                _buildSectionHeader('Links', Icons.link, Colors.blue, () {
                  _editLink(context);
                }),
                _buildLinksList(_links,
                    onEdit: (index) => _editLink(context, _links[index], index),
                    onDelete: (index) =>
                        setState(() => _links.removeAt(index))),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                          'Cancel', style: TextStyle(color: Colors.black54)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _saveEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(_isEditing ? 'Update Event' : 'Add Event'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for text fields with icons
  Widget _buildInputField(TextEditingController controller, String label,
      IconData icon, bool required, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      maxLines: maxLines,
      validator: required
          ? (value) {
        if (value == null || value
            .trim()
            .isEmpty) {
          return 'Please enter $label';
        }
        return null;
      }
          : null,
    );
  }

// Helper method for dropdowns
  Widget _buildDropdown(String label, String value, List<String> options,
      IconData icon, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label, icon),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option.replaceAll('_', ' ')),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Common input decoration
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(String title, IconData icon, Color color,
      VoidCallback onAdd) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }

  // Helper method to build people lists (chief guests or speakers)
  Widget _buildPersonList(List<Map<String, dynamic>> people, {
    required Function(int) onEdit,
    required Function(int) onDelete,
  }) {
    if (people.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No one added yet',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: people.length,
      itemBuilder: (context, index) {
        final person = people[index];
        return Card(
          elevation: 3, // Adds a slight shadow for a premium feel
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Icon(Icons.person, color: Colors.orange.shade700),
            ),
            title: Text(
              person["name"],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '${person["designation"]}, ${person["organization"]}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                      Icons.edit, size: 22, color: Colors.orange.shade700),
                  onPressed: () => onEdit(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 22, color: Colors.red),
                  onPressed: () => onDelete(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Helper method to build links list
  Widget _buildLinksList(List<Map<String, dynamic>> links, {
    required Function(int) onEdit,
    required Function(int) onDelete,
  }) {
    if (links.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No links added yet',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.link, color: Colors.blue.shade700),
            ),
            title: Text(
              link["title"],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              link["url"],
              style: const TextStyle(fontSize: 14, color: Colors.blue),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: 22, color: Colors.blue.shade700),
                  onPressed: () => onEdit(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 22, color: Colors.red),
                  onPressed: () => onDelete(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}