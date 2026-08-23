import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TravelAppColors {
  TravelAppColors._();

  static const Color primary = Color(0xFF4B0082);
  static const Color primaryLight = Color(0xFF7840A1);
  static const Color primaryDark = Color(0xFF380062);

  static const Color accentGold = Color(0xFFDAA520);
  static const Color accentGoldLight = Color(0xFFE3BC58);
  static const Color accentGoldDark = Color(0xFFA47C18);

  static const Color tertiary = Color(0xFF2EBB57);

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF101820);

  static const Color border = Color(0xFFE0E3E7);
  static const Color divider = Color(0xFFE8EAED);
  static const Color disabled = Color(0xFFB0B6BD);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF708090);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF2EBB57);
  static const Color warning = Color(0xFFC08A2E);
  static const Color error = Color(0xFFB23A3A);
  static const Color info = Color(0xFF3A6EA5);
}

class AppTheme {
  static TextTheme _poppinsTextTheme(TextTheme base) {
    return GoogleFonts.poppinsTextTheme(base).copyWith(
      displayLarge: GoogleFonts.poppins(
        textStyle: base.displayLarge,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: GoogleFonts.poppins(
        textStyle: base.displayMedium,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: GoogleFonts.poppins(
        textStyle: base.displaySmall,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.poppins(
        textStyle: base.headlineLarge,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.poppins(
        textStyle: base.headlineSmall,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.poppins(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.poppins(
        textStyle: base.titleMedium,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.poppins(
        textStyle: base.titleSmall,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.poppins(
        textStyle: base.bodyLarge,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.poppins(
        textStyle: base.bodyMedium,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.poppins(
        textStyle: base.bodySmall,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.poppins(
        textStyle: base.labelLarge,
        fontWeight: FontWeight.w400,
      ),
      labelMedium: GoogleFonts.poppins(
        textStyle: base.labelMedium,
        fontWeight: FontWeight.w400,
      ),
      labelSmall: GoogleFonts.poppins(
        textStyle: base.labelSmall,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: TravelAppColors.primary,
      scaffoldBackgroundColor: TravelAppColors.background,
      textTheme: _poppinsTextTheme(ThemeData.light().textTheme),
      colorScheme: const ColorScheme.light(
        primary: TravelAppColors.primary,
        secondary: TravelAppColors.accentGold,
        surface: TravelAppColors.surface,
        error: TravelAppColors.error,
        onPrimary: TravelAppColors.textOnPrimary,
        // accentGold é um tom claro — texto escuro garante contraste AA (branco falha, ~2.2:1).
        onSecondary: TravelAppColors.textPrimary,
        onSurface: TravelAppColors.textPrimary,
        onError: TravelAppColors.textOnPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TravelAppColors.primary,
        foregroundColor: TravelAppColors.textOnPrimary,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: TravelAppColors.primaryDark,
      scaffoldBackgroundColor: TravelAppColors.surfaceDark,
      textTheme: _poppinsTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: TravelAppColors.primaryLight,
        secondary: TravelAppColors.accentGoldLight,
        surface: TravelAppColors.surfaceDark,
        error: TravelAppColors.error,
        onPrimary: TravelAppColors.textOnPrimary,
        // accentGoldLight também é claro — mesma correção de contraste do tema light.
        onSecondary: TravelAppColors.textPrimary,
        onSurface: TravelAppColors.textOnDark,
        onError: TravelAppColors.textOnPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TravelAppColors.surfaceDark,
        foregroundColor: TravelAppColors.textOnDark,
        elevation: 0,
      ),
    );
  }
}
