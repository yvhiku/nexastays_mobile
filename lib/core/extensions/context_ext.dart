// =============================================================================
// NexaStays BuildContext Extensions
// =============================================================================
// Shorthand properties for accessing theme, typography, colours, and
// screen geometry without boilerplate `Theme.of(context)` or `MediaQuery`.
// =============================================================================

import 'package:flutter/material.dart';

/// Helpers for theme and layout access via [BuildContext].
extension ContextExt on BuildContext {
  // ── Layout & Geometry ───────────────────────────────────────────────

  /// The dimensions of the viewport (screen or current bounded container).
  Size get screenSize => MediaQuery.sizeOf(this);

  /// The width of the viewport.
  double get width => screenSize.width;

  /// The height of the viewport.
  double get height => screenSize.height;

  // ── Theming ─────────────────────────────────────────────────────────

  /// The closest [ThemeData] in the widget tree.
  ThemeData get theme => Theme.of(this);

  /// The active [ColorScheme] from the current theme.
  ColorScheme get colors => theme.colorScheme;

  /// The active [TextTheme] from the current theme.
  TextTheme get text => theme.textTheme;

  // ── State checks ────────────────────────────────────────────────────

  /// `true` if the app is currently rendering in dark mode.
  ///
  /// Checks the brightness of the current [ThemeData], not necessarily
  /// the system platform brightness (since the user might have forced a mode).
  bool get isDarkMode => theme.brightness == Brightness.dark;
}
