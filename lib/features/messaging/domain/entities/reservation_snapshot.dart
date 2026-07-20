import 'package:equatable/equatable.dart';

class ReservationSnapshot extends Equatable {
  const ReservationSnapshot({
    required this.listingTitle,
    this.primaryPhotoUrl,
    this.addressDisplay,
    required this.checkinDate,
    required this.checkoutDate,
    required this.guestCount,
    this.hostDisplayName,
    this.guestDisplayName,
    this.bookingReference,
  });

  final String listingTitle;
  final String? primaryPhotoUrl;
  final String? addressDisplay;
  final String checkinDate;
  final String checkoutDate;
  final int guestCount;
  final String? hostDisplayName;
  final String? guestDisplayName;
  final String? bookingReference;

  @override
  List<Object?> get props => [
        listingTitle,
        primaryPhotoUrl,
        addressDisplay,
        checkinDate,
        checkoutDate,
        guestCount,
        hostDisplayName,
        guestDisplayName,
        bookingReference,
      ];
}
