import '../../domain/entities/reservation_snapshot.dart';

class ReservationSnapshotModel extends ReservationSnapshot {
  const ReservationSnapshotModel({
    required super.listingTitle,
    super.primaryPhotoUrl,
    super.addressDisplay,
    required super.checkinDate,
    required super.checkoutDate,
    required super.guestCount,
    super.hostDisplayName,
    super.guestDisplayName,
    super.bookingReference,
  });

  factory ReservationSnapshotModel.fromJson(Map<String, dynamic> json) {
    return ReservationSnapshotModel(
      listingTitle: json['listingTitle'] as String? ?? 'Stay',
      primaryPhotoUrl: json['primaryPhotoUrl'] as String?,
      addressDisplay: json['addressDisplay'] as String?,
      checkinDate: json['checkinDate'] as String? ?? '',
      checkoutDate: json['checkoutDate'] as String? ?? '',
      guestCount: (json['guestCount'] as num?)?.toInt() ?? 1,
      hostDisplayName: json['hostDisplayName'] as String?,
      guestDisplayName: json['guestDisplayName'] as String?,
      bookingReference: json['bookingReference'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'listingTitle': listingTitle,
        'primaryPhotoUrl': primaryPhotoUrl,
        'addressDisplay': addressDisplay,
        'checkinDate': checkinDate,
        'checkoutDate': checkoutDate,
        'guestCount': guestCount,
        'hostDisplayName': hostDisplayName,
        'guestDisplayName': guestDisplayName,
        'bookingReference': bookingReference,
      };
}
