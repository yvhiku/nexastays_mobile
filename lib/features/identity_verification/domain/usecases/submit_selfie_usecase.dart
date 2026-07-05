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
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/verification.dart';
import '../repositories/verification_repository.dart';

class SubmitSelfieUseCase implements UseCase<Verification, SubmitSelfieParams> {
  final VerificationRepository repository;

  SubmitSelfieUseCase(this.repository);

  @override
  Future<Either<Failure, Verification>> call(SubmitSelfieParams params) async {
    if (params.profilePhotoPath.isEmpty) {
      return const Left(ValidationFailure('Profile photo is required'));
    }

    // Step 1: Upload the profile photo
    final uploadResult = await repository.uploadProfilePhoto(
      userId: params.userId,
      profilePhotoPath: params.profilePhotoPath,
    );

    return uploadResult.fold(
      (failure) => Left(failure),
      (_) async {
        // Step 2: Submit verification for review
        return await repository.submitVerification(userId: params.userId);
      },
    );
  }
}

class SubmitSelfieParams extends Equatable {
  final String userId;
  final String profilePhotoPath;

  const SubmitSelfieParams({
    required this.userId,
    required this.profilePhotoPath,
  });

  @override
  List<Object?> get props => [userId, profilePhotoPath];
}
