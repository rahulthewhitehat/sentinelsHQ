import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sentinelshq/providers/event_provider.dart';
import 'package:sentinelshq/providers/resource_provider.dart';
import 'package:sentinelshq/providers/task_provider.dart';
import 'package:sentinelshq/providers/user_provider.dart';
import 'package:sentinelshq/screens/superAdminView/event_management.dart';
import 'package:sentinelshq/screens/superAdminView/issue_management.dart';
import 'package:sentinelshq/screens/superAdminView/resource_management.dart';
import 'package:sentinelshq/screens/superAdminView/task_management.dart';
import 'package:sentinelshq/screens/superAdminView/verification_screen.dart';
import 'package:sentinelshq/splash_screen.dart';
import '/config/theme.dart';
import '/providers/auth_provider.dart';
import '/services/auth_service.dart';
import '/screens/settings_screen.dart';
import 'screens/superAdminView/user_management.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ResourceProvider()),
        ChangeNotifierProvider(create: (context) => EventProvider()),
      ],
      child: MaterialApp(
        title: 'SentinelsHQ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/settings': (context) => SettingsScreen(),
          '/user_management': (context) => UserManagementScreen(),
          '/task_management': (context) => TaskScreen(),
          '/resource_management': (context) => ResourceScreen(),
          '/events_calendar': (context) => EventCalendarScreen(),
          '/issue_screen': (context) => ViewIssuesScreen(),
          '/verify': (context) => VerificationScreen(),
        },
      ),
    );
  }
}