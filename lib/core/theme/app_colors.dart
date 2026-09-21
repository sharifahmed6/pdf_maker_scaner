import 'package:flutter/material.dart';

class AppColors {
  // Primary Accent (Professional Blue/Indigo)
  static const Color primary = Color(0xFF2563EB); // Tailwind Blue 600
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFDBEAFE); // Tailwind Blue 100
  static const Color onPrimaryContainer = Color(0xFF1E3A8A); // Tailwind Blue 900

  // Secondary
  static const Color secondary = Color(0xFF475569); // Tailwind Slate 600
  static const Color onSecondary = Colors.white;

  // Neutrals - Light Mode
  static const Color backgroundLight = Color(0xFFF8FAFC); // Tailwind Slate 50
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A); // Tailwind Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Tailwind Slate 500
  static const Color borderLight = Color(0xFFE2E8F0); // Tailwind Slate 200

  // Neutrals - Dark Mode
  static const Color backgroundDark = Color(0xFF0F172A); // Tailwind Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Tailwind Slate 800
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Tailwind Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Tailwind Slate 400
  static const Color borderDark = Color(0xFF334155); // Tailwind Slate 700

  // Semantic
  static const Color error = Color(0xFFDC2626); // Tailwind Red 600
  static const Color success = Color(0xFF16A34A); // Tailwind Green 600
  static const Color warning = Color(0xFFD97706); // Tailwind Amber 600
  static const Color premium = Color(0xFFF59E0B); // Tailwind Amber 500
}
