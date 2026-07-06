import '../../domain/entities/booking.dart';
import '../../domain/entities/fee_breakdown.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.propertyId,
    required super.propertyName,
    required super.propertyPhotoUrl,
    required super.propertyCity,
    required super.propertyNeighborhood,
    required super.hostId,
    required super.hostName,
    required super.guestId,
    required super.guestName,
    required super.checkIn,
    required super.checkOut,
    required super.guests,
    required super.nightlyRate,
    required super.nights,
    required super.feeBreakdown,
    required super.status,
    super.cancellationReason,
    required super.createdAt,
    super.confirmedAt,
    super.cancelledAt,
    required super.checkInContact,
    required super.checkInContactPhone,
    super.checkInContactRole,
    required super.checkInInstructions,
    required super.exactAddress,
    super.specialRequests,
    super.isExpired,
    super.paymentExpiresAt,
    super.paymentFailed,
    super.canReviewOverride,
    super.canComplainOverride,
    super.canCancelOverride,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      propertyName: json['property_name'] as String,
      propertyPhotoUrl: json['property_photo_url'] as String,
      propertyCity: json['property_city'] as String,
      propertyNeighborhood: json['property_neighborhood'] as String,
      hostId: json['host_id'] as String,
      hostName: json['host_name'] as String,
      guestId: json['guest_id'] as String,
      guestName: json['guest_name'] as String,
      checkIn: DateTime.parse(json['check_in'] as String),
      checkOut: DateTime.parse(json['check_out'] as String),
      guests: json['guests'] as int,
      nightlyRate: (json['nightly_rate'] as num).toDouble(),
      nights: json['nights'] as int,
      feeBreakdown: FeeBreakdownModel.fromJson(
        json['fee_breakdown'] as Map<String, dynamic>,
      ),
      status: _parseStatus(json['status'] as String),
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      checkInContact: json['check_in_contact'] as String,
      checkInContactPhone: json['check_in_contact_phone'] as String,
      checkInInstructions: json['check_in_instructions'] as String,
      exactAddress: json['exact_address'] as String,
      specialRequests: json['special_requests'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'property_name': propertyName,
      'property_photo_url': propertyPhotoUrl,
      'property_city': propertyCity,
      'property_neighborhood': propertyNeighborhood,
      'host_id': hostId,
      'host_name': hostName,
      'guest_id': guestId,
      'guest_name': guestName,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut.toIso8601String(),
      'guests': guests,
      'nightly_rate': nightlyRate,
      'nights': nights,
      'fee_breakdown': (feeBreakdown as FeeBreakdownModel).toJson(),
      'status': _statusToString(status),
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'check_in_contact': checkInContact,
      'check_in_contact_phone': checkInContactPhone,
      'check_in_instructions': checkInInstructions,
      'exact_address': exactAddress,
      'special_requests': specialRequests,
    };
  }

  factory BookingModel.fromEntity(Booking b) {
    return BookingModel(
      id: b.id,
      propertyId: b.propertyId,
      propertyName: b.propertyName,
      propertyPhotoUrl: b.propertyPhotoUrl,
      propertyCity: b.propertyCity,
      propertyNeighborhood: b.propertyNeighborhood,
      hostId: b.hostId,
      hostName: b.hostName,
      guestId: b.guestId,
      guestName: b.guestName,
      checkIn: b.checkIn,
      checkOut: b.checkOut,
      guests: b.guests,
      nightlyRate: b.nightlyRate,
      nights: b.nights,
      feeBreakdown: b.feeBreakdown is FeeBreakdownModel
          ? b.feeBreakdown
          : FeeBreakdownModel.fromEntity(b.feeBreakdown),
      status: b.status,
      cancellationReason: b.cancellationReason,
      createdAt: b.createdAt,
      confirmedAt: b.confirmedAt,
      cancelledAt: b.cancelledAt,
      checkInContact: b.checkInContact,
      checkInContactPhone: b.checkInContactPhone,
      checkInContactRole: b.checkInContactRole,
      checkInInstructions: b.checkInInstructions,
      exactAddress: b.exactAddress,
      specialRequests: b.specialRequests,
      isExpired: b.isExpired,
      paymentExpiresAt: b.paymentExpiresAt,
      paymentFailed: b.paymentFailed,
      canReviewOverride: b.canReviewOverride,
      canComplainOverride: b.canComplainOverride,
      canCancelOverride: b.canCancelOverride,
    );
  }

  static BookingStatus _parseStatus(String s) {
    final key = s.trim().toLowerCase().replaceAll('-', '_');
    switch (key) {
      case 'payment_pending':
        return BookingStatus.paymentPending;
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'active':
        return BookingStatus.active;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'rejected':
        return BookingStatus.rejected;
      default:
        return BookingStatus.pending;
    }
  }

  static String _statusToString(BookingStatus s) {
    return s.toString().split('.').last;
  }
}

class FeeBreakdownModel extends FeeBreakdown {
  const FeeBreakdownModel({
    required super.nightlyRate,
    required super.nights,
    required super.subtotal,
    required super.guestServiceFee,
    required super.hostPlatformFee,
    required super.totalGuestPays,
    required super.hostPayout,
    super.weeklyDiscount,
    super.monthlyDiscount,
  });

  factory FeeBreakdownModel.fromJson(Map<String, dynamic> json) {
    return FeeBreakdownModel(
      nightlyRate: (json['nightly_rate'] as num).toDouble(),
      nights: json['nights'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      guestServiceFee: (json['guest_service_fee'] as num).toDouble(),
      hostPlatformFee: (json['host_platform_fee'] as num).toDouble(),
      totalGuestPays: (json['total_guest_pays'] as num).toDouble(),
      hostPayout: (json['host_payout'] as num).toDouble(),
      weeklyDiscount: (json['weekly_discount'] as num?)?.toDouble(),
      monthlyDiscount: (json['monthly_discount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nightly_rate': nightlyRate,
      'nights': nights,
      'subtotal': subtotal,
      'guest_service_fee': guestServiceFee,
      'host_platform_fee': hostPlatformFee,
      'total_guest_pays': totalGuestPays,
      'host_payout': hostPayout,
      'weekly_discount': weeklyDiscount,
      'monthly_discount': monthlyDiscount,
    };
  }

  factory FeeBreakdownModel.fromEntity(FeeBreakdown e) {
    return FeeBreakdownModel(
      nightlyRate: e.nightlyRate,
      nights: e.nights,
      subtotal: e.subtotal,
      guestServiceFee: e.guestServiceFee,
      hostPlatformFee: e.hostPlatformFee,
      totalGuestPays: e.totalGuestPays,
      hostPayout: e.hostPayout,
      weeklyDiscount: e.weeklyDiscount,
      monthlyDiscount: e.monthlyDiscount,
    );
  }
}
