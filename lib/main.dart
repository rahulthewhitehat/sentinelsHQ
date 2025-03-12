import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sentinelshq/providers/event_provider.dart';
import 'package:sentinelshq/providers/resource_provider.dart';
import 'package:sentinelshq/providers/task_provider.dart';
import 'package:sentinelshq/providers/user_provider.dart';
import 'package:sentinelshq/screens/MemberView/task_management2.dart';
import 'package:sentinelshq/screens/auth/login_screen.dart';
import 'package:sentinelshq/screens/AdminView/event_management.dart';
import 'package:sentinelshq/screens/AdminView/issue_management.dart';
import 'package:sentinelshq/screens/AdminView/resource_management.dart';
import 'package:sentinelshq/screens/AdminView/task_management.dart';
import 'package:sentinelshq/screens/AdminView/verification_screen.dart';
import 'package:sentinelshq/splash_screen.dart';
import '/config/theme.dart';
import '/providers/auth_provider.dart';
import '/services/auth_service.dart';
import '/screens/settings_screen.dart';
import 'screens/AdminView/user_management.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  //copyDocument();
  runApp(MyApp());
}

  Future<void> copyDocument() async {
    String sourcePath = '/roles/Leads/members/IT2y2jlhKNPZvpu9egtgb4hFbxh1';
    String destinationPath = '/roles/root@localhost/members/IT2y2jlhKNPZvpu9egtgb4hFbxh1';

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Get the document from source
      DocumentSnapshot docSnapshot = await firestore.doc(sourcePath).get();

      if (docSnapshot.exists) {
        // Copy data to the new location
        await firestore.doc(destinationPath).set(docSnapshot.data() as Map<String, dynamic>);

        print("Document copied successfully!");
      } else {
        print("Source document does not exist.");
      }
    } catch (e) {
      print("Error copying document: $e");
    }
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
          '/login': (context) => LoginScreen(),
         // '/task_management2': (context) => TaskScreen2(),
        },
      ),
    );
  }
}