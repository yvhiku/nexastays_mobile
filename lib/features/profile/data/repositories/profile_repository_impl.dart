import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

// =============================================================================
// Profile Repository Implementation
// =============================================================================

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorage,
    required this.sessionManager,
    required this.secureStorage,
  });

  final ProfileRemoteDataSource remoteDataSource;
  final LocalStorage localStorage;
  final SessionManager sessionManager;
  final SecureStorageService secureStorage;

  static const _profilePrefix = 'cached_profile_';

  // ── Helpers ──────────────────────────────────────────────────────────

  Future<void> _cacheProfile(String userId, UserModel model) async {
    await localStorage.setString(
      '$_profilePrefix$userId',
      jsonEncode(model.toJson()),
    );
  }

  Future<UserModel?> _readCachedProfile(String userId) async {
    final raw = await localStorage.getString('$_profilePrefix$userId');
    if (raw == null || raw.isEmpty) return null;
    return UserModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  // ── Get profile ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, User>> getProfile(String userId) async {
    try {
      final model = await remoteDataSource.getProfile(userId);
      await _cacheProfile(userId, model);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      // Fallback to cache on network failure.
      final cached = await _readCachedProfile(userId);
      if (cached != null) return Right(cached);
      return const Left(NetworkFailure());
    }
  }

  // ── Update profile ───────────────────────────────────────────────────

  @override
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    bool identityLocked = false,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? profilePhotoPath,
  }) async {
    try {
      final model = await remoteDataSource.updateProfile(
        userId: userId,
        identityLocked: identityLocked,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        profilePhotoPath: profilePhotoPath,
      );

      // Update cache.
      await _cacheProfile(userId, model);

      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }

  // ── Change password ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      if (e.message.contains('incorrect_password') ||
          e.message.toLowerCase().contains('incorrect password')) {
        return const Left(
          ValidationFailure('Current password is incorrect'),
        );
      }
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }

  // ── Delete account ───────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> deleteAccount(String userId) async {
    try {
      await remoteDataSource.deleteAccount(userId);

      // Full local wipe after confirmed server-side delete.
      await localStorage.clear();
      await sessionManager.clearSession();
      await secureStorage.clearAll();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }

  // ── Notification preferences ─────────────────────────────────────────

  @override
  Future<Either<Failure, void>> updateNotificationPreferences({
    required String userId,
    required Map<String, bool> preferences,
  }) async {
    try {
      await remoteDataSource.updateNotificationPreferences(
        userId: userId,
        preferences: preferences,
      );

      // Update cached profile with new preferences if available.
      final cached = await _readCachedProfile(userId);
      if (cached != null) {
        await _cacheProfile(userId, cached);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }

  // ── Language preference ──────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> updateLanguagePreference({
    required String userId,
    required String languageCode,
  }) async {
    try {
      await remoteDataSource.updateLanguagePreference(
        userId: userId,
        languageCode: languageCode,
      );

      // Persist language locally for immediate use.
      await localStorage.setString('user_language', languageCode);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }

  // ── Cached profile ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, User>> getCachedProfile(String userId) async {
    final cached = await _readCachedProfile(userId);
    if (cached != null) return Right(cached);
    return const Left(CacheFailure('No cached profile'));
  }
}
