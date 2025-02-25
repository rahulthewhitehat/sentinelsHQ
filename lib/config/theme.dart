import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF1E88E5); // Blue
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black;
  static const Color secondaryColor = Color(0xFF64B5F6); // Lighter Blue
  static const Color accentColor = Color(0xFF0D47A1); // Darker Blue

  // Font Family
  static const String fontFamily = 'Montserrat';

  // Theme Data
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: fontFamily,
    appBarTheme: AppBarTheme(
      color: primaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: TextStyle(color: Colors.grey[700]),
    ),
    cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textColor,
        fontSize: 14,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
  );
}