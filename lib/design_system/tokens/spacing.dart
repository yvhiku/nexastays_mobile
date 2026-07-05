// =============================================================================
// NexaStays Design System — Spacing
// =============================================================================
// Pre-defined spacing multipliers and padding constants. Keeps gaps and
// margins consistent across the entire component library without hard-coding.
// =============================================================================

import 'package:flutter/material.dart';

/// Semantic spacing and inset tokens for the NexaStays design system.
class DSSpacing {
  DSSpacing._();

  // ── Margins & Constraints ───────────────────────────────────────────

  /// Extra small (4.0) — tight inner padding, icon–label gap.
  static const double xs = 4.0;

  /// Small (8.0) — compact padding, list-item spacing.
  static const double s = 8.0;

  /// Medium (16.0) — default content padding, section gaps.
  static const double m = 16.0;

  /// Large (24.0) — generous spacing between sections.
  static const double l = 24.0;

  /// Extra large (32.0) — page-level padding.
  static const double xl = 32.0;

  /// Extra extra large (48.0) — empty state gaps, major section breaks.
  static const double xxl = 48.0;

  // ── Radii ───────────────────────────────────────────────────────────

  /// Standard corner radius (12.0) matching the NexaStays web design.
  static const double borderRadius = 12.0;

  // ── Insets (EdgeInsets) ─────────────────────────────────────────────

  /// Padding all sides (8.0).
  ///
  /// ```dart
  /// Padding(padding: DSSpacing.paddingAllS, child: ...)
  /// ```
  static const EdgeInsets paddingAllS = EdgeInsets.all(s);

  /// Padding all sides (16.0).
  ///
  /// ```dart
  /// Padding(padding: DSSpacing.paddingAllM, child: ...)
  /// ```
  static const EdgeInsets paddingAllM = EdgeInsets.all(m);

  /// Padding all sides (24.0).
  ///
  /// ```dart
  /// Padding(padding: DSSpacing.paddingAllL, child: ...)
  /// ```
  static const EdgeInsets paddingAllL = EdgeInsets.all(l);

  /// Horizontal padding (8.0).
  ///
  /// ```dart
  /// Padding(padding: DSSpacing.paddingHorzS, child: ...)
  /// ```
  static const EdgeInsets paddingHorzS = EdgeInsets.symmetric(horizontal: s);

  /// Horizontal padding (16.0).
  ///
  /// ```dart
  /// Padding(padding: DSSpacing.paddingHorzM, child: ...)
  /// ```
  static const EdgeInsets paddingHorzM = EdgeInsets.symmetric(horizontal: m);

  /// Horizontal padding (24.0).
  ///
  /// ```dart
  /// Padding(padding: DSSpacing.paddingHorzL, child: ...)
  /// ```
  static const EdgeInsets paddingHorzL = EdgeInsets.symmetric(horizontal: l);

  /// Vertical padding (8.0).
  ///
  /// ```dart
  /// Padding(padding: DSSpacing.paddingVertS, child: ...)
  /// ```
  static const EdgeInsets paddingVertS = EdgeInsets.symmetric(vertical: s);

  /// Vertical padding (16.0).
  ///
  /// ```dart
  /// Padding(padding: DSSpacing.paddingVertM, child: ...)
  /// ```
  static const EdgeInsets paddingVertM = EdgeInsets.symmetric(vertical: m);

  /// Vertical padding (24.0).
  ///
  /// ```dart
  /// Padding(padding: DSSpacing.paddingVertL, child: ...)
  /// ```
  static const EdgeInsets paddingVertL = EdgeInsets.symmetric(vertical: l);
}
