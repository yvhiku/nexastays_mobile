import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';

/// Platform guest/host fee rates loaded from Stays API.
class StaysFeeConfig {
  StaysFeeConfig._();

  static final StaysFeeConfig instance = StaysFeeConfig._();

  double guestFeePct = 0.05;
  double hostFeePct = 0.05;
  double guestFeePercent = 5;
  double hostFeePercent = 5;
  double totalCommissionPercent = 10;

  String get guestFeePercentLabel =>
      _formatPercent(guestFeePercent);

  String get hostFeePercentLabel => _formatPercent(hostFeePercent);

  String get totalCommissionPercentLabel =>
      _formatPercent(totalCommissionPercent);

  Future<void> loadFromApi(String staysBaseUrl) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final res = await dio.get<Map<String, dynamic>>(
        '$staysBaseUrl${ApiEndpoints.staysConfigFees}',
      );
      final data = res.data;
      if (data == null) return;

      guestFeePct = _asDouble(data['guest_fee_pct']) ?? guestFeePct;
      hostFeePct = _asDouble(data['host_fee_pct']) ?? hostFeePct;
      guestFeePercent =
          _asDouble(data['guest_fee_percent']) ?? guestFeePercent;
      hostFeePercent = _asDouble(data['host_fee_percent']) ?? hostFeePercent;
      totalCommissionPercent = _asDouble(data['total_commission_percent']) ??
          totalCommissionPercent;
    } catch (_) {
      // Keep defaults (5% / 5%)
    }
  }

  ({
    double guestFee,
    double hostFee,
    double totalGuestPays,
    double hostPayout,
  }) calculateFees(double subtotal) {
    final guestFee = (subtotal * guestFeePct * 100).round() / 100;
    final hostFee = (subtotal * hostFeePct * 100).round() / 100;
    return (
      guestFee: guestFee,
      hostFee: hostFee,
      totalGuestPays: subtotal + guestFee,
      hostPayout: subtotal - hostFee,
    );
  }

  static String _formatPercent(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    }
    return '${value.toStringAsFixed(1)}%';
  }

  static double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
