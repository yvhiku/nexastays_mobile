// ─── NEXASTAYS IDENTITY VERIFICATION — SYNC CONTRACT ─────────────────────
// Design tokens:
//   Primary       : Color(0xFFE8507A)
//   Success       : Color(0xFF16A34A)  bg: Color(0xFFF0FDF4)
//   Error         : Color(0xFFDC2626)  bg: Color(0xFFFEF2F2)
//   Warning       : Color(0xFFD97706)  bg: Color(0xFFFFFBEB)
//   Upload dashed : dashed border Color(0xFFE8507A), bg Color(0xFFFFF0F5)
//
// Cubit contract : VerificationCubit → VerificationState
//   (lib/features/identity_verification/presentation/bloc/)
//
// Entities       : Verification, IdType, VerificationStatus
//   (lib/features/identity_verification/domain/entities/verification.dart)
//
// Repository     : VerificationRepository (domain) → VerificationRepositoryImpl (data)
// UseCases       : UploadIdUseCase, SubmitSelfieUseCase
//
// Upload stream  : repository.uploadProgressStream → Stream<UploadProgressEvent>
//   UploadProgressEvent { String fileName, double progress, bool isDone }
//
// Navigation routes (app/router.dart):
//   /verify-id           → IdUploadPage       (step 3)
//   /selfie-capture      → SelfiePage         (camera, returns path)
//   /verification-status → VerificationStatusPage (step 4)
//
// Stepper (shared widget from auth feature):
//   StepIndicator(currentStep: 3) on IdUploadPage
//   StepIndicator(currentStep: 4) on VerificationStatusPage
//
// User userId sourced from: AuthBloc → AuthAuthenticated state → user.id
//
// After VerificationApproved:
//   Update cached User.isVerified = true via AuthBloc or SessionManager
// ─────────────────────────────────────────────────────────────────────────

import '../../domain/entities/verification.dart';

class VerificationModel extends Verification {
  const VerificationModel({
    required super.userId,
    required super.idType,
    required super.idNumber,
    super.status,
    super.idFrontPath,
    super.idBackPath,
    super.profilePhotoPath,
    super.rejectionReasons,
    super.attemptsRemaining,
    super.submittedAt,
    super.reviewedAt,
  });

  factory VerificationModel.fromJson(Map<String, dynamic> json) {
    return VerificationModel(
      userId: json['user_id'] as String,
      idType: _parseIdType(json['id_type'] as String),
      idNumber: json['id_number'] as String,
      status: _parseStatus(json['status'] as String),
      idFrontPath: json['id_front_url'] as String?,
      idBackPath: json['id_back_url'] as String?,
      profilePhotoPath: json['profile_photo_url'] as String?,
      rejectionReasons: (json['rejection_reasons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      attemptsRemaining: json['attempts_remaining'] as int? ?? 3,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'id_type': idTypeToString(idType),
      'id_number': idNumber,
      'status': _statusToString(status),
      'id_front_url': idFrontPath,
      'id_back_url': idBackPath,
      'profile_photo_url': profilePhotoPath,
      'rejection_reasons': rejectionReasons,
      'attempts_remaining': attemptsRemaining,
      'submitted_at': submittedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }

  factory VerificationModel.fromEntity(Verification v) {
    return VerificationModel(
      userId: v.userId,
      idType: v.idType,
      idNumber: v.idNumber,
      status: v.status,
      idFrontPath: v.idFrontPath,
      idBackPath: v.idBackPath,
      profilePhotoPath: v.profilePhotoPath,
      rejectionReasons: v.rejectionReasons,
      attemptsRemaining: v.attemptsRemaining,
      submittedAt: v.submittedAt,
      reviewedAt: v.reviewedAt,
    );
  }

  // ── Enum parsing helpers ──────────────────────────────────────────

  static IdType _parseIdType(String value) {
    switch (value) {
      case 'cnie':
        return IdType.cnie;
      case 'passport':
        return IdType.passport;
      case 'driving_license':
        return IdType.drivingLicense;
      default:
        return IdType.cnie;
    }
  }

  static VerificationStatus _parseStatus(String value) {
    switch (value) {
      case 'not_started':
        return VerificationStatus.notStarted;
      case 'submitted':
        return VerificationStatus.submitted;
      case 'pending':
        return VerificationStatus.pending;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.notStarted;
    }
  }

  static String idTypeToString(IdType type) {
    switch (type) {
      case IdType.cnie:
        return 'cnie';
      case IdType.passport:
        return 'passport';
      case IdType.drivingLicense:
        return 'driving_license';
    }
  }

  static String _statusToString(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.notStarted:
        return 'not_started';
      case VerificationStatus.submitted:
        return 'submitted';
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.approved:
        return 'approved';
      case VerificationStatus.rejected:
        return 'rejected';
    }
  }
}
