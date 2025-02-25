import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sentinelshq/splash_screen.dart';
import '/config/theme.dart';
import '/providers/auth_provider.dart';
import '/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
      ],
      child: MaterialApp(
        title: 'SentinelsHQ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: SplashScreen(),
      ),
    );
  }
}