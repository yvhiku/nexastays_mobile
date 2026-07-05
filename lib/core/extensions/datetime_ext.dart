// =============================================================================
// NexaStays DateTime Extensions
// =============================================================================
// Handy extension methods on [DateTime] for checking temporal state (today,
// past, future) and formatting dates consistently across the app using `intl`.
// =============================================================================

import 'package:intl/intl.dart';

/// Temporal checks and formatting helpers for [DateTime].
extension DateTimeExt on DateTime {
  // ── State checks ────────────────────────────────────────────────────

  /// `true` if this date falls on the current calendar day (local time).
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// `true` if this date is strictly before the current moment.
  bool get isPast => isBefore(DateTime.now());

  /// `true` if this date is strictly after the current moment.
  bool get isFuture => isAfter(DateTime.now());

  // ── Formatting ──────────────────────────────────────────────────────

  /// Formats as a short month and day.
  ///
  /// Example: `Jul 22`
  String toShortDate() {
    return DateFormat('MMM d').format(this);
  }

  /// Formats as a full booking date with day, month, and year.
  ///
  /// Example: `22 Jul 2025`
  String toBookingDate() {
    return DateFormat('d MMM yyyy').format(this);
  }
}
