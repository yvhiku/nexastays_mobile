// =============================================================================
// NexaStays Design System — Colors
// =============================================================================
// Matches nexastays_web tailwind.config.ts (nexa-* tokens).
// =============================================================================

import 'package:flutter/material.dart';

/// Semantic colour tokens for the NexaStays design system.
class DSColors {
  DSColors._();

  // ── Primary (brand pink) ────────────────────────────────────────────

  static const Color primary = Color(0xFFE8507A);
  static const Color primaryDark = Color(0xFFC93A62);
  static const Color primaryLight = Color(0xFFF4809A);
  static const Color primarySoft = Color(0xFFFDF0F3);

  // ── Secondary (warm accent) ─────────────────────────────────────────

  static const Color accent = Color(0xFFF9A86C);
  static const Color accentSoft = Color(0xFFFEF5EC);

  // ── Ink / text ──────────────────────────────────────────────────────

  static const Color ink = Color(0xFF1A1118);
  static const Color ink2 = Color(0xFF3D2B36);
  static const Color ink3 = Color(0xFF6B5460);
  static const Color ink4 = Color(0xFF9E8A93);

  /// Primary text — alias for [ink].
  static const Color neutral = ink;

  // ── Surfaces ────────────────────────────────────────────────────────

  static const Color background = Color(0xFFFDFBFC);
  static const Color background2 = Color(0xFFF8F2F5);
  static const Color line = Color(0xFFEDE0E5);
  static const Color surface = Color(0xFFFFFFFF);

  /// Soft tint for inputs, badges, muted containers (alias: primarySoft).
  static const Color muted = primarySoft;

  // ── Semantic ────────────────────────────────────────────────────────

  static const Color success = Color(0xFF27AE60);
  static const Color danger = Color(0xFFEB5757);

  // ── Gradients & swatches ────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const MaterialColor primarySwatch = MaterialColor(
    0xFFE8507A,
    <int, Color>{
      50: Color(0xFFFDF0F3),
      100: Color(0xFFF4809A),
      500: Color(0xFFE8507A),
      700: Color(0xFFC93A62),
      900: Color(0xFF90183B),
    },
  );
}
