// =============================================================================
// NexaStays Fee Calculator
// =============================================================================
// Centralised calculation logic for computing total booking costs from a base
// rate and duration. Ensures tax and service fees remain consistent check-out.
// =============================================================================

/// Encapsulates the financial breakdown of a single booking.
class BookingPriceBreakdown {
  const BookingPriceBreakdown({
    required this.subtotal,
    required this.serviceFee,
    required this.tax,
    required this.total,
  });

  /// The raw cost of the stay (nightly rate × nights).
  final double subtotal;

  /// The platform service fee applied to the subtotal.
  final double serviceFee;

  /// The local / national tax applied to the subtotal.
  final double tax;

  /// The final amount the user will be charged.
  final double total;

  @override
  String toString() {
    return 'BookingPriceBreakdown(\n'
        '  Subtotal: \$${subtotal.toStringAsFixed(2)}\n'
        '  Service : \$${serviceFee.toStringAsFixed(2)}\n'
        '  Tax     : \$${tax.toStringAsFixed(2)}\n'
        '  Total   : \$${total.toStringAsFixed(2)}\n'
        ')';
  }
}

/// Central calculations for NexaStays booking fees.
class FeeCalculator {
  FeeCalculator._();

  /// Platform service fee rate (12%).
  static const double _serviceFeeRate = 0.12;

  /// Standard tax rate (8%).
  static const double _taxRate = 0.08;

  /// Calculates the platform service fee based on the [subtotal].
  static double calculateServiceFee(double subtotal) {
    return subtotal * _serviceFeeRate;
  }

  /// Calculates the tax amount based on the [subtotal].
  static double calculateTax(double subtotal) {
    return subtotal * _taxRate;
  }

  /// Computes the full price breakdown for a booking.
  ///
  /// [nightlyPrice] is the base rate per night.
  /// [nights] is the duration of the stay.
  static BookingPriceBreakdown calculateTotal({
    required double nightlyPrice,
    required int nights,
  }) {
    // 1. Calculate raw subtotal
    final subtotal = nightlyPrice * nights.toDouble();

    // 2. Compute fees & taxes
    final serviceFee = calculateServiceFee(subtotal);
    final tax = calculateTax(subtotal);

    // 3. Final total
    final total = subtotal + serviceFee + tax;

    return BookingPriceBreakdown(
      subtotal: subtotal,
      serviceFee: serviceFee,
      tax: tax,
      total: total,
    );
  }
}
