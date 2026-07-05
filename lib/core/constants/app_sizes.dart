// =============================================================================
// NexaStays App Sizes
// =============================================================================
// Spacing, radius, elevation, and icon-size constants used across the app.
// Prefer these tokens over hard-coded values to keep the UI consistent.
// =============================================================================

/// Design-token sizes for spacing, border radius, elevation, and icons.
class AppSizes {
  AppSizes._();

  // ── Spacing scale ───────────────────────────────────────────────────
  // Use for padding, margin, gaps, and SizedBox dimensions.

  /// 4 px — tight inner padding, icon–label gap.
  static const double xs = 4.0;

  /// 8 px — compact padding, list-item spacing.
  static const double s = 8.0;

  /// 16 px — default content padding, section gaps.
  static const double m = 16.0;

  /// 24 px — generous spacing between sections.
  static const double l = 24.0;

  /// 32 px — large spacing, page-level padding.
  static const double xl = 32.0;

  // ── Border radius ───────────────────────────────────────────────────
  // Default radius for cards, buttons, inputs, bottom sheets.

  /// 12 px — standard corner radius matching the NexaStays web design.
  static const double borderRadius = 12.0;

  // ── Elevation ───────────────────────────────────────────────────────
  // Material elevation value for cards and floating elements.

  /// 6 dp — soft shadow for property cards and containers.
  static const double cardElevation = 6.0;

  // ── Icons ───────────────────────────────────────────────────────────

  /// 20 px — default icon size for nav bars, list tiles, and actions.
  static const double iconSize = 20.0;
}
