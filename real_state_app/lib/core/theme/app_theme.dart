// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppTheme {
  static const Color customSuccess = Color(0xFF4CAF50);
  static const Color customWarning = Color(0xFFFFC107);
  static const Color customAccent = Color(0xFF00BFAE);

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: customAccent,
      background: Colors.white,
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade200,
    ),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme.dark(
      primary: Colors.indigoAccent,
      secondary: customAccent,
      background: Color(0xFF181A20),
      surface: Color(0xFF23262B),
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
      onError: Colors.black,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade800,
    ),
    scaffoldBackgroundColor: const Color(0xFF181A20),
    cardColor: const Color(0xFF23262B),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF181A20),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
