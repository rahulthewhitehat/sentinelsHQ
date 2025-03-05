import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelshq/screens/auth/login_screen.dart';
import 'package:sentinelshq/screens/dashboard/admin_dashboard.dart';
import 'package:sentinelshq/screens/dashboard/member_dashboard.dart';
import 'package:sentinelshq/screens/dashboard/superAdmin_dashboard.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
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

    if (authProvider.isAdmin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AdminDashboard()),
      );
    } else if (authProvider.isSuperAdmin){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SuperAdminDashboard()),
      );
    }
    else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MemberDashboard(userId: authProvider.user!.uid),
        ),
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