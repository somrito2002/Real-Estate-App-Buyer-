import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color accentBlue = Color(0xFF4B85F0);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: accentBlue,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: accentBlue,
        secondary: accentBlue.withValues(alpha: 0.8),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF111111),
        outline: Colors.grey.shade300,
        surfaceContainerHighest: Colors.grey.shade200,
        onSurfaceVariant: Colors.grey.shade600,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: const Color(0xFF111111),
        displayColor: const Color(0xFF111111),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: accentBlue,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.dark(
        primary: accentBlue,
        secondary: accentBlue.withValues(alpha: 0.8),
        surface: const Color(0xFF1E1E1E),
        onPrimary: Colors.white,
        onSurface: Colors.white,
        outline: Colors.grey.shade800,
        surfaceContainerHighest: const Color(0xFF2C2C2C),
        onSurfaceVariant: Colors.grey.shade400,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      useMaterial3: true,
    );
  }
}