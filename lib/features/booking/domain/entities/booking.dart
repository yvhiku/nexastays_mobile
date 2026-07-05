import 'package:equatable/equatable.dart';
import 'fee_breakdown.dart';

enum BookingStatus {
  paymentPending, // awaiting guest card payment (CMI / Payzone)
  pending,        // awaiting host/system confirmation
  confirmed,      // booking confirmed — contact + address revealed
  active,         // guest is currently staying
  completed,      // stay finished
  cancelled,      // cancelled by guest or host
  rejected,       // host rejected
}

class Booking extends Equatable {
  final String id;
  final String propertyId;
  final String propertyName;
  final String propertyPhotoUrl;
  final String propertyCity;
  final String propertyNeighborhood;
  final String hostId;
  final String hostName;
  final String guestId;
  final String guestName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double nightlyRate;
  final int nights;
  final FeeBreakdown feeBreakdown;
  final BookingStatus status;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String checkInContact;
  final String checkInContactPhone;
  final String checkInContactRole;
  final String checkInInstructions;
  final String exactAddress;
  final String? specialRequests;

  const Booking({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.propertyPhotoUrl,
    required this.propertyCity,
    required this.propertyNeighborhood,
    required this.hostId,
    required this.hostName,
    required this.guestId,
    required this.guestName,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.nightlyRate,
    required this.nights,
    required this.feeBreakdown,
    required this.status,
    this.cancellationReason,
    required this.createdAt,
    this.confirmedAt,
    this.cancelledAt,
    required this.checkInContact,
    required this.checkInContactPhone,
    this.checkInContactRole = '',
    required this.checkInInstructions,
    required this.exactAddress,
    this.specialRequests,
  });

  // ── Getters ──────────────────────────────────────────────────────────

  bool get isConfirmed =>
      status == BookingStatus.confirmed ||
      status == BookingStatus.active ||
      status == BookingStatus.completed;

  bool get needsPayment => status == BookingStatus.paymentPending;

  bool get canCancel =>
      status == BookingStatus.paymentPending ||
      status == BookingStatus.pending ||
      status == BookingStatus.confirmed;

  bool get canDispute => status == BookingStatus.completed;

  bool get isActive => status == BookingStatus.active;

  bool get contactRevealed => isConfirmed;

  bool get hasContactDetails =>
      checkInContact.isNotEmpty ||
      checkInContactPhone.isNotEmpty ||
      exactAddress.isNotEmpty ||
      checkInInstructions.isNotEmpty;

  String get displayHostName =>
      hostName.isNotEmpty ? hostName : checkInContact;

  String get dateRangeDisplay {
    final start = checkIn;
    final end = checkOut;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final startStr = '${months[start.month - 1]} ${start.day}';
    final endStr = start.month == end.month 
        ? '${end.day}' 
        : '${months[end.month - 1]} ${end.day}';
    
    return '$startStr – $endStr, ${end.year}';
  }

  String get nightsDisplay => nights == 1 ? "1 night" : "$nights nights";

  String get statusLabel {
    switch (status) {
      case BookingStatus.paymentPending:
        return 'Payment pending';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return "Confirmed";
      case BookingStatus.active:
        return "Active";
      case BookingStatus.completed:
        return "Completed";
      case BookingStatus.cancelled:
        return "Cancelled";
      case BookingStatus.rejected:
        return "Rejected";
    }
  }

  // ── Utility ──────────────────────────────────────────────────────────

  Booking copyWith({
    String? id,
    String? propertyId,
    String? propertyName,
    String? propertyPhotoUrl,
    String? propertyCity,
    String? propertyNeighborhood,
    String? hostId,
    String? hostName,
    String? guestId,
    String? guestName,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    double? nightlyRate,
    int? nights,
    FeeBreakdown? feeBreakdown,
    BookingStatus? status,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    String? checkInContact,
    String? checkInContactPhone,
    String? checkInContactRole,
    String? checkInInstructions,
    String? exactAddress,
    String? specialRequests,
  }) {
    return Booking(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      propertyName: propertyName ?? this.propertyName,
      propertyPhotoUrl: propertyPhotoUrl ?? this.propertyPhotoUrl,
      propertyCity: propertyCity ?? this.propertyCity,
      propertyNeighborhood: propertyNeighborhood ?? this.propertyNeighborhood,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      guestId: guestId ?? this.guestId,
      guestName: guestName ?? this.guestName,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guests: guests ?? this.guests,
      nightlyRate: nightlyRate ?? this.nightlyRate,
      nights: nights ?? this.nights,
      feeBreakdown: feeBreakdown ?? this.feeBreakdown,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      checkInContact: checkInContact ?? this.checkInContact,
      checkInContactPhone: checkInContactPhone ?? this.checkInContactPhone,
      checkInContactRole: checkInContactRole ?? this.checkInContactRole,
      checkInInstructions: checkInInstructions ?? this.checkInInstructions,
      exactAddress: exactAddress ?? this.exactAddress,
      specialRequests: specialRequests ?? this.specialRequests,
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        propertyName,
        propertyPhotoUrl,
        propertyCity,
        propertyNeighborhood,
        hostId,
        hostName,
        guestId,
        guestName,
        checkIn,
        checkOut,
        guests,
        nightlyRate,
        nights,
        feeBreakdown,
        status,
        cancellationReason,
        createdAt,
        confirmedAt,
        cancelledAt,
        checkInContact,
        checkInContactPhone,
        checkInContactRole,
        checkInInstructions,
        exactAddress,
        specialRequests,
      ];
}
