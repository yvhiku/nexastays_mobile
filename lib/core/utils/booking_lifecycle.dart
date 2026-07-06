import 'package:flutter/material.dart' show Color;

import '../../features/booking/domain/entities/booking.dart';

enum BookingLifecycle {
  upcoming,
  active,
  completed,
  pendingPayment,
  cancelled,
  expired,
}

enum BookingsTab {
  upcoming,
  current,
  pending,
  completed,
  cancelled,
  all,
}

const int paymentPendingTtlMinutes = 60;
const int bookingsPageSize = 10;

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime getPaymentExpiresAt(DateTime createdAt) =>
    createdAt.add(const Duration(minutes: paymentPendingTtlMinutes));

BookingLifecycle resolveBookingLifecycle(Booking booking) {
  final now = DateTime.now();
  final today = _startOfDay(now);
  final checkin = _startOfDay(booking.checkIn);
  final checkout = _startOfDay(booking.checkOut);

  if (booking.isExpired) return BookingLifecycle.expired;

  if (booking.status == BookingStatus.cancelled ||
      booking.status == BookingStatus.rejected) {
    return BookingLifecycle.cancelled;
  }

  if (booking.status == BookingStatus.paymentPending ||
      booking.status == BookingStatus.pending) {
    final expiresAt =
        booking.paymentExpiresAt ?? getPaymentExpiresAt(booking.createdAt);
    if (!expiresAt.isAfter(now)) return BookingLifecycle.expired;
    return BookingLifecycle.pendingPayment;
  }

  if (booking.status == BookingStatus.completed) {
    return BookingLifecycle.completed;
  }

  if (booking.status == BookingStatus.confirmed ||
      booking.status == BookingStatus.active) {
    if (!today.isBefore(checkout)) return BookingLifecycle.completed;
    if (!today.isBefore(checkin) && today.isBefore(checkout)) {
      return BookingLifecycle.active;
    }
    if (today.isBefore(checkin)) return BookingLifecycle.upcoming;
  }

  return BookingLifecycle.cancelled;
}

BookingsTab? lifecycleToTab(BookingLifecycle lifecycle) {
  switch (lifecycle) {
    case BookingLifecycle.upcoming:
      return BookingsTab.upcoming;
    case BookingLifecycle.active:
      return BookingsTab.current;
    case BookingLifecycle.pendingPayment:
      return BookingsTab.pending;
    case BookingLifecycle.completed:
      return BookingsTab.completed;
    case BookingLifecycle.cancelled:
    case BookingLifecycle.expired:
      return BookingsTab.cancelled;
  }
}

bool canCancelBooking(Booking booking) {
  if (booking.canCancelOverride != null) return booking.canCancelOverride!;
  final lifecycle = resolveBookingLifecycle(booking);
  return lifecycle == BookingLifecycle.pendingPayment ||
      lifecycle == BookingLifecycle.upcoming;
}

bool canReviewBooking(Booking booking) {
  if (booking.canReviewOverride != null) return booking.canReviewOverride!;
  return resolveBookingLifecycle(booking) == BookingLifecycle.completed;
}

bool canComplainBooking(Booking booking) {
  if (booking.canComplainOverride != null) return booking.canComplainOverride!;
  final lifecycle = resolveBookingLifecycle(booking);
  return lifecycle == BookingLifecycle.active ||
      lifecycle == BookingLifecycle.completed;
}

class BookingFilters {
  const BookingFilters({
    this.search = '',
    this.dateFrom,
    this.dateTo,
    this.status,
    this.city,
    this.priceMin,
    this.priceMax,
    this.sort = BookingSort.newest,
  });

  final String search;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final BookingLifecycle? status;
  final String? city;
  final double? priceMin;
  final double? priceMax;
  final BookingSort sort;

  static const BookingFilters defaults = BookingFilters();

  BookingFilters copyWith({
    String? search,
    DateTime? dateFrom,
    DateTime? dateTo,
    BookingLifecycle? status,
    String? city,
    double? priceMin,
    double? priceMax,
    BookingSort? sort,
    bool clearDateFrom = false,
    bool clearDateTo = false,
    bool clearStatus = false,
    bool clearCity = false,
    bool clearPriceMin = false,
    bool clearPriceMax = false,
  }) {
    return BookingFilters(
      search: search ?? this.search,
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      status: clearStatus ? null : (status ?? this.status),
      city: clearCity ? null : (city ?? this.city),
      priceMin: clearPriceMin ? null : (priceMin ?? this.priceMin),
      priceMax: clearPriceMax ? null : (priceMax ?? this.priceMax),
      sort: sort ?? this.sort,
    );
  }
}

enum BookingSort { newest, oldest, checkin, price, guests }

List<Booking> filterAndSortBookings(
  List<Booking> bookings,
  BookingsTab tab,
  BookingFilters filters,
) {
  final result = bookings.where((b) {
    final lifecycle = resolveBookingLifecycle(b);
    final bookingTab = lifecycleToTab(lifecycle);
    if (tab != BookingsTab.all && bookingTab != tab) return false;
    if (filters.status != null && lifecycle != filters.status) return false;

    if (filters.city != null && filters.city!.isNotEmpty) {
      if (b.propertyCity.toLowerCase() != filters.city!.toLowerCase()) {
        return false;
      }
    }

    if (filters.dateFrom != null) {
      if (_startOfDay(b.checkOut).isBefore(_startOfDay(filters.dateFrom!))) {
        return false;
      }
    }
    if (filters.dateTo != null) {
      if (_startOfDay(b.checkIn).isAfter(_startOfDay(filters.dateTo!))) {
        return false;
      }
    }

    final price = b.feeBreakdown.totalGuestPays;
    if (filters.priceMin != null && price < filters.priceMin!) return false;
    if (filters.priceMax != null && price > filters.priceMax!) return false;

    final q = filters.search.trim().toLowerCase();
    if (q.isNotEmpty) {
      final title = b.propertyName.toLowerCase();
      final city = b.propertyCity.toLowerCase();
      final id = b.id.toLowerCase();
      if (!title.contains(q) && !city.contains(q) && !id.contains(q)) {
        return false;
      }
    }

    return true;
  }).toList();

  result.sort((a, b) {
    switch (filters.sort) {
      case BookingSort.oldest:
        return a.createdAt.compareTo(b.createdAt);
      case BookingSort.checkin:
        return a.checkIn.compareTo(b.checkIn);
      case BookingSort.price:
        return b.feeBreakdown.totalGuestPays
            .compareTo(a.feeBreakdown.totalGuestPays);
      case BookingSort.guests:
        return b.guests.compareTo(a.guests);
      case BookingSort.newest:
        return b.createdAt.compareTo(a.createdAt);
    }
  });

  return result;
}

Map<BookingsTab, int> countByTab(List<Booking> bookings) {
  final counts = <BookingsTab, int>{
    BookingsTab.upcoming: 0,
    BookingsTab.current: 0,
    BookingsTab.pending: 0,
    BookingsTab.completed: 0,
    BookingsTab.cancelled: 0,
    BookingsTab.all: bookings.length,
  };

  for (final b in bookings) {
    final tab = lifecycleToTab(resolveBookingLifecycle(b));
    if (tab != null && tab != BookingsTab.all) {
      counts[tab] = (counts[tab] ?? 0) + 1;
    }
  }

  return counts;
}

List<String> uniqueCities(List<Booking> bookings) {
  final set = <String>{};
  for (final b in bookings) {
    final city = b.propertyCity.trim();
    if (city.isNotEmpty) set.add(city);
  }
  final list = set.toList()..sort();
  return list;
}

String lifecycleLabel(BookingLifecycle lifecycle) {
  switch (lifecycle) {
    case BookingLifecycle.upcoming:
      return 'Upcoming';
    case BookingLifecycle.active:
      return 'Current Stay';
    case BookingLifecycle.pendingPayment:
      return 'Awaiting Payment';
    case BookingLifecycle.completed:
      return 'Completed';
    case BookingLifecycle.cancelled:
      return 'Cancelled';
    case BookingLifecycle.expired:
      return 'Expired';
  }
}

String tabLabel(BookingsTab tab) {
  switch (tab) {
    case BookingsTab.upcoming:
      return 'Upcoming';
    case BookingsTab.current:
      return 'Current';
    case BookingsTab.pending:
      return 'Pending';
    case BookingsTab.completed:
      return 'Completed';
    case BookingsTab.cancelled:
      return 'Cancelled';
    case BookingsTab.all:
      return 'All';
  }
}

String tabSectionTitle(BookingsTab tab) {
  switch (tab) {
    case BookingsTab.upcoming:
      return 'Upcoming Bookings';
    case BookingsTab.current:
      return 'Current Stay';
    case BookingsTab.pending:
      return 'Pending Payment';
    case BookingsTab.completed:
      return 'Completed Bookings';
    case BookingsTab.cancelled:
      return 'Cancelled & Expired';
    case BookingsTab.all:
      return 'All Bookings';
  }
}

String tabSectionDescription(BookingsTab tab) {
  switch (tab) {
    case BookingsTab.upcoming:
      return 'Confirmed stays that haven\'t started yet.';
    case BookingsTab.current:
      return 'You\'re checked in — access host contact and directions.';
    case BookingsTab.pending:
      return 'Complete payment before the hold expires.';
    case BookingsTab.completed:
      return 'Past stays — view receipts and leave reviews.';
    case BookingsTab.cancelled:
      return 'Bookings that were cancelled or expired.';
    case BookingsTab.all:
      return 'Every booking across all statuses.';
  }
}

class LifecycleColors {
  const LifecycleColors({required this.background, required this.foreground});
  final Color background;
  final Color foreground;
}

LifecycleColors lifecycleColors(BookingLifecycle lifecycle) {
  switch (lifecycle) {
    case BookingLifecycle.upcoming:
      return const LifecycleColors(
        background: Color(0xFFDBEAFE),
        foreground: Color(0xFF1D4ED8),
      );
    case BookingLifecycle.active:
      return const LifecycleColors(
        background: Color(0xFFD1FAE5),
        foreground: Color(0xFF047857),
      );
    case BookingLifecycle.pendingPayment:
      return const LifecycleColors(
        background: Color(0xFFFFEDD5),
        foreground: Color(0xFFC2410C),
      );
    case BookingLifecycle.completed:
      return const LifecycleColors(
        background: Color(0xFFF3F4F6),
        foreground: Color(0xFF4B5563),
      );
    case BookingLifecycle.cancelled:
    case BookingLifecycle.expired:
      return const LifecycleColors(
        background: Color(0xFFFEE2E2),
        foreground: Color(0xFFB91C1C),
      );
  }
}
