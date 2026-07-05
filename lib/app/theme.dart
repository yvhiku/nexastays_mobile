// =============================================================================
// NexaStays App Theme
// =============================================================================
// ThemeData aligned with nexastays_web: Playfair Display + DM Sans,
// nexa pink primary, warm accent, ink neutrals.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/tokens/colors.dart';
import '../design_system/tokens/typography.dart';

class AppTheme {
  AppTheme._();

  static const LinearGradient primaryGradient = DSColors.primaryGradient;

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: DSColors.primary,
      onPrimary: Colors.white,
      secondary: DSColors.accent,
      onSecondary: DSColors.ink,
      error: const Color(0xFFB00020),
      onError: Colors.white,
      surface: DSColors.surface,
      onSurface: DSColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DSColors.background,
      fontFamily: DSTypography.bodyFontFamily,
      textTheme: DSTypography.toTextTheme(),

      appBarTheme: AppBarTheme(
        backgroundColor: DSColors.surface,
        foregroundColor: DSColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: DSColors.ink,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _elevatedButtonStyle(
          background: DSColors.primary,
          shadow: DSColors.primary.withValues(alpha: 0.35),
        ),
      ),

      textButtonTheme: TextButtonThemeData(style: _textButtonStyle()),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _outlinedButtonStyle(foreground: DSColors.ink),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DSColors.background2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DSColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DSColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DSColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: DSColors.ink4,
        ),
        labelStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: DSColors.ink2,
        ),
      ),

      cardTheme: CardThemeData(
        color: DSColors.surface,
        elevation: 0,
        shadowColor: const Color.fromRGBO(26, 17, 24, 0.07),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: DSColors.line),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      dividerColor: DSColors.line,

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DSColors.surface,
        selectedItemColor: DSColors.primary,
        unselectedItemColor: DSColors.ink4,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkInk = Color(0xFFF5EDF0);
    const darkSurface = Color(0xFF2A1D24);
    const darkBackground = Color(0xFF1A1017);

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: DSColors.primary,
      onPrimary: Colors.white,
      secondary: DSColors.accent,
      onSecondary: darkInk,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
      surface: darkSurface,
      onSurface: darkInk,
    );

    final darkTextTheme = DSTypography.toTextTheme().apply(
      bodyColor: darkInk,
      displayColor: darkInk,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: DSTypography.bodyFontFamily,
      textTheme: darkTextTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkInk,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkInk,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _elevatedButtonStyle(
          background: DSColors.primary,
          shadow: DSColors.primary.withValues(alpha: 0.4),
        ),
      ),

      textButtonTheme: TextButtonThemeData(style: _textButtonStyle()),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _outlinedButtonStyle(foreground: darkInk),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: darkInk.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DSColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: darkInk.withValues(alpha: 0.45),
        ),
      ),

      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: DSColors.primary,
        unselectedItemColor: darkInk.withValues(alpha: 0.45),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
      ),
    );
  }

  static TextStyle _buttonTextStyle() => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1,
      );

  static ButtonStyle _elevatedButtonStyle({
    required Color background,
    required Color shadow,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: shadow,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      minimumSize: const Size(0, 48),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: _buttonTextStyle(),
    );
  }

  static ButtonStyle _textButtonStyle() {
    return TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      minimumSize: const Size(0, 44),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      alignment: Alignment.center,
      textStyle: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1,
      ),
    );
  }

  static ButtonStyle _outlinedButtonStyle({required Color foreground}) {
    return OutlinedButton.styleFrom(
      foregroundColor: foreground,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      minimumSize: const Size(0, 48),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      alignment: Alignment.center,
      side: const BorderSide(color: DSColors.line),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: _buttonTextStyle(),
    );
  }
}
