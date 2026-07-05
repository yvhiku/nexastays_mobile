import '../../domain/entities/dispute.dart';

// =============================================================================
// Dispute Timeline Event Model
// =============================================================================

class DisputeTimelineEventModel extends DisputeTimelineEvent {
  const DisputeTimelineEventModel({
    required super.id,
    required super.message,
    required super.actor,
    required super.timestamp,
    super.isSystemEvent,
  });

  factory DisputeTimelineEventModel.fromJson(Map<String, dynamic> json) {
    return DisputeTimelineEventModel(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      actor: json['actor'] ?? 'nexa',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isSystemEvent: json['is_system_event'] ?? false,
    );
  }

  factory DisputeTimelineEventModel.fromEntity(DisputeTimelineEvent e) {
    return DisputeTimelineEventModel(
      id: e.id,
      message: e.message,
      actor: e.actor,
      timestamp: e.timestamp,
      isSystemEvent: e.isSystemEvent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'actor': actor,
      'timestamp': timestamp.toIso8601String(),
      'is_system_event': isSystemEvent,
    };
  }
}

// =============================================================================
// Dispute Model
// =============================================================================

class DisputeModel extends Dispute {
  const DisputeModel({
    required super.id,
    required super.bookingId,
    required super.propertyId,
    required super.propertyName,
    required super.guestId,
    required super.guestName,
    required super.hostId,
    required super.hostName,
    required super.type,
    required super.description,
    required super.evidenceUrls,
    required super.status,
    super.resolutionNote,
    super.resolution,
    super.refundAmount,
    required super.openedAt,
    super.reviewedAt,
    super.resolvedAt,
    super.timeline,
  });

  // ── fromJson ─────────────────────────────────────────────────────────

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: json['id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      propertyId: json['property_id'] ?? '',
      propertyName: json['property_name'] ?? '',
      guestId: json['guest_id'] ?? '',
      guestName: json['guest_name'] ?? '',
      hostId: json['host_id'] ?? '',
      hostName: json['host_name'] ?? '',
      type: _parseType(json['type'] ?? 'other'),
      description: json['description'] ?? '',
      evidenceUrls: (json['evidence_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: _parseStatus(json['status'] ?? 'open'),
      resolutionNote: json['resolution_note'],
      resolution: _parseResolution(json['resolution']),
      refundAmount: (json['refund_amount'] as num?)?.toDouble(),
      openedAt: json['opened_at'] != null
          ? DateTime.parse(json['opened_at'])
          : DateTime.now(),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) => DisputeTimelineEventModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  // ── fromEntity ───────────────────────────────────────────────────────

  factory DisputeModel.fromEntity(Dispute d) {
    return DisputeModel(
      id: d.id,
      bookingId: d.bookingId,
      propertyId: d.propertyId,
      propertyName: d.propertyName,
      guestId: d.guestId,
      guestName: d.guestName,
      hostId: d.hostId,
      hostName: d.hostName,
      type: d.type,
      description: d.description,
      evidenceUrls: d.evidenceUrls,
      status: d.status,
      resolutionNote: d.resolutionNote,
      resolution: d.resolution,
      refundAmount: d.refundAmount,
      openedAt: d.openedAt,
      reviewedAt: d.reviewedAt,
      resolvedAt: d.resolvedAt,
      timeline: d.timeline
          .map((e) => DisputeTimelineEventModel.fromEntity(e))
          .toList(),
    );
  }

  // ── toJson ───────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'property_id': propertyId,
      'property_name': propertyName,
      'guest_id': guestId,
      'guest_name': guestName,
      'host_id': hostId,
      'host_name': hostName,
      'type': _typeToString(type),
      'description': description,
      'evidence_urls': evidenceUrls,
      'status': _statusToString(status),
      if (resolutionNote != null) 'resolution_note': resolutionNote,
      if (resolution != null) 'resolution': _resolutionToString(resolution!),
      if (refundAmount != null) 'refund_amount': refundAmount,
      'opened_at': openedAt.toIso8601String(),
      if (reviewedAt != null) 'reviewed_at': reviewedAt!.toIso8601String(),
      if (resolvedAt != null) 'resolved_at': resolvedAt!.toIso8601String(),
      'timeline': timeline
          .map((e) => DisputeTimelineEventModel.fromEntity(e).toJson())
          .toList(),
    };
  }

  // ── Enum parsers ─────────────────────────────────────────────────────

  static DisputeType _parseType(String s) => switch (s) {
        'property_not_as_described' => DisputeType.propertyNotAsDescribed,
        'check_in_issue' => DisputeType.checkInIssue,
        'amenity_missing' => DisputeType.amenityMissing,
        'cleanliness_issue' => DisputeType.cleanlinessIssue,
        'safety_issue' => DisputeType.safetyIssue,
        'host_no_show' => DisputeType.hostNoShow,
        'unauthorised_charge' => DisputeType.unauthorisedCharge,
        _ => DisputeType.other,
      };

  static DisputeStatus _parseStatus(String s) => switch (s) {
        'open' => DisputeStatus.open,
        'under_review' => DisputeStatus.underReview,
        'awaiting_host' => DisputeStatus.awaitingHost,
        'resolved' => DisputeStatus.resolved,
        'rejected' => DisputeStatus.rejected,
        'closed' => DisputeStatus.closed,
        _ => DisputeStatus.open,
      };

  static DisputeResolution? _parseResolution(String? s) => switch (s) {
        'full_refund' => DisputeResolution.fullRefund,
        'partial_refund' => DisputeResolution.partialRefund,
        'no_refund' => DisputeResolution.noRefund,
        'warning_issued' => DisputeResolution.warningIssued,
        'listing_removed' => DisputeResolution.listingRemoved,
        _ => null,
      };

  // ── Enum serialisers ─────────────────────────────────────────────────

  static String _typeToString(DisputeType t) => switch (t) {
        DisputeType.propertyNotAsDescribed => 'property_not_as_described',
        DisputeType.checkInIssue => 'check_in_issue',
        DisputeType.amenityMissing => 'amenity_missing',
        DisputeType.cleanlinessIssue => 'cleanliness_issue',
        DisputeType.safetyIssue => 'safety_issue',
        DisputeType.hostNoShow => 'host_no_show',
        DisputeType.unauthorisedCharge => 'unauthorised_charge',
        DisputeType.other => 'other',
      };

  static String _statusToString(DisputeStatus s) => switch (s) {
        DisputeStatus.open => 'open',
        DisputeStatus.underReview => 'under_review',
        DisputeStatus.awaitingHost => 'awaiting_host',
        DisputeStatus.resolved => 'resolved',
        DisputeStatus.rejected => 'rejected',
        DisputeStatus.closed => 'closed',
      };

  static String _resolutionToString(DisputeResolution r) => switch (r) {
        DisputeResolution.fullRefund => 'full_refund',
        DisputeResolution.partialRefund => 'partial_refund',
        DisputeResolution.noRefund => 'no_refund',
        DisputeResolution.warningIssued => 'warning_issued',
        DisputeResolution.listingRemoved => 'listing_removed',
      };
}
