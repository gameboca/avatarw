import 'package:flutter/material.dart';

class AppColors {
  // Primary Dark Palette
  static const Color background = Color(0xFF0F1017);
  static const Color surface = Color(0xFF161824);
  static const Color surfaceElevated = Color(0xFF1E2132);
  static const Color surfaceBorder = Color(0xFF2C3048);

  // Cyber Accents
  static const Color primary = Color(0xFF9D5CE6);
  static const Color primaryLight = Color(0xFFBE82FF);
  static const Color primaryDark = Color(0xFF6B2FB8);

  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color neonPink = Color(0xFFFF2A85);
  static const Color neonAmber = Color(0xFFFFB300);
  static const Color neonGreen = Color(0xFF00E676);

  // Text
  static const Color textPrimary = Color(0xFFF1F3F9);
  static const Color textSecondary = Color(0xFF9399B2);
  static const Color textMuted = Color(0xFF5F6580);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFB163FF), Color(0xFF702AEB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1B1E2E), Color(0xFF141622)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glowingBorderGradient = LinearGradient(
    colors: [Color(0xFF9D5CE6), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
