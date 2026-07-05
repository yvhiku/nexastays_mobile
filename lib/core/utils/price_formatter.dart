// =============================================================================
// NexaStays Price Formatter
// =============================================================================
// Centralised utility for formatting currency values across the ap.
// Handles whole-number stripping and "per night" suffixes.
// =============================================================================

import 'package:intl/intl.dart';

/// Formatter for property and booking prices.
///
/// Ensures all prices use the same currency symbol (USD by default) and
/// decimal precision across the NexaStays app.
class PriceFormatter {
  PriceFormatter._();

  /// The underlying currency formatter.
  ///
  /// Uses USD by default. `decimalDigits: 0` drops `.00` for whole numbers
  /// (which is standard for NexaStays pricing UI).
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 0,
    customPattern: '\u00A4#,##0',
  );

  /// Formats a raw price amount into a currency string.
  ///
  /// Example: `120.0` → `$120`
  static String format(double price) {
    return _currencyFormat.format(price);
  }

  /// Formats a raw price amount and appends a "per night" suffix.
  ///
  /// Example: `120.0` → `$120 / night`
  static String formatNight(double price) {
    final formatted = format(price);
    return '$formatted / night';
  }
}
