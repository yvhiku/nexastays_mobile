// =============================================================================
// NexaStays — Font helpers (matches nexastays_web)
// =============================================================================
// Playfair Display → headlines, display, card titles
// DM Sans → body, labels, buttons, inputs
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Typed font helpers — prefer these over raw [GoogleFonts] in new code.
abstract final class NexaFonts {
  /// Serif headline (Playfair Display) — page titles, section headers, card titles.
  static TextStyle display({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w700,
    Color color = DSColors.ink,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Sans body (DM Sans) — paragraphs, descriptions, meta text.
  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = DSColors.ink3,
    double? height,
  }) =>
      GoogleFonts.dmSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height ?? 1.5,
      );

  /// Sans label (DM Sans semibold) — form labels, buttons, chips.
  static TextStyle label({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color color = DSColors.ink2,
  }) =>
      GoogleFonts.dmSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: 1.2,
      );
}
