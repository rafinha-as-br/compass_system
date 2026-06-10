import 'package:flutter/material.dart';

class TravelAppColors {
  TravelAppColors._();

  static const Color primary = Color(0xFF0F2A44);
  static const Color primaryLight = Color(0xFF1E3F60);
  static const Color primaryDark = Color(0xFF081C2C);
  
  static const Color accentGold = Color(0xFFB8965A);
  static const Color accentGoldLight = Color(0xFFD3B27A);
  static const Color accentGoldDark = Color(0xFF8C6F3E);

  static const Color background = Color(0xFFF5F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF101820);

  static const Color border = Color(0xFFE0E3E7);
  static const Color divider = Color(0xFFE8EAED);
  static const Color disabled = Color(0xFFB0B6BD);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF2E7D5B);
  static const Color warning = Color(0xFFC08A2E);
  static const Color error = Color(0xFFB23A3A);
  static const Color info = Color(0xFF3A6EA5);
}

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color success;
  final Color warning;
  final Color info;

  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.info,
  });

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppSemanticColors lerp(
    ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

extension AppSemanticColorsLookup on ThemeData {
  AppSemanticColors get semanticColors =>
      extension<AppSemanticColors>() ??
      const AppSemanticColors(
        success: TravelAppColors.success,
        warning: TravelAppColors.warning,
        info: TravelAppColors.info,
      );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: TravelAppColors.primary,
      scaffoldBackgroundColor: TravelAppColors.background,
      colorScheme: const ColorScheme.light(
        primary: TravelAppColors.primary,
        secondary: TravelAppColors.accentGold,
        surface: TravelAppColors.surface,
        error: TravelAppColors.error,
        onPrimary: TravelAppColors.textOnPrimary,
        onSecondary: TravelAppColors.textOnDark,
        onSurface: TravelAppColors.textPrimary,
        onError: TravelAppColors.textOnPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TravelAppColors.primary,
        foregroundColor: TravelAppColors.textOnPrimary,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: TravelAppColors.primary,
        unselectedLabelColor: TravelAppColors.textSecondary,
        labelStyle: TextStyle(color: TravelAppColors.textOnPrimary)
      ),
      extensions: const [
        AppSemanticColors(
          success: TravelAppColors.success,
          warning: TravelAppColors.warning,
          info: TravelAppColors.info,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: TravelAppColors.primaryDark,
      scaffoldBackgroundColor: TravelAppColors.surfaceDark,
      colorScheme: const ColorScheme.dark(
        primary: TravelAppColors.primaryLight,
        secondary: TravelAppColors.accentGoldLight,
        surface: TravelAppColors.surfaceDark,
        error: TravelAppColors.error,
        onPrimary: TravelAppColors.textOnPrimary,
        onSecondary: TravelAppColors.textOnDark,
        onSurface: TravelAppColors.textOnDark,
        onError: TravelAppColors.textOnPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TravelAppColors.surfaceDark,
        foregroundColor: TravelAppColors.textOnDark,
        elevation: 0,
      ),
      extensions: const [
        AppSemanticColors(
          success: Color(0xFF65C18C),
          warning: Color(0xFFE4B363),
          info: Color(0xFF7BB2D9),
        ),
      ],
    );
  }
}
