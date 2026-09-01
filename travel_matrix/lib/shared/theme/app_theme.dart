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
  static TextTheme _interTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.inter(textStyle: base.displayLarge, fontWeight: FontWeight.w600),
      displayMedium: GoogleFonts.inter(textStyle: base.displayMedium, fontWeight: FontWeight.w600),
      displaySmall: GoogleFonts.inter(textStyle: base.displaySmall, fontWeight: FontWeight.w600),
      headlineLarge: GoogleFonts.inter(textStyle: base.headlineLarge, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.inter(textStyle: base.headlineMedium, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.inter(textStyle: base.headlineSmall, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.inter(textStyle: base.titleLarge, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(textStyle: base.titleMedium, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.inter(textStyle: base.titleSmall, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(textStyle: base.bodyLarge, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.inter(textStyle: base.bodyMedium, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.inter(textStyle: base.bodySmall, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.inter(textStyle: base.labelLarge, fontWeight: FontWeight.w500),
      labelMedium: GoogleFonts.inter(textStyle: base.labelMedium, fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.inter(textStyle: base.labelSmall, fontWeight: FontWeight.w500),
    );
  }

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: TravelAppColors.primary,
      secondary: TravelAppColors.accentGold,
      surface: TravelAppColors.surface,
      error: TravelAppColors.error,
      onPrimary: TravelAppColors.textOnPrimary,
      // accentGold é um tom claro — texto escuro garante contraste AA (branco falha, ~2.2:1).
      onSecondary: TravelAppColors.textPrimary,
      onSurface: TravelAppColors.textPrimary,
      onError: TravelAppColors.textOnPrimary,
      // outline/outlineVariant não têm default de marca — sem isso caem no
      // fallback do ColorScheme.light() (preto puro), quebrando qualquer borda.
      outline: TravelAppColors.border,
      outlineVariant: TravelAppColors.divider,
    );

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: TravelAppColors.primary,
      scaffoldBackgroundColor: TravelAppColors.background,
      textTheme: _interTextTheme(ThemeData.light().textTheme),
      colorScheme: colorScheme,
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
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      cardTheme: _cardTheme(colorScheme),
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
    const colorScheme = ColorScheme.dark(
      primary: TravelAppColors.primaryLight,
      secondary: TravelAppColors.accentGoldLight,
      surface: TravelAppColors.surfaceDark,
      error: TravelAppColors.error,
      onPrimary: TravelAppColors.textOnPrimary,
      // accentGoldLight também é claro — mesma correção de contraste do tema light.
      onSecondary: TravelAppColors.textPrimary,
      onSurface: TravelAppColors.textOnDark,
      onError: TravelAppColors.textOnPrimary,
      // Sem default de marca para tons neutros escuros — mesma correção do tema light.
      outline: TravelAppColors.disabled,
      // 25% de branco sobre surfaceDark — mesma proporção das variantes semânticas
      // abaixo (não 12%: contraste ficava abaixo de 3:1 contra surfaceDark, borda
      // de card/input quase invisível).
      outlineVariant: Color(0xFF4C5258),
    );

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: TravelAppColors.primaryDark,
      scaffoldBackgroundColor: TravelAppColors.surfaceDark,
      textTheme: _interTextTheme(ThemeData.dark().textTheme),
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: TravelAppColors.surfaceDark,
        foregroundColor: TravelAppColors.textOnDark,
        elevation: 0,
      ),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      cardTheme: _cardTheme(colorScheme),
      extensions: const [
        AppSemanticColors(
          // Variantes com 25% de branco misturado — mesma proporção usada para
          // derivar primaryLight/accentGoldLight a partir dos tokens base.
          success: Color(0xFF62CC81),
          warning: Color(0xFFD0A762),
          info: Color(0xFF6B92BC),
        ),
      ],
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
    );
  }

  static CardThemeData _cardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    );
  }
}
