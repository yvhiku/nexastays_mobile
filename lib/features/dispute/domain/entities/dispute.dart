import 'package:equatable/equatable.dart';

// =============================================================================
// Dispute Enums
// =============================================================================

enum DisputeType {
  propertyNotAsDescribed,
  checkInIssue,
  amenityMissing,
  cleanlinessIssue,
  safetyIssue,
  hostNoShow,
  unauthorisedCharge,
  other,
}

enum DisputeStatus {
  open,
  underReview,
  awaitingHost,
  resolved,
  rejected,
  closed,
}

enum DisputeResolution {
  fullRefund,
  partialRefund,
  noRefund,
  warningIssued,
  listingRemoved,
}

// =============================================================================
// Dispute Timeline Event
// =============================================================================

class DisputeTimelineEvent extends Equatable {
  const DisputeTimelineEvent({
    required this.id,
    required this.message,
    required this.actor,
    required this.timestamp,
    this.isSystemEvent = false,
  });

  final String id;

  /// Human-readable event description.
  final String message;

  /// One of `'guest'`, `'host'`, or `'nexa'`.
  final String actor;

  final DateTime timestamp;

  /// If `true`, the event is rendered in a muted gray style.
  final bool isSystemEvent;

  @override
  List<Object?> get props => [id, message, actor, timestamp, isSystemEvent];
}

// =============================================================================
// Dispute Entity
// =============================================================================

class Dispute extends Equatable {
  const Dispute({
    required this.id,
    required this.bookingId,
    required this.propertyId,
    required this.propertyName,
    required this.guestId,
    required this.guestName,
    required this.hostId,
    required this.hostName,
    required this.type,
    required this.description,
    required this.evidenceUrls,
    required this.status,
    this.resolutionNote,
    this.resolution,
    this.refundAmount,
    required this.openedAt,
    this.reviewedAt,
    this.resolvedAt,
    this.timeline = const [],
  });

  final String id;
  final String bookingId;
  final String propertyId;
  final String propertyName;
  final String guestId;
  final String guestName;
  final String hostId;
  final String hostName;
  final DisputeType type;

  /// Guest's written description of the issue.
  final String description;

  /// Uploaded photo/video paths as evidence.
  final List<String> evidenceUrls;

  final DisputeStatus status;

  /// Nexa's final decision note (populated when resolved/rejected).
  final String? resolutionNote;

  final DisputeResolution? resolution;

  /// Refund amount in MAD, if a refund was granted.
  final double? refundAmount;

  final DateTime openedAt;
  final DateTime? reviewedAt;
  final DateTime? resolvedAt;

  final List<DisputeTimelineEvent> timeline;

  // ── Getters ──────────────────────────────────────────────────────────

  bool get isPending =>
      status == DisputeStatus.open ||
      status == DisputeStatus.underReview ||
      status == DisputeStatus.awaitingHost;

  bool get isResolved =>
      status == DisputeStatus.resolved || status == DisputeStatus.closed;

  bool get canAddEvidence =>
      status == DisputeStatus.open || status == DisputeStatus.awaitingHost;

  String get statusLabel => switch (status) {
        DisputeStatus.open => 'Open',
        DisputeStatus.underReview => 'Under review',
        DisputeStatus.awaitingHost => 'Awaiting host',
        DisputeStatus.resolved => 'Resolved',
        DisputeStatus.rejected => 'Rejected',
        DisputeStatus.closed => 'Closed',
      };

  String get typeLabel => switch (type) {
        DisputeType.propertyNotAsDescribed => 'Property not as described',
        DisputeType.checkInIssue => 'Check-in issue',
        DisputeType.amenityMissing => 'Amenity missing',
        DisputeType.cleanlinessIssue => 'Cleanliness issue',
        DisputeType.safetyIssue => 'Safety issue',
        DisputeType.hostNoShow => 'Host no-show',
        DisputeType.unauthorisedCharge => 'Unauthorised charge',
        DisputeType.other => 'Other',
      };

  // ── copyWith ─────────────────────────────────────────────────────────

  Dispute copyWith({
    String? id,
    String? bookingId,
    String? propertyId,
    String? propertyName,
    String? guestId,
    String? guestName,
    String? hostId,
    String? hostName,
    DisputeType? type,
    String? description,
    List<String>? evidenceUrls,
    DisputeStatus? status,
    String? resolutionNote,
    DisputeResolution? resolution,
    double? refundAmount,
    DateTime? openedAt,
    DateTime? reviewedAt,
    DateTime? resolvedAt,
    List<DisputeTimelineEvent>? timeline,
  }) {
    return Dispute(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      propertyId: propertyId ?? this.propertyId,
      propertyName: propertyName ?? this.propertyName,
      guestId: guestId ?? this.guestId,
      guestName: guestName ?? this.guestName,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      type: type ?? this.type,
      description: description ?? this.description,
      evidenceUrls: evidenceUrls ?? this.evidenceUrls,
      status: status ?? this.status,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      resolution: resolution ?? this.resolution,
      refundAmount: refundAmount ?? this.refundAmount,
      openedAt: openedAt ?? this.openedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      timeline: timeline ?? this.timeline,
    );
  }

  // ── Equatable ────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
        id,
        bookingId,
        propertyId,
        propertyName,
        guestId,
        guestName,
        hostId,
        hostName,
        type,
        description,
        evidenceUrls,
        status,
        resolutionNote,
        resolution,
        refundAmount,
        openedAt,
        reviewedAt,
        resolvedAt,
        timeline,
      ];
}
