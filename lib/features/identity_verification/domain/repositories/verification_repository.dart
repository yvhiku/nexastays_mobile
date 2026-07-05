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

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/verification.dart';
import '../../data/datasources/verification_remote_datasource.dart'
    show UploadProgressEvent;

export '../../data/datasources/verification_remote_datasource.dart'
    show UploadProgressEvent;

abstract class VerificationRepository {
  Future<Either<Failure, void>> uploadIdDocument({
    required String userId,
    required IdType idType,
    required String idNumber,
    required String idFrontPath,
    required String idBackPath,
  });

  Future<Either<Failure, void>> uploadProfilePhoto({
    required String userId,
    required String profilePhotoPath,
  });

  Future<Either<Failure, Verification>> submitVerification({
    required String userId,
  });

  Future<Either<Failure, Verification>> getVerificationStatus({
    required String userId,
  });

  Future<Either<Failure, Verification>> resubmitVerification({
    required String userId,
    required String idFrontPath,
    required String idBackPath,
    required String profilePhotoPath,
  });

  Stream<UploadProgressEvent> get uploadProgressStream;
}
