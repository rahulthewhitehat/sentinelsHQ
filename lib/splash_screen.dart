import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelshq/screens/auth/login_screen.dart';
import 'package:sentinelshq/screens/dashboard/admin_dashboard.dart';
import 'package:sentinelshq/screens/dashboard/member_dashboard.dart';
import 'package:sentinelshq/screens/dashboard/superAdmin_dashboard.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check authentication status after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Short delay to show splash screen
    await Future.delayed(Duration(seconds: 2));

    if (authProvider.isAuthenticated) {
      _navigateToDashboard(context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  void _navigateToDashboard(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isVerified) {
      switch (authProvider.userRole) {
        case 'Founders':
        case 'Leads':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => AdminDashboard()),
          );
          break;
        case 'superAdmin':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => SuperAdminDashboard()),
          );
          break;
        default:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MemberDashboard(role: authProvider.userRole),
            ),
          );
      }
    }
    else {
      // Show a dialog to inform the user that admin verification is in process
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Irungaa Bhaii!'),
            content: Text('Super Admin verification is in process. Kindly Wait!'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: AssetImage('assets/images/logo.png'),
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 24),
            Text(
              'SentinelsHQ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 48),
            LoadingIndicator(),
          ],
        ),
      ),
    );
  }
}