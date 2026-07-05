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

import 'package:equatable/equatable.dart';

enum IdType { cnie, passport, drivingLicense }

enum VerificationStatus { notStarted, submitted, pending, approved, rejected }

class Verification extends Equatable {
  final String userId;
  final IdType idType;
  final String idNumber;
  final VerificationStatus status;
  final String? idFrontPath;
  final String? idBackPath;
  final String? profilePhotoPath;
  final List<String> rejectionReasons;
  final int attemptsRemaining;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  const Verification({
    required this.userId,
    required this.idType,
    required this.idNumber,
    this.status = VerificationStatus.notStarted,
    this.idFrontPath,
    this.idBackPath,
    this.profilePhotoPath,
    this.rejectionReasons = const [],
    this.attemptsRemaining = 3,
    this.submittedAt,
    this.reviewedAt,
  });

  bool get isApproved => status == VerificationStatus.approved;

  bool get canResubmit =>
      status == VerificationStatus.rejected && attemptsRemaining > 0;

  bool get allFilesUploaded =>
      idFrontPath != null &&
      idBackPath != null &&
      profilePhotoPath != null &&
      idNumber.isNotEmpty;

  Verification copyWith({
    String? userId,
    IdType? idType,
    String? idNumber,
    VerificationStatus? status,
    String? idFrontPath,
    String? idBackPath,
    String? profilePhotoPath,
    List<String>? rejectionReasons,
    int? attemptsRemaining,
    DateTime? submittedAt,
    DateTime? reviewedAt,
  }) {
    return Verification(
      userId: userId ?? this.userId,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      status: status ?? this.status,
      idFrontPath: idFrontPath ?? this.idFrontPath,
      idBackPath: idBackPath ?? this.idBackPath,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      rejectionReasons: rejectionReasons ?? this.rejectionReasons,
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        idType,
        idNumber,
        status,
        idFrontPath,
        idBackPath,
        profilePhotoPath,
        rejectionReasons,
        attemptsRemaining,
        submittedAt,
        reviewedAt,
      ];
}
