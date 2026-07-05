// Mock Verification Repository — returns fake data for offline development.
// TODO: Switch back to VerificationRepositoryImpl when backend is ready.

import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/verification.dart';
import '../../domain/repositories/verification_repository.dart';

class MockVerificationRepository implements VerificationRepository {
  final StreamController<UploadProgressEvent> _progressController =
      StreamController<UploadProgressEvent>.broadcast();

  @override
  Stream<UploadProgressEvent> get uploadProgressStream =>
      _progressController.stream;

  @override
  Future<Either<Failure, void>> uploadIdDocument({
    required String userId,
    required IdType idType,
    required String idNumber,
    required String idFrontPath,
    required String idBackPath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> uploadProfilePhoto({
    required String userId,
    required String profilePhotoPath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(null);
  }

  @override
  Future<Either<Failure, Verification>> submitVerification({
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Right(Verification(
      userId: userId,
      idType: IdType.cnie,
      idNumber: 'MOCK12345',
      status: VerificationStatus.submitted,
      submittedAt: DateTime.now(),
    ));
  }

  @override
  Future<Either<Failure, Verification>> getVerificationStatus({
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Right(Verification(
      userId: userId,
      idType: IdType.cnie,
      idNumber: 'AB123456',
      status: VerificationStatus.approved,
      submittedAt: DateTime(2025, 1, 15),
      reviewedAt: DateTime(2025, 1, 16),
    ));
  }

  @override
  Future<Either<Failure, Verification>> resubmitVerification({
    required String userId,
    required String idFrontPath,
    required String idBackPath,
    required String profilePhotoPath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(Verification(
      userId: userId,
      idType: IdType.cnie,
      idNumber: 'MOCK12345',
      status: VerificationStatus.submitted,
      submittedAt: DateTime.now(),
    ));
  }
}
