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

import '../../domain/entities/verification.dart';

enum UploadFileStatus { queued, uploading, done }

abstract class VerificationState extends Equatable {
  const VerificationState();

  @override
  List<Object?> get props => [];
}

class VerificationInitial extends VerificationState {
  const VerificationInitial();
}

class VerificationLoading extends VerificationState {
  const VerificationLoading();
}

class VerificationFormReady extends VerificationState {
  final IdType selectedIdType;
  final String idNumber;
  final String? idFrontPath;
  final String? idBackPath;
  final String? profilePhotoPath;

  const VerificationFormReady({
    required this.selectedIdType,
    this.idNumber = '',
    this.idFrontPath,
    this.idBackPath,
    this.profilePhotoPath,
  });

  bool get allFilesReady =>
      idFrontPath != null &&
      idBackPath != null &&
      profilePhotoPath != null &&
      idNumber.isNotEmpty;

  @override
  List<Object?> get props => [
        selectedIdType,
        idNumber,
        idFrontPath,
        idBackPath,
        profilePhotoPath,
      ];
}

class VerificationUploading extends VerificationState {
  final UploadFileStatus idFront;
  final UploadFileStatus idBack;
  final UploadFileStatus profilePhoto;
  final UploadFileStatus encrypting;
  final double profilePhotoProgress;

  const VerificationUploading({
    this.idFront = UploadFileStatus.queued,
    this.idBack = UploadFileStatus.queued,
    this.profilePhoto = UploadFileStatus.queued,
    this.encrypting = UploadFileStatus.queued,
    this.profilePhotoProgress = 0.0,
  });

  @override
  List<Object?> get props => [
        idFront,
        idBack,
        profilePhoto,
        encrypting,
        profilePhotoProgress,
      ];
}

class VerificationSubmitted extends VerificationState {
  const VerificationSubmitted();
}

class VerificationApproved extends VerificationState {
  final Verification verification;

  const VerificationApproved({required this.verification});

  @override
  List<Object?> get props => [verification];
}

class VerificationRejected extends VerificationState {
  final List<String> reasons;
  final int attemptsRemaining;

  const VerificationRejected({
    required this.reasons,
    required this.attemptsRemaining,
  });

  @override
  List<Object?> get props => [reasons, attemptsRemaining];
}

class VerificationError extends VerificationState {
  final String message;

  const VerificationError({required this.message});

  @override
  List<Object?> get props => [message];
}
