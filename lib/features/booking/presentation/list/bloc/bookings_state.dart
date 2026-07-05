import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking.dart';

enum BookingsTab { upcoming, past }

sealed class BookingsState extends Equatable {
  const BookingsState();

  @override
  List<Object?> get props => [];
}

class BookingsInitial extends BookingsState {
  const BookingsInitial();
}

class BookingsLoading extends BookingsState {
  const BookingsLoading();
}

class BookingsLoaded extends BookingsState {
  final List<Booking> upcomingBookings;
  final List<Booking> pastBookings;
  final BookingsTab activeTab;

  const BookingsLoaded({
    required this.upcomingBookings,
    required this.pastBookings,
    required this.activeTab,
  });

  @override
  List<Object?> get props => [upcomingBookings, pastBookings, activeTab];
}

class BookingsEmpty extends BookingsState {
  final BookingsTab tab;

  const BookingsEmpty({required this.tab});

  @override
  List<Object?> get props => [tab];
}

class BookingsError extends BookingsState {
  final String message;

  const BookingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BookingCancelSuccess extends BookingsState {
  final String bookingId;

  const BookingCancelSuccess({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}
