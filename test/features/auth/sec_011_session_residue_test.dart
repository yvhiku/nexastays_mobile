import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexa_stays_f/core/session/session_manager.dart';
import 'package:nexa_stays_f/core/storage/local_storage.dart';
import 'package:nexa_stays_f/core/storage/secure_storage.dart';
import 'package:nexa_stays_f/core/utils/phone_normalizer.dart';
import 'package:nexa_stays_f/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:nexa_stays_f/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nexa_stays_f/features/auth/domain/entities/user.dart';
import 'package:nexa_stays_f/features/auth/domain/usecases/create_pin_usecase.dart';
import 'package:nexa_stays_f/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nexa_stays_f/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:nexa_stays_f/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:nexa_stays_f/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexa_stays_f/features/auth/presentation/bloc/auth_state.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource {}

String _fakeJwt({required String sub}) {
  String b64(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${b64({'alg': 'none'})}.${b64({'sub': sub})}.sig';
}

void main() {
  late Map<String, String> secureStore;
  late SecureStorageService secureStorage;
  late SessionManager sessionManager;
  late LocalStorage localStorage;
  late _MockRemote remote;
  late AuthRepositoryImpl repo;

  final phone = normalizeMoroccoPhone('0612345678');
  const binder = 'otp-binder-jwt';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LocalStorage.debugResetForTest();
    secureStore = <String, String>{};
    secureStorage = SecureStorageService.forTesting(secureStore);
    sessionManager = SessionManager(storage: secureStorage);
    localStorage = LocalStorage();
    remote = _MockRemote();
    repo = AuthRepositoryImpl(
      remoteDataSource: remote,
      secureStorage: secureStorage,
      localStorage: localStorage,
      sessionManager: sessionManager,
    );
  });

  Future<User> seedNewUserPendingRegistration() async {
    when(() => remote.verifyOtpRaw(any(), any())).thenAnswer(
      (_) async => {
        'verified': true,
        'otp_session_token': binder,
        'user_id': 'pending_$phone',
      },
    );
    final result = await repo.verifyOtp(phone: phone, otp: '123456');
    return result.getOrElse(() => throw StateError('verifyOtp failed'));
  }

  group('SEC-011 session residue', () {
    test('TEST 1 — new-user OTP verify stores binder + phone + cached user',
        () async {
      final user = await seedNewUserPendingRegistration();

      expect(user.id, 'pending_$phone');
      expect(await secureStorage.read(SecureStorageKeys.otpSessionToken), binder);
      expect(await secureStorage.read(SecureStorageKeys.phoneNumber), phone);
      expect(await localStorage.getString('cached_user'), isNotNull);
      expect(await secureStorage.getAccessToken(), isNull);
    });

    test('TEST 2 — logout clears session + registration secrets; keeps device id',
        () async {
      await seedNewUserPendingRegistration();
      await secureStorage.write(SecureStorageKeys.deviceId, 'device-abc');
      await sessionManager.saveSession(
        accessToken: _fakeJwt(sub: 'user-1'),
        refreshToken: 'refresh-1',
        userId: 'user-1',
      );
      await secureStorage.write('has_pin_user-1', 'true');

      when(() => remote.logout(any())).thenAnswer((_) async {});

      final out = await repo.logout();
      expect(out.isRight(), isTrue);

      expect(await secureStorage.getAccessToken(), isNull);
      expect(await secureStorage.getRefreshToken(), isNull);
      expect(await secureStorage.getUserId(), isNull);
      expect(await localStorage.getString('cached_user'), isNull);
      expect(
        await secureStorage.read(SecureStorageKeys.otpSessionToken),
        isNull,
      );
      expect(await secureStorage.read(SecureStorageKeys.phoneNumber), isNull);
      expect(await secureStorage.read(SecureStorageKeys.deviceId), 'device-abc');
      expect(await secureStorage.read('has_pin_user-1'), isNull);
      expect(sessionManager.accessToken, isNull);
    });

    test('TEST 3 — binder survives mid-KYC then deletes on logout', () async {
      await seedNewUserPendingRegistration();
      expect(await secureStorage.read(SecureStorageKeys.otpSessionToken), binder);

      // Active KYC / registration still holds binder (no premature wipe).
      expect(await secureStorage.read(SecureStorageKeys.phoneNumber), phone);

      when(() => remote.logout(any())).thenAnswer((_) async {});
      await repo.logout();

      expect(
        await secureStorage.read(SecureStorageKeys.otpSessionToken),
        isNull,
      );
      expect(await secureStorage.read(SecureStorageKeys.phoneNumber), isNull);
    });

    test('TEST 4 — successful registration deletes OTP binder', () async {
      await seedNewUserPendingRegistration();
      final access = _fakeJwt(sub: 'consumer-1');
      when(() => remote.completeRegistration(binder)).thenAnswer(
        (_) async => {
          'access_token': access,
          'refresh_token': 'refresh-reg',
        },
      );
      when(() => remote.fetchCurrentUserMe()).thenAnswer(
        (_) async => {
          'id': 'consumer-1',
          'phone_number': phone,
          'full_name': 'Test User',
          'kyc_status': 'APPROVED',
        },
      );

      final out = await repo.finalizeRegistrationAfterKycApprovalForTest();
      expect(out.isRight(), isTrue);
      expect(await secureStorage.getAccessToken(), access);
      expect(await secureStorage.getRefreshToken(), 'refresh-reg');
      expect(
        await secureStorage.read(SecureStorageKeys.otpSessionToken),
        isNull,
      );
      // Phone may remain for post-registration hydration / profile fallback.
      expect(await secureStorage.read(SecureStorageKeys.phoneNumber), phone);
    });

    test('TEST 5 — createPin deletes client OTP binder after success', () async {
      await seedNewUserPendingRegistration();
      when(
        () => remote.setPinWithOtpSession(
          otpSessionToken: binder,
          pin: '2468',
        ),
      ).thenAnswer((_) async {});

      final out = await repo.createPin(userId: 'pending_$phone', pin: '2468');
      expect(out.isRight(), isTrue);
      expect(
        await secureStorage.read(SecureStorageKeys.otpSessionToken),
        isNull,
      );
      expect(await secureStorage.read('has_pin_pending_$phone'), 'true');
    });

    test('TEST 6 — restart after logout does not restore AuthOtpVerified',
        () async {
      await seedNewUserPendingRegistration();
      when(() => remote.logout(any())).thenAnswer((_) async {});
      await repo.logout();

      final cached = await repo.getCachedUser();
      expect(cached.getOrElse(() => throw StateError('x')), isNull);

      final bloc = AuthBloc(
        sendOtpUseCase: SendOtpUseCase(repo),
        loginWithPinUseCase: LoginWithPinUseCase(repo),
        verifyOtpUseCase: VerifyOtpUseCase(repo),
        savePersonalInfoUseCase: SavePersonalInfoUseCase(repo),
        completeKycUseCase: CompleteKycUseCase(repo),
        createPinUseCase: CreatePinUseCase(repo),
        logoutUseCase: LogoutUseCase(repo),
        authRepository: repo,
      );

      await expectLater(
        bloc.stream,
        emitsThrough(isA<AuthUnauthenticated>()),
      );
      expect(bloc.state, isA<AuthUnauthenticated>());
      await bloc.close();
    });

    test('TEST 7 — clearTokens stays narrow; full logout clears registration',
        () async {
      await secureStorage.write(SecureStorageKeys.otpSessionToken, binder);
      await secureStorage.write(SecureStorageKeys.phoneNumber, phone);
      await secureStorage.saveAccessToken('access');
      await secureStorage.saveRefreshToken('refresh');
      await secureStorage.saveUserId('u1');

      await secureStorage.clearTokens();
      expect(await secureStorage.getAccessToken(), isNull);
      expect(await secureStorage.getRefreshToken(), isNull);
      expect(await secureStorage.getUserId(), isNull);
      expect(await secureStorage.read(SecureStorageKeys.otpSessionToken), binder);
      expect(await secureStorage.read(SecureStorageKeys.phoneNumber), phone);

      await secureStorage.clearRegistrationSecrets();
      expect(
        await secureStorage.read(SecureStorageKeys.otpSessionToken),
        isNull,
      );
      expect(await secureStorage.read(SecureStorageKeys.phoneNumber), isNull);
    });

    test('new OTP send clears prior registration secrets', () async {
      await seedNewUserPendingRegistration();
      when(() => remote.sendOtp(any())).thenAnswer((_) async {});

      await repo.sendOtp('+212698765432');
      expect(
        await secureStorage.read(SecureStorageKeys.otpSessionToken),
        isNull,
      );
      expect(await secureStorage.read(SecureStorageKeys.phoneNumber), isNull);
    });
  });
}
