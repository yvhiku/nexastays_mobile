import '../../../booking/domain/entities/booking.dart';
import '../entities/host_property_manage_data.dart';

class ListingAnalyticsCalculator {
  static const _earningStatuses = {
    BookingStatus.confirmed,
    BookingStatus.active,
    BookingStatus.completed,
  };

  static const _monthLabels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

  static PropertyListingAnalytics fromBookings(
    List<Booking> bookings, {
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final yearStart = DateTime(today.year);
    final thisMonthStart = DateTime(today.year, today.month);
    final lastMonthStart = DateTime(today.year, today.month - 1);
    final lastMonthEnd = thisMonthStart;

    var earningsYtd = 0.0;
    var earningsThisMonth = 0.0;
    var earningsLastMonth = 0.0;

    for (final booking in bookings) {
      if (!_earningStatuses.contains(booking.status)) continue;
      final payout = booking.feeBreakdown.hostPayout;
      final ref = booking.confirmedAt ?? booking.checkIn;
      if (!ref.isBefore(yearStart)) {
        earningsYtd += payout;
      }
      if (!ref.isBefore(thisMonthStart)) {
        earningsThisMonth += payout;
      } else if (!ref.isBefore(lastMonthStart) && ref.isBefore(lastMonthEnd)) {
        earningsLastMonth += payout;
      }
    }

    final earningsTrendPct = _percentChange(earningsLastMonth, earningsThisMonth);
    final occupancyPercent = _occupancyForWindow(bookings, today, 30);
    final previousOccupancy = _occupancyForWindow(
      bookings,
      today.subtract(const Duration(days: 30)),
      30,
    );
    final occupancyTrendPct = _percentChange(previousOccupancy, occupancyPercent);

    final monthlyEarnings = <MonthlyEarningPoint>[];
    for (var i = 5; i >= 0; i--) {
      final monthDate = DateTime(today.year, today.month - i);
      final monthStart = DateTime(monthDate.year, monthDate.month);
      final monthEnd = DateTime(monthDate.year, monthDate.month + 1);
      var amount = 0.0;
      for (final booking in bookings) {
        if (!_earningStatuses.contains(booking.status)) continue;
        final ref = booking.confirmedAt ?? booking.checkIn;
        if (!ref.isBefore(monthStart) && ref.isBefore(monthEnd)) {
          amount += booking.feeBreakdown.hostPayout;
        }
      }
      monthlyEarnings.add(
        MonthlyEarningPoint(
          year: monthDate.year,
          month: monthDate.month,
          amount: amount,
          label: _monthLabels[monthDate.month - 1],
        ),
      );
    }

    return PropertyListingAnalytics(
      earningsYtd: earningsYtd,
      earningsTrendPct: earningsTrendPct,
      occupancyPercent: occupancyPercent,
      occupancyTrendPct: occupancyTrendPct,
      monthlyEarnings: monthlyEarnings,
    );
  }

  static List<PropertyBookingHistoryItem> historyFromBookings(
    List<Booking> bookings, {
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final items = bookings.map((booking) {
      final guest = booking.guestName.trim().isNotEmpty
          ? booking.guestName.trim()
          : 'Guest';
      final isCancelled = booking.status == BookingStatus.cancelled;
      final isCompleted = booking.status == BookingStatus.completed;
      final isPast = !booking.checkOut.isAfter(todayDate);
      final statusLabel = isCancelled
          ? 'Canceled'
          : isCompleted || isPast
              ? 'Completed'
              : booking.status == BookingStatus.active
                  ? 'Active'
                  : 'Confirmed';

      return PropertyBookingHistoryItem(
        bookingId: booking.id,
        guestName: guest,
        checkIn: booking.checkIn,
        checkOut: booking.checkOut,
        amount: booking.feeBreakdown.hostPayout,
        currency: 'MAD',
        statusLabel: statusLabel,
        isCompleted: !isCancelled && (isCompleted || isPast),
        isCancelled: isCancelled,
      );
    }).toList();

    items.sort((a, b) => b.checkIn.compareTo(a.checkIn));
    return items;
  }

  static double _occupancyForWindow(
    List<Booking> bookings,
    DateTime windowEnd,
    int days,
  ) {
    if (days <= 0) return 0;
    final end = DateTime(windowEnd.year, windowEnd.month, windowEnd.day);
    final start = end.subtract(Duration(days: days));
    var occupiedNights = 0;

    for (var i = 0; i < days; i++) {
      final day = start.add(Duration(days: i));
      final hasBooking = bookings.any((booking) {
        if (booking.status == BookingStatus.cancelled ||
            booking.status == BookingStatus.rejected) {
          return false;
        }
        final checkIn = DateTime(
          booking.checkIn.year,
          booking.checkIn.month,
          booking.checkIn.day,
        );
        final checkOut = DateTime(
          booking.checkOut.year,
          booking.checkOut.month,
          booking.checkOut.day,
        );
        return !day.isBefore(checkIn) && day.isBefore(checkOut);
      });
      if (hasBooking) occupiedNights++;
    }

    return (occupiedNights / days) * 100;
  }

  static double _percentChange(double previous, double current) {
    if (previous <= 0) {
      return current > 0 ? 100 : 0;
    }
    return ((current - previous) / previous) * 100;
  }
}
