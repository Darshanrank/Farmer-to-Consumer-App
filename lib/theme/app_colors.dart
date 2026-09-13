import 'package:flutter/material.dart';

/// App Color Palette for KisanBazaar
/// Agricultural/Nature-inspired green theme with modern vibrancy
class AppColors {
  // Primary Colors - Quick Commerce Green
  static const Color primary = Color(0xFF0C831F); // Crisp Blinkit-style Green
  static const Color primaryLight = Color(0xFF16A34A); // Lighter vibrant green
  static const Color primaryDark = Color(0xFF065F15); // Deep Green
  
  // Secondary Colors - Earthy & Natural tones
  static const Color secondary = Color(0xFF795548); // Natural Brown
  static const Color secondaryLight = Color(0xFFA1887F);
  static const Color secondaryDark = Color(0xFF4E342E);
  
  // Accent Colors - Offers & Highlights
  static const Color accent = Color(0xFFFBC02D); // Sunny Yellow
  static const Color accentLight = Color(0xFFFFF176);
  static const Color accentDark = Color(0xFFF57F17);
  
  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF); // Pure clean white
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFF4F6F9); // Very subtle light gray/blue surface
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1B1B1B); // Rich Black
  static const Color textSecondary = Color(0xFF757575); // Medium Gray
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Status Colors
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFB8C00);
  static const Color info = Color(0xFF1E88E5);
  
  // Functional Colors
  static const Color divider = Color(0xFFE0E0E0); // Lighter distinct divider
  static const Color shadow = Color(0x08000000); // Extremely subtle shadow
  static const Color overlay = Color(0x4D000000);
  
  // Modern Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Decorative Colors
  static const Color lightGreenBg = Color(0xFFE8F5E9);
  static const Color lightAmberBg = Color(0xFFFFF8E1);
  static const Color lightBrownBg = Color(0xFFEFEBE9);
}
