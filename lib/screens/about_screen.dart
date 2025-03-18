import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  final String appDescription =
      'Version 1.0.0 (Beta)\n\nSentinelsHQ is the official management app for the Cyber Sentinels Club, designed to streamline club operations. '
      'Built with Flutter, it enables efficient task management, issue tracking, event coordination, and team collaboration in one platform. '
      'This app empowers club members to communicate, contribute, and track their activities seamlessly.';

  final String developerDescription =
      'I am a student with a deep passion for technology and aspirations to become an ethical hacker. '
      'I have continuously challenged myself in cybersecurity, networking, and programming, reflecting my dedication in multiple achievements and certifications.';

  const AboutScreen({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('About', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade800,
                  Colors.blue.shade600,
                  Colors.blue.shade400,
                  Colors.blue.shade200,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // App section with card
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shield, color: Colors.blue, size: 32),
                                const SizedBox(width: 12),
                                Text(
                                  'About SentinelsHQ',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              appDescription,
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Developer section with card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              'About Developer',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Developer avatar with border
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 75,
                                  backgroundImage: const AssetImage('assets/images/dev.jpg'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Developer name
                            Text(
                              'Rahul Babu M P',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Developer role/title
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Cybersecurity Enthusiast',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Developer description
                            Text(
                              developerDescription,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Contact section with card
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Contact items
                            _buildContactItem(
                              icon: Icons.email_outlined,
                              text: 'rahulbabuoffl@gmail.com',
                              onTap: () => _launchURL('mailto:rahulbabuoffl@gmail.com'),
                            ),
                            _buildContactItem(
                              icon: Icons.phone_outlined,
                              text: '+91 9514803391',
                              onTap: () => _launchURL('tel:+919514803391'),
                            ),
                            _buildContactItem(
                              icon: Icons.language_outlined,
                              text: 'Visit Portfolio',
                              onTap: () => _launchURL('https://rahulbabump.online'),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),

                  // Footer space
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isLast = false
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(color: Colors.grey.shade200),
      ],
    );
  }
}