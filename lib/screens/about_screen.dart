import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  final String appDescription =
      'SentinelsHQ App\n\nVersion 1.0.0\n\nSentinelsHQ is the official management app for the Cyber Sentinels Club, designed to streamline club operations. '
      'Built with Flutter, it enables efficient task management, issue tracking, event coordination, and team collaboration in one platform. '
      'This app empowers club members to communicate, contribute, and track their activities seamlessly.';

  final String developerDescription =
      'I am a student with a deep passion for technology and aspirations to become an ethical hacker. '
      'I have continuously challenged myself in cybersecurity, networking, and programming, reflecting my dedication in multiple achievements and certifications. '
      ;

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
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // About App
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About SentinelsHQ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                appDescription,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              ),
            ),
            const SizedBox(height: 30),

            // About Developer Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About the Developer',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Developer Profile Photo
            const CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/images/dev.jpg'), // Adjust path
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 15),

            // Developer Name
            Text(
              'Rahul Babu M P',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // About Developer
            Text(
              developerDescription,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Contact Information
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Contact Details with Icons
            Row(
              children: [
                const Icon(Icons.email, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  'rahulbabuoffl@gmail.com',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  '+91 9514803391',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.web, color: Colors.blue),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _launchURL('https://rahulbabump.online'),
                  child: const Text(
                    'Visit Portfolio',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.web, color: Colors.blue),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _launchURL('https://linktr.ee/rahulthewhitehat'),
                  child: const Text(
                    'linktr.ee/rahulthewhitehat',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}