import 'package:flutter/material.dart';

import '../../../../../design_system/tokens/colors.dart';

/// Colour tokens for the property listing screen — aligned with nexastays_web.
abstract final class ListingColors {
  static const Color background = DSColors.background;
  static const Color surfaceBright = DSColors.surface;
  static const Color onSurface = DSColors.ink;
  static const Color onSurfaceVariant = DSColors.ink3;
  static const Color primary = DSColors.primary;
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = DSColors.primarySoft;
  static const Color onPrimaryContainer = DSColors.primaryDark;
  static const Color tertiary = DSColors.accent;
  static const Color tertiaryContainer = DSColors.accentSoft;
  static const Color onTertiaryContainer = Color(0xFF7A4A1E);
  static const Color outline = DSColors.line;
  static const Color outlineVariant = DSColors.line;
  static const Color surfaceContainerLow = DSColors.background2;
  static const Color surfaceContainerHighest = DSColors.line;

  static const double marginMobile = 20;
  static const double stackMd = 32;
  static const double stackLg = 48;
}
