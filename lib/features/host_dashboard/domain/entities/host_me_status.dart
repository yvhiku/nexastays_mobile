/// Response from `GET /stays/host/me` (unified host onboarding).
class HostMeStatus {
  const HostMeStatus({
    required this.isHost,
    required this.applicationStatus,
    required this.identityStatus,
    required this.hostVerificationStatus,
    required this.canCreateListing,
    required this.canPublishListing,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
    this.source,
    this.submittedFrom,
  });

  final bool isHost;
  final String applicationStatus;
  final String identityStatus;
  final String hostVerificationStatus;
  final bool canCreateListing;
  final bool canPublishListing;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? source;
  final String? submittedFrom;

  bool get isPending => applicationStatus.toUpperCase() == 'PENDING';
  bool get isApproved =>
      applicationStatus.toUpperCase() == 'APPROVED' || isHost;
  bool get isRejected => applicationStatus.toUpperCase() == 'REJECTED';

  /// Matches web NavBar: hide "Become a Host" for approved or pending hosts.
  bool get shouldShowBecomeHostBanner => !isApproved && !isPending;
  bool get hasNotStarted =>
      applicationStatus.toUpperCase() == 'NOT_STARTED' ||
      applicationStatus.toUpperCase() == 'DRAFT';

  factory HostMeStatus.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? v) {
      if (v is! String || v.isEmpty) return null;
      return DateTime.tryParse(v);
    }

    return HostMeStatus(
      isHost: json['is_host'] == true,
      applicationStatus:
          (json['application_status'] as String? ?? 'NOT_STARTED').toString(),
      identityStatus:
          (json['identity_status'] as String? ?? 'NOT_STARTED').toString(),
      hostVerificationStatus: (json['host_verification_status'] as String? ??
              'NOT_STARTED')
          .toString(),
      canCreateListing: json['can_create_listing'] == true,
      canPublishListing: json['can_publish_listing'] == true,
      rejectionReason: json['rejection_reason'] as String?,
      submittedAt: parseDate(json['submitted_at']),
      reviewedAt: parseDate(json['reviewed_at']),
      source: json['source'] as String?,
      submittedFrom: json['submitted_from'] as String?,
    );
  }
}
