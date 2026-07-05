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

class UploadIdUseCase implements UseCase<void, UploadIdParams> {
  final VerificationRepository repository;

  UploadIdUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UploadIdParams params) async {
    // if (params.idNumber.isEmpty) {
    //   return const Left(ValidationFailure('ID number is required'));
    // }
    // if (params.idNumber.length < 5) {
    //   return const Left(
    //       ValidationFailure('ID number must be at least 5 characters'));
    // }
    if (params.idFrontPath.isEmpty) {
      return const Left(ValidationFailure('Front of ID document is required'));
    }
    if (params.idBackPath.isEmpty) {
      return const Left(ValidationFailure('Back of ID document is required'));
    }

    return await repository.uploadIdDocument(
      userId: params.userId,
      idType: params.idType,
      idNumber: params.idNumber,
      idFrontPath: params.idFrontPath,
      idBackPath: params.idBackPath,
    );
  }
}

class UploadIdParams extends Equatable {
  final String userId;
  final IdType idType;
  final String idNumber;
  final String idFrontPath;
  final String idBackPath;

  const UploadIdParams({
    required this.userId,
    required this.idType,
    required this.idNumber,
    required this.idFrontPath,
    required this.idBackPath,
  });

  @override
  List<Object?> get props =>
      [userId, idType, idNumber, idFrontPath, idBackPath];
}
