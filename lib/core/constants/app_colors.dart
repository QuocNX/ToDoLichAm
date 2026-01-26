import 'package:flutter/material.dart';

/// App-wide color constants.
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryLight = Color(0xFF5AC8FA);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color darkSurface = Color(0xFF2C2C2E);
  static const Color darkSurfaceVariant = Color(0xFF3A3A3C);
  static const Color darkDivider = Color(0xFF48484A);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFE5E5EA);
  static const Color lightDivider = Color(0xFFC6C6C8);

  // Text colors
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF8E8E93);
  static const Color textPrimaryLight = Color(0xFF1C1C1E);
  static const Color textSecondaryLight = Color(0xFF8E8E93);

  // Accent colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color star = Color(0xFFFFCC00);
}
