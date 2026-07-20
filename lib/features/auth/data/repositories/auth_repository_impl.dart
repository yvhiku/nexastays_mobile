import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_idensic_mobile_sdk_plugin/flutter_idensic_mobile_sdk_plugin.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/jwt_sub.dart';
import '../../../../core/utils/phone_normalizer.dart';
import '../../../../services/push_registration_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;
  final LocalStorage localStorage;
  final SessionManager sessionManager;
  final PushRegistrationService? pushRegistration;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.localStorage,
    required this.sessionManager,
    this.pushRegistration,
  });

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'cached_user';
  static const String _pinKey = 'has_pin_';
  static const String _phoneKey = 'nexastays_phone_number';
  static const String _otpSessionKey = 'nexastays_otp_session_token';

  Future<String> _requireStoredPhone() async {
    final phone = await secureStorage.read(_phoneKey);
    if (phone == null || phone.isEmpty) {
      throw ServerException('Phone number not found. Please verify again.');
    }
    final normalized = normalizeMoroccoPhone(phone);
    if (normalized != phone) {
      await secureStorage.write(_phoneKey, normalized);
    }
    return normalized;
  }

  Failure _mapException(dynamic e) {
    if (e is ServerException) {
      if (e.message == 'Wrong PIN. Try again.' ||
          e.message == 'Account locked. Contact support.') {
        return ValidationFailure(e.message);
      }
      return ServerFailure(e.message);
    }
    if (e is DioException) {
      return NetworkFailure();
    }
    if (e.runtimeType.toString() == 'CacheException') {
      return CacheFailure(e.toString());
    }
    return ServerFailure('Something went wrong');
  }

  Future<UserModel> _hydrateUserAfterTokenSave({
    required String accessToken,
    required String refreshToken,
    required String phoneFallback,
  }) async {
    final userId = decodeJwtSub(accessToken);
    if (userId == null || userId.isEmpty) {
      throw ServerException('Invalid access token');
    }
    await sessionManager.saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
    );
    final me = await remoteDataSource.fetchCurrentUserMe();
    final userModel = UserModel.fromUsersMe(me, phoneFallback: phoneFallback);
    await localStorage.setString(_userKey, jsonEncode(userModel.toJson()));
    unawaited(pushRegistration?.registerIfAuthenticated());
    return userModel;
  }

  @override
  Future<Either<Failure, void>> sendOtp(String phone) async {
    try {
      await remoteDataSource.sendOtp(normalizeMoroccoPhone(phone));
      return const Right(null);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final normalizedPhone = normalizeMoroccoPhone(phone);
      var raw = await remoteDataSource.verifyOtpRaw(normalizedPhone, otp);
      if (raw['verified'] != true) {
        throw ServerException('Invalid or expired code');
      }
      await secureStorage.write(_phoneKey, normalizedPhone);

      String? access = raw['access_token'] as String?;
      String? refresh = raw['refresh_token'] as String?;

      if (access == null || refresh == null) {
        final otpSession = raw['otp_session_token'] as String? ??
            raw['identity_session_token'] as String?;
        final accounts = raw['accounts'] as List<dynamic>?;

        if (otpSession != null &&
            accounts != null &&
            accounts.isNotEmpty) {
          String? selectedAccountId;
          for (final a in accounts) {
            if (a is! Map) continue;
            final m = Map<String, dynamic>.from(a);
            final type = (m['account_type'] ?? '').toString().toUpperCase();
            if (type == 'CONSUMER') {
              selectedAccountId = m['id']?.toString();
              break;
            }
          }
          if (selectedAccountId == null && accounts.length == 1) {
            final only = accounts.first;
            if (only is Map) {
              selectedAccountId =
                  Map<String, dynamic>.from(only)['id']?.toString();
            }
          }
          if (selectedAccountId != null) {
            final sel = await remoteDataSource.selectAccount(
              identitySessionToken: otpSession,
              accountId: selectedAccountId,
            );
            access = sel['access_token'] as String?;
            refresh = sel['refresh_token'] as String?;
          }
        } else if (otpSession != null && otpSession.isNotEmpty) {
          await secureStorage.write(_otpSessionKey, otpSession);
          final pendingId =
              (raw['user_id'] as String?) ?? 'pending_$normalizedPhone';
          final userModel = UserModel(
            id: pendingId,
            phone: normalizedPhone,
            fullName: '',
            dateOfBirth: DateTime(2000, 1, 1),
            isMoroccan: true,
            hasPin: false,
            isVerified: false,
            isHost: false,
            onboardingStep: OnboardingStep.personalInfo,
            createdAt: DateTime.now(),
          );
          await localStorage.setString(
            _userKey,
            jsonEncode(userModel.toJson()),
          );
          return Right(userModel);
        }
      }

      if (access == null || refresh == null) {
        throw ServerException(
          'Sign-in could not be completed for this number. Try again or contact support.',
        );
      }

      final userModel = await _hydrateUserAfterTokenSave(
        accessToken: access,
        refreshToken: refresh,
        phoneFallback: normalizedPhone,
      );
      return Right(userModel);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, User>> savePersonalInfo({
    required String userId,
    required String fullName,
    required DateTime dateOfBirth,
    required bool isMoroccan,
    String? email,
    String? city,
    String? nationality,
    String? countryOfCitizenship,
  }) async {
    try {
      final userModel = await remoteDataSource.savePersonalInfo(
        userId: userId,
        fullName: fullName,
        dateOfBirth: dateOfBirth.toIso8601String().split('T').first,
        isMoroccan: isMoroccan,
        email: email,
        city: city,
        nationality: nationality,
        countryOfCitizenship: countryOfCitizenship,
      );

      await localStorage.setString(_userKey, jsonEncode(userModel.toJson()));

      return Right(userModel);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> createPin({
    required String userId,
    required String pin,
  }) async {
    try {
      final otpSession = await secureStorage.read(_otpSessionKey);
      if (otpSession == null || otpSession.isEmpty) {
        throw ServerException(
          'Session expired. Please verify your phone again.',
        );
      }
      await remoteDataSource.setPinWithOtpSession(
        otpSessionToken: otpSession,
        pin: pin,
      );
      await secureStorage.write('$_pinKey$userId', 'true');
      return const Right(null);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> submitKycPersonalInfo({
    required String fullName,
    required DateTime dateOfBirth,
    required bool isMoroccan,
    String? email,
    String? city,
    String? nationality,
  }) async {
    try {
      final phone = await _requireStoredPhone();
      await remoteDataSource.submitKycPersonalInfo(
        phone: phone,
        fullName: fullName,
        dateOfBirth: dateOfBirth.toIso8601String().split('T').first,
        nationality: nationality ?? (isMoroccan ? 'MA' : 'OTHER'),
        email: email,
        city: city,
      );
      return const Right(null);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> launchSumsubVerification() async {
    try {
      final accessToken = await remoteDataSource.createSumsubAccessToken();
      final sdk = SNSMobileSDK.init(
        accessToken,
        () => remoteDataSource.createSumsubAccessToken(),
      ).build();

      final result = await sdk.launch();
      if (!result.success) {
        throw ServerException(
          result.errorMsg ?? 'Verification was not completed.',
        );
      }

      final status = await remoteDataSource.syncSumsubStatus();
      final approved = status == 'APPROVED' || status == 'VERIFIED';

      if (approved) {
        final otpSession = await secureStorage.read(_otpSessionKey);
        if (otpSession != null && otpSession.isNotEmpty) {
          final reg = await remoteDataSource.completeRegistration(otpSession);
          final access = reg['access_token'] as String?;
          final refresh = reg['refresh_token'] as String?;
          if (access != null && refresh != null) {
            final phone = await secureStorage.read(_phoneKey) ?? '';
            await _hydrateUserAfterTokenSave(
              accessToken: access,
              refreshToken: refresh,
              phoneFallback: phone,
            );
            await secureStorage.delete(_otpSessionKey);
          }
        }
      }

      return Right(approved);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, User>> refreshCurrentUser() async {
    try {
      final phone = await secureStorage.read(_phoneKey) ?? '';
      final me = await remoteDataSource.fetchCurrentUserMe();
      final userModel = UserModel.fromUsersMe(me, phoneFallback: phone);
      await localStorage.setString(_userKey, jsonEncode(userModel.toJson()));
      return Right(userModel);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> confirmPin({
    required String userId,
    required String pin,
  }) async {
    // Validated client-side; backend uses single-step POST /auth/pin/set.
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> loginWithPin({
    required String phone,
    required String pin,
  }) async {
    try {
      final normalizedPhone = normalizeMoroccoPhone(phone);
      await secureStorage.write(_phoneKey, normalizedPhone);
      final raw = await remoteDataSource.loginWithPinRaw(normalizedPhone, pin);
      final access = raw['access_token'] as String?;
      final refresh = raw['refresh_token'] as String?;
      if (access == null || refresh == null) {
        throw ServerException('Login failed');
      }
      final userModel = await _hydrateUserAfterTokenSave(
        accessToken: access,
        refreshToken: refresh,
        phoneFallback: normalizedPhone,
      );
      return Right(userModel);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp(String phone) async {
    try {
      await remoteDataSource.resendOtp(normalizeMoroccoPhone(phone));
      return const Right(null);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, User?>> getCachedUser() async {
    try {
      final raw = await localStorage.getString(_userKey);
      if (raw == null) return const Right(null);

      final map = jsonDecode(raw) as Map<String, dynamic>;
      final userModel = UserModel.fromJson(map);

      return Right(userModel);
    } catch (_) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Capture before clearing (used for best-effort revoke on server).
    final userId = sessionManager.userId;

    unawaited(pushRegistration?.deactivateOnLogout());

    // Always clear local/session first so logout completes quickly and the UI
    // can transition even if the API is slow or unreachable (hung POST was
    // preventing AuthBloc from emitting AuthUnauthenticated).
    try {
      await secureStorage.delete(_tokenKey);
      await localStorage.remove(_userKey);
      try {
        sessionManager.clearSession();
      } catch (_) {
        /* best effort */
      }
    } catch (_) {
      /* ignore */
    }

    if (userId != null && userId.isNotEmpty) {
      unawaited(
        remoteDataSource.logout(userId).catchError((_) {}),
      );
    }
    return const Right(null);
  }
}
