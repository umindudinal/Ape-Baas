import 'package:flutter/material.dart';

class AppColors {
  // Deep Navy Blue Core Palette (#002B49) - Main Logo Brand Theme
  static const Color deepNavy = Color(0xFF002B49);
  static const Color primary = Color(0xFF002B49);

  // Tonal Navy Blue Variations
  static const Color navyDark = Color(0xFF00192C);    // Deepest Midnight Navy
  static const Color navyMedium = Color(0xFF002B49);  // Primary Deep Navy Blue (#002B49)
  static const Color navyLight = Color(0xFF004370);   // Rich Lighter Navy
  static const Color navyAccent = Color(0xFF005E99);  // Accent Soft Navy
  static const Color navySubtle = Color(0xFFE3EFF7);  // Light Navy Container Fill
  static const Color navyBg = Color(0xFFEEF5FA);      // Soft Navy Tint Surface

  // Functional Status Colors
  static const Color successGreen = Color(0xFF059669); // Emerald Green for Verified & Accepted
  static const Color warningAmber = Color(0xFFD97706); // Warm Amber Gold for Pending & Ratings
  static const Color errorRed = Color(0xFFE11D48);    // Rose Crimson for Rejected & Suspended

  // Mapped Legacy Accent Tokens for Unified Navy Theme (#002B49)
  static const Color orangePrimary = Color(0xFF002B49);
  static const Color orangeDark = Color(0xFF00192C);
  static const Color orangeLight = Color(0xFF004370);
  static const Color orangeBg = Color(0xFFEEF5FA);

  // General Surface & Text Colors
  static const Color surfaceBg = Color(0xFFF4F7FA);
  static const Color textDark = Color(0xFF00192C);
  static const Color textMedium = Color(0xFF002B49);
  static const Color textMuted = Color(0xFF4C6578);
  static const Color cardBorder = Color(0xFFCFE0EB);
  static const Color white = Colors.white;

  // Status & Tag Badges (Navy Theme Aligned)
  static const Color statusActive = Color(0xFF059669);
  static const Color statusPending = Color(0xFFD97706);
  static const Color statusCompleted = Color(0xFF004370);
  static const Color statusCancelled = Color(0xFF64748B);

  // Deep Navy Blue Brand Gradients
  static const LinearGradient navyGradient = LinearGradient(
    colors: [Color(0xFF00192C), Color(0xFF002B49)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF002B49), Color(0xFF004370)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFF002B49), Color(0xFF004370)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandCombinedGradient = LinearGradient(
    colors: [Color(0xFF00192C), Color(0xFF002B49), Color(0xFF004370)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyLightGradient = LinearGradient(
    colors: [Color(0xFFF4F7FA), Color(0xFFE3EFF7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
