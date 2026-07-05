import '../../../home/domain/entities/property.dart';

class MonthlyEarningPoint {
  const MonthlyEarningPoint({
    required this.year,
    required this.month,
    required this.amount,
    required this.label,
  });

  final int year;
  final int month;
  final double amount;
  final String label;
}

class PropertyBookingHistoryItem {
  const PropertyBookingHistoryItem({
    required this.bookingId,
    required this.guestName,
    required this.checkIn,
    required this.checkOut,
    required this.amount,
    required this.currency,
    required this.statusLabel,
    required this.isCompleted,
    required this.isCancelled,
  });

  final String bookingId;
  final String guestName;
  final DateTime checkIn;
  final DateTime checkOut;
  final double amount;
  final String currency;
  final String statusLabel;
  final bool isCompleted;
  final bool isCancelled;
}

class PropertyListingAnalytics {
  const PropertyListingAnalytics({
    required this.earningsYtd,
    required this.earningsTrendPct,
    required this.occupancyPercent,
    required this.occupancyTrendPct,
    required this.monthlyEarnings,
  });

  final double earningsYtd;
  final double earningsTrendPct;
  final double occupancyPercent;
  final double occupancyTrendPct;
  final List<MonthlyEarningPoint> monthlyEarnings;
}

class HostPropertyManageData {
  const HostPropertyManageData({
    required this.property,
    required this.analytics,
    required this.pastBookings,
  });

  final Property property;
  final PropertyListingAnalytics analytics;
  final List<PropertyBookingHistoryItem> pastBookings;
}
