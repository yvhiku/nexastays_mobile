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

import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/verification.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_datasource.dart';
import '../models/verification_model.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  static const String _cachedUserKey = 'cached_user';

  final VerificationRemoteDataSource remoteDataSource;
  final LocalStorage localStorage;

  VerificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorage,
  });

  /// Host `/stays/host/verification` can be NOT_STARTED even when unified KYC
  /// (`/users/me` → [User.isVerified]) is already approved (e.g. via Nexa Pay).
  Future<VerificationModel> _mergeWithUnifiedKyc(
    String userId,
    VerificationModel remote,
  ) async {
    try {
      final raw = await localStorage.getString(_cachedUserKey);
      if (raw == null || raw.isEmpty) return remote;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final user = UserModel.fromJson(map);
      if (user.id.isNotEmpty && user.id != userId) return remote;
      if (!user.isVerified) return remote;
      return VerificationModel.fromEntity(
        remote.copyWith(status: VerificationStatus.approved),
      );
    } catch (_) {
      return remote;
    }
  }

  /// Passthrough to remote datasource upload progress.
  Stream<UploadProgressEvent> get uploadProgressStream =>
      remoteDataSource.uploadProgressStream;

  @override
  Future<Either<Failure, void>> uploadIdDocument({
    required String userId,
    required IdType idType,
    required String idNumber,
    required String idFrontPath,
    required String idBackPath,
  }) async {
    try {
      await remoteDataSource.uploadIdDocument(
        userId: userId,
        idType: VerificationModel.idTypeToString(idType),
        idNumber: idNumber,
        idFrontPath: idFrontPath,
        idBackPath: idBackPath,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network Error'));
    } on FileSystemException {
      return const Left(ServerFailure('Failed to read file'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> uploadProfilePhoto({
    required String userId,
    required String profilePhotoPath,
  }) async {
    try {
      await remoteDataSource.uploadProfilePhoto(
        userId: userId,
        profilePhotoPath: profilePhotoPath,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network Error'));
    } on FileSystemException {
      return const Left(ServerFailure('Failed to read file'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Verification>> submitVerification({
    required String userId,
  }) async {
    try {
      final result = await remoteDataSource.submitVerification(userId);

      // Cache verification status
      await localStorage.setString(
        'verification_status_$userId',
        jsonEncode(result.toJson()),
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Verification>> getVerificationStatus({
    required String userId,
  }) async {
    try {
      final result = await remoteDataSource.getVerificationStatus(userId);
      final merged = await _mergeWithUnifiedKyc(userId, result);

      // Update cache
      await localStorage.setString(
        'verification_status_$userId',
        jsonEncode(merged.toJson()),
      );

      return Right(merged);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      // On network failure, try cached data
      return _getCachedStatus(
          userId, NetworkFailure(e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Verification>> resubmitVerification({
    required String userId,
    required String idFrontPath,
    required String idBackPath,
    required String profilePhotoPath,
  }) async {
    try {
      final result = await remoteDataSource.resubmitVerification(
        userId: userId,
        idFrontPath: idFrontPath,
        idBackPath: idBackPath,
        profilePhotoPath: profilePhotoPath,
      );

      // Update cache
      await localStorage.setString(
        'verification_status_$userId',
        jsonEncode(result.toJson()),
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network Error'));
    } on FileSystemException {
      return const Left(ServerFailure('Failed to read file'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── Cache fallback ──────────────────────────────────────────────────

  Future<Either<Failure, Verification>> _getCachedStatus(
    String userId,
    Failure originalFailure,
  ) async {
    try {
      final cached =
          await localStorage.getString('verification_status_$userId');
      if (cached != null) {
        final model = VerificationModel.fromJson(jsonDecode(cached));
        final merged = await _mergeWithUnifiedKyc(userId, model);
        return Right(merged);
      }
    } catch (_) {}
    return Left(originalFailure);
  }
}
