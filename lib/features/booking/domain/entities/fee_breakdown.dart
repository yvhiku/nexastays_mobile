import 'package:equatable/equatable.dart';

import '../../../../core/config/stays_fee_config.dart';

class FeeBreakdown extends Equatable {
  final double nightlyRate;
  final int nights;
  final double subtotal;
  final double guestServiceFee;
  final double hostPlatformFee;
  final double totalGuestPays;
  final double hostPayout;
  final double? weeklyDiscount;
  final double? monthlyDiscount;

  const FeeBreakdown({
    required this.nightlyRate,
    required this.nights,
    required this.subtotal,
    required this.guestServiceFee,
    required this.hostPlatformFee,
    required this.totalGuestPays,
    required this.hostPayout,
    this.weeklyDiscount,
    this.monthlyDiscount,
  });

  factory FeeBreakdown.calculate({
    required double nightlyRate,
    required int nights,
    double? weeklyDiscountPercent,
    double? monthlyDiscountPercent,
  }) {
    double currentSubtotal = nightlyRate * nights;
    double? weeklySaving;
    double? monthlySaving;

    if (nights >= 28 && monthlyDiscountPercent != null) {
      monthlySaving = currentSubtotal * (monthlyDiscountPercent / 100);
      currentSubtotal -= monthlySaving;
    } else if (nights >= 7 && weeklyDiscountPercent != null) {
      weeklySaving = currentSubtotal * (weeklyDiscountPercent / 100);
      currentSubtotal -= weeklySaving;
    }

    final config = StaysFeeConfig.instance;
    final guestServiceFee = currentSubtotal * config.guestFeePct;
    final hostPlatformFee = currentSubtotal * config.hostFeePct;
    final totalGuestPays = currentSubtotal + guestServiceFee;
    final hostPayout = currentSubtotal - hostPlatformFee;

    return FeeBreakdown(
      nightlyRate: nightlyRate,
      nights: nights,
      subtotal: currentSubtotal,
      guestServiceFee: guestServiceFee,
      hostPlatformFee: hostPlatformFee,
      totalGuestPays: totalGuestPays,
      hostPayout: hostPayout,
      weeklyDiscount: weeklySaving,
      monthlyDiscount: monthlySaving,
    );
  }

  // ── Getters ──────────────────────────────────────────────────────────

  String get subtotalDisplay => '${subtotal.toInt()} MAD';
  String get guestFeeDisplay => '+${guestServiceFee.toInt()} MAD';
  String get totalDisplay => '${totalGuestPays.toInt()} MAD';
  String get hostPayoutDisplay => '${hostPayout.toInt()} MAD';

  bool get hasDiscount => weeklyDiscount != null || monthlyDiscount != null;

  double get totalDiscount => (weeklyDiscount ?? 0) + (monthlyDiscount ?? 0);

  // ── Utility ──────────────────────────────────────────────────────────

  FeeBreakdown copyWith({
    double? nightlyRate,
    int? nights,
    double? subtotal,
    double? guestServiceFee,
    double? hostPlatformFee,
    double? totalGuestPays,
    double? hostPayout,
    double? weeklyDiscount,
    double? monthlyDiscount,
  }) {
    return FeeBreakdown(
      nightlyRate: nightlyRate ?? this.nightlyRate,
      nights: nights ?? this.nights,
      subtotal: subtotal ?? this.subtotal,
      guestServiceFee: guestServiceFee ?? this.guestServiceFee,
      hostPlatformFee: hostPlatformFee ?? this.hostPlatformFee,
      totalGuestPays: totalGuestPays ?? this.totalGuestPays,
      hostPayout: hostPayout ?? this.hostPayout,
      weeklyDiscount: weeklyDiscount ?? this.weeklyDiscount,
      monthlyDiscount: monthlyDiscount ?? this.monthlyDiscount,
    );
  }

  @override
  List<Object?> get props => [
        nightlyRate,
        nights,
        subtotal,
        guestServiceFee,
        hostPlatformFee,
        totalGuestPays,
        hostPayout,
        weeklyDiscount,
        monthlyDiscount,
      ];
}
