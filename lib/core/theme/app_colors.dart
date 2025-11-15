import 'package:flutter/material.dart';

/// App color palette - MilkBill Fresh Mint Theme
class AppColors {
  AppColors._();

  // Primary Colors - Fresh Mint Green
  static const Color primary = Color(0xFF2BC5B4); // Fresh mint green, energetic
  static const Color primaryDark = Color(0xFF17A090); // Buttons / highlights
  static const Color primaryLight = Color(0xFF5FD9CA); // Lighter mint

  // Secondary Colors - Supporting greens
  static const Color secondary = Color(0xFF17A090); // Same as primaryDark for consistency
  static const Color secondaryDark = Color(0xFF0D8070);
  static const Color secondaryLight = Color(0xFF3BB8A6);

  // Accent Colors - Warm Yellow for CTAs
  static const Color accent = Color(0xFFFFD369); // Warm contrasting highlight
  static const Color accentDark = Color(0xFFE6B849);
  static const Color accentLight = Color(0xFFFFDD8C);

  // Semantic Colors
  static const Color success = Color(0xFF17A090); // Use primaryDark
  static const Color error = Color(0xFFE74C3C); // Soft red
  static const Color warning = Color(0xFFFFD369); // Use accent
  static const Color info = Color(0xFF2BC5B4); // Use primary

  // Neutral Colors - Light Theme
  static const Color backgroundLight = Color(0xFFF6FFFD); // Soft mint-white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF142D27); // Deep greenish charcoal
  static const Color textSecondaryLight = Color(0xFF5A7A72);
  static const Color dividerLight = Color(0xFFE3F3F1); // Soft borders / containers

  // Neutral Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF0F1514); // Deep greenish dark
  static const Color surfaceDark = Color(0xFF1A2320); // Greenish dark surface
  static const Color textPrimaryDark = Color(0xFFE3F3F1);
  static const Color textSecondaryDark = Color(0xFF9DB8B3);
  static const Color dividerDark = Color(0xFF2A3936);

  // Functional Colors
  static const Color delivered = Color(0xFF17A090); // Success green
  static const Color notDelivered = Color(0xFFE74C3C); // Error red
  static const Color pending = Color(0xFFFFD369); // Accent yellow
  static const Color paid = Color(0xFF17A090); // Success green
  static const Color unpaid = Color(0xFFE74C3C); // Error red
  static const Color partiallyPaid = Color(0xFFFFD369); // Accent yellow

  // Status Colors
  static const Color activeStatus = Color(0xFF17A090);
  static const Color inactiveStatus = Color(0xFF9E9E9E);
  static const Color holidayStatus = Color(0xFFFFD369);

  // Grey/Border colors
  static const Color grey = Color(0xFFE3F3F1); // Soft grey for containers
  static const Color greyDark = Color(0xFF2A3936);

  // Convenience aliases for common usage
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textDisabled = Color(0xFF9DB8B3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color divider = dividerLight;
  static const Color border = dividerLight;
  static const Color borderDark = Color(0xFF5A7A72);

  // Gradient colors for premium feel
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
