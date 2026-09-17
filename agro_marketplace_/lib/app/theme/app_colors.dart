import 'package:flutter/material.dart';

/// Application color palette.
///
/// Agriculture-themed with earthy greens and warm accents.
/// Designed for both light and dark themes.
class AppColors {
  const AppColors._();

  // === Primary (Rich Green — agriculture identity) ===
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryContainer = Color(0xFFC8E6C9);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF0D3311);

  // === Secondary (Warm Amber — harvest accent) ===
  static const Color secondary = Color(0xFFF57F17);
  static const Color secondaryLight = Color(0xFFFFB300);
  static const Color secondaryDark = Color(0xFFE65100);
  static const Color secondaryContainer = Color(0xFFFFF3E0);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF4E2600);

  // === Tertiary (Earthy Brown — soil/nature) ===
  static const Color tertiary = Color(0xFF795548);
  static const Color tertiaryContainer = Color(0xFFD7CCC8);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // === Background / Surface ===
  static const Color background = Color(0xFFF5F7F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4E8);
  static const Color surfaceTint = Color(0xFFE8F5E9);

  // === Text ===
  static const Color textPrimary = Color(0xFF1A1C18);
  static const Color textSecondary = Color(0xFF44483E);
  static const Color textTertiary = Color(0xFF74796D);
  static const Color textOnDark = Color(0xFFF5F5F5);

  // === Status ===
  static const Color success = Color(0xFF388E3C);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF9A825);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFFE3F2FD);

  // === Divider / Border ===
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  static const Color borderLight = Color(0xFFE8E8E8);

  // === Dark Theme ===
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkPrimary = Color(0xFF66BB6A);
  static const Color darkSecondary = Color(0xFFFFCA28);

  // === Seller Status Colors ===
  static const Color statusActive = Color(0xFF388E3C);
  static const Color statusPending = Color(0xFFF9A825);
  static const Color statusRejected = Color(0xFFD32F2F);
  static const Color statusSuspended = Color(0xFFE64A19);
  static const Color statusDraft = Color(0xFF9E9E9E);

  // === Order Status Colors ===
  static const Color orderPlaced = Color(0xFF1976D2);
  static const Color orderProcessing = Color(0xFFF9A825);
  static const Color orderDelivered = Color(0xFF388E3C);
  static const Color orderCancelled = Color(0xFFD32F2F);
}
