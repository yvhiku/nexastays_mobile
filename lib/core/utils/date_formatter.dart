// =============================================================================
// NexaStays Date Formatter
// =============================================================================
// Centralised utility for date formatting logic that might require cross-locale
// support or complex range concatenation later.
// =============================================================================

import 'package:intl/intl.dart';

/// Formatter for short, long, and range duration strings matching the
/// NexaStays web component designs.
class DateFormatter {
  DateFormatter._();

  /// Formats as a short month and day.
  ///
  /// Example: `Jun 24`
  static String formatShort(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Formats as a long date with full month, day, and year.
  ///
  /// Example: `24 June 2025`
  static String formatLong(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  /// Formats a stay duration range.
  ///
  /// Example: `24 Jun - 28 Jun`
  static String formatBookingRange(DateTime start, DateTime end) {
    final startFmt = DateFormat('d MMM').format(start);
    final endFmt = DateFormat('d MMM').format(end);

    return '$startFmt - $endFmt';
  }
}
