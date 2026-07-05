// =============================================================================
// NexaStays String Extensions
// =============================================================================
// Handy extension methods on [String] for validation, formatting, and
// truncation used across the app.
// =============================================================================

/// Validation and formatting helpers for [String].
extension StringExt on String {
  // ── Validation ──────────────────────────────────────────────────────

  /// `true` if this string is a valid email address.
  ///
  /// Uses a simplified RFC 5322 regex — sufficient for client-side checks.
  bool get isEmail {
    final regex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    return regex.hasMatch(this);
  }

  /// `true` if this string looks like an international phone number.
  ///
  /// Accepts optional leading `+`, followed by 7–15 digits (spaces, dashes,
  /// and parentheses are allowed).
  bool get isPhone {
    final regex = RegExp(
      r'^\+?[\d\s\-\(\)]{7,15}$',
    );
    return regex.hasMatch(this);
  }

  /// `true` if every character is a digit (`0`–`9`).
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);

  // ── Formatting ──────────────────────────────────────────────────────

  /// Returns this string with the first character upper-cased.
  ///
  /// ```dart
  /// 'hello'.capitalize(); // 'Hello'
  /// ```
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Truncates this string to [length] characters and appends `…` if it
  /// was longer than [length].
  ///
  /// ```dart
  /// 'A long description'.truncate(10); // 'A long des…'
  /// ```
  String truncate(int length) {
    if (this.length <= length) return this;
    return '${substring(0, length)}…';
  }
}
