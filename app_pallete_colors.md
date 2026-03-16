import 'package:flutter/material.dart';

/// Central palette for the Travel App.
/// Used by both:
/// - Client mobile app
/// - Travel agent management panel
///
/// Design goals:
/// - Premium
/// - Minimalist
/// - Neutral base with elegant accents
/// - Avoid overly saturated colors
class TravelAppColors {
  TravelAppColors._();

  /// ===============================
  /// Primary Brand Colors
  /// ===============================

  /// Main brand color - deep travel blue
  static const Color primary = Color(0xFF0F2A44);

  /// Slightly lighter blue for hover / secondary actions
  static const Color primaryLight = Color(0xFF1E3F60);

  /// Darker blue for emphasis
  static const Color primaryDark = Color(0xFF081C2C);

  /// ===============================
  /// Premium Accent Colors
  /// ===============================

  /// Dark gold accent (premium highlights)
  static const Color accentGold = Color(0xFFB8965A);

  /// Subtle gold for hover / UI details
  static const Color accentGoldLight = Color(0xFFD3B27A);

  /// Deeper gold for strong highlights
  static const Color accentGoldDark = Color(0xFF8C6F3E);

  /// ===============================
  /// Background Colors
  /// ===============================

  /// Main background (app screens)
  static const Color background = Color(0xFFF5F6F8);

  /// Card / container surfaces
  static const Color surface = Color(0xFFFFFFFF);

  /// Dark surface (headers / navbars)
  static const Color surfaceDark = Color(0xFF101820);

  /// ===============================
  /// Neutral UI Colors
  /// ===============================

  static const Color border = Color(0xFFE0E3E7);

  static const Color divider = Color(0xFFE8EAED);

  static const Color disabled = Color(0xFFB0B6BD);

  /// ===============================
  /// Text Colors
  /// ===============================

  /// Main text
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Secondary text
  static const Color textSecondary = Color(0xFF6B7280);

  /// Text on dark backgrounds
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Text used on primary buttons
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// ===============================
  /// Semantic Colors
  /// ===============================

  static const Color success = Color(0xFF2E7D5B);

  static const Color warning = Color(0xFFC08A2E);

  static const Color error = Color(0xFFB23A3A);

  static const Color info = Color(0xFF3A6EA5);
}