// =============================================================================
// NexaStays Design System — Typography
// =============================================================================
// Playfair Display (headlines) + DM Sans (body, labels) — matches web.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Semantic typography tokens mapping to the [TextTheme] scale.
class DSTypography {
  DSTypography._();

  static String? get displayFontFamily => GoogleFonts.playfairDisplay().fontFamily;
  static String? get bodyFontFamily => GoogleFonts.dmSans().fontFamily;

  // ── Headlines (Playfair Display) ────────────────────────────────────

  static TextStyle get heading1 => GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: DSColors.ink,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle get heading2 => GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: DSColors.ink,
        height: 1.2,
      );

  static TextStyle get heading3 => GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: DSColors.ink,
        height: 1.25,
      );

  static TextStyle get heading4 => GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: DSColors.ink,
        height: 1.25,
      );

  // ── Body (DM Sans) ──────────────────────────────────────────────────

  static TextStyle get bodyLarge => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: DSColors.ink3,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: DSColors.ink3,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: DSColors.ink4,
        height: 1.5,
      );

  // ── Labels (DM Sans, uppercase eyebrows on web) ────────────────────

  static TextStyle get labelLarge => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: DSColors.ink2,
        height: 1.2,
      );

  static TextStyle get labelMedium => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: DSColors.ink2,
        height: 1.2,
      );

  /// Eyebrow / section label — matches web `text-xs uppercase tracking-[0.12em]`.
  static TextStyle get eyebrow => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: DSColors.primary,
        letterSpacing: 1.44,
        height: 1.2,
      );

  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: DSColors.ink4,
        height: 1.4,
      );

  static const TextHeightBehavior centeredTextHeight = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );

  static TextStyle get buttonLabel => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1,
        color: Colors.white,
      );

  static TextStyle get buttonLabelSmall => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1,
        color: Colors.white,
      );

  static TextTheme toTextTheme() {
    return TextTheme(
      displayLarge: heading1,
      displayMedium: heading2,
      displaySmall: heading3,
      headlineLarge: heading4,
      headlineMedium: heading4.copyWith(fontSize: 18),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: DSColors.ink,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: DSColors.ink,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: DSColors.ink,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: DSColors.ink,
      ),
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: caption,
    );
  }
}
