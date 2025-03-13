import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    primaryColor: const Color(0xFFFFC107),
    scaffoldBackgroundColor: const Color(0xFF1A1A1D),
    cardColor: const Color(0xFFDDE6EE),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: const Color(0xFF1A1A1D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF212121),
      ),
      titleMedium: TextStyle(color: Color(0xFF757575)),
      bodyMedium: TextStyle(color: Color(0xFF212121)),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFFFC107)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1D),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
