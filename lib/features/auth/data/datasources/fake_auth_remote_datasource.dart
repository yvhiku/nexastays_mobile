import 'dart:convert';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  final Map<String, UserModel> _users = {};
  final Map<String, String> _otps = {};
  String? _lastPhone;

  String _mockJwt(String sub) {
    final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': sub})));
    return 'e.$payload.e';
  }

  UserModel _createBaseUser(String phone) {
    return UserModel(
      id: 'mock_user_id_${phone.replaceAll('+', '')}',
      phone: phone,
      fullName: 'Test User',
      dateOfBirth: DateTime(1990, 1, 1),
      isMoroccan: true,
      hasPin: false,
      isVerified: false,
      isHost: false,
      onboardingStep: OnboardingStep.phoneEntry,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> _meMapFor(String phone) {
    final id = 'mock_user_id_${phone.replaceAll('+', '')}';
    final user = _users[id];
    return {
      'id': id,
      'phone_number': phone,
      'full_name': user?.fullName ?? 'Test User',
      'date_of_birth':
          (user?.dateOfBirth ?? DateTime(1990, 1, 1)).toIso8601String(),
      'nationality': user?.nationality ?? 'MA',
      'email': user?.email,
      'profile_photo_url': null,
      'kyc_status': user?.isVerified == true ? 'APPROVED' : 'PENDING',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<void> sendOtp(String phone) async {
    await Future.delayed(const Duration(seconds: 1));
    _otps[phone] = '123456';
  }

  @override
  Future<Map<String, dynamic>> verifyOtpRaw(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp != '123456' && otp != _otps[phone]) {
      throw ServerException('Invalid or expired code');
    }

    final userId = 'mock_user_id_${phone.replaceAll('+', '')}';
    _lastPhone = phone;
    if (!_users.containsKey(userId)) {
      final baseUser = _createBaseUser(phone);
      _users[userId] = UserModel(
        id: baseUser.id,
        phone: baseUser.phone,
        fullName: baseUser.fullName,
        dateOfBirth: baseUser.dateOfBirth,
        isMoroccan: baseUser.isMoroccan,
        hasPin: baseUser.hasPin,
        isVerified: baseUser.isVerified,
        isHost: baseUser.isHost,
        onboardingStep: OnboardingStep.otpVerify,
        createdAt: baseUser.createdAt,
      );
    }

    return {
      'verified': true,
      'access_token': _mockJwt(userId),
      'refresh_token': 'mock_refresh_$userId',
    };
  }

  @override
  Future<Map<String, dynamic>> selectAccount({
    required String identitySessionToken,
    required String accountId,
  }) async {
    return {
      'access_token': _mockJwt(accountId),
      'refresh_token': 'mock_refresh_$accountId',
    };
  }

  @override
  Future<Map<String, dynamic>> fetchCurrentUserMe() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final phone = _lastPhone ?? '+212000000000';
    return _meMapFor(phone);
  }

  @override
  Future<UserModel> savePersonalInfo({
    required String userId,
    required String fullName,
    required String dateOfBirth,
    required bool isMoroccan,
    String? email,
    String? city,
    String? nationality,
    String? countryOfCitizenship,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!_users.containsKey(userId)) {
      _users[userId] = UserModel(
        id: userId,
        phone: '+212000000000',
        fullName: fullName,
        dateOfBirth: DateTime.tryParse(dateOfBirth) ?? DateTime.now(),
        isMoroccan: isMoroccan,
        nationality: nationality,
        countryOfCitizenship: countryOfCitizenship,
        hasPin: false,
        isVerified: false,
        isHost: false,
        onboardingStep: OnboardingStep.personalInfo,
        createdAt: DateTime.now(),
      );
      return _users[userId]!;
    }

    final user = _users[userId]!;
    final updatedUser = UserModel(
      id: user.id,
      phone: user.phone,
      fullName: fullName,
      dateOfBirth: DateTime.tryParse(dateOfBirth) ?? user.dateOfBirth,
      isMoroccan: isMoroccan,
      nationality: nationality ?? user.nationality,
      countryOfCitizenship: countryOfCitizenship ?? user.countryOfCitizenship,
      profilePhotoUrl: user.profilePhotoUrl,
      hasPin: user.hasPin,
      isVerified: user.isVerified,
      isHost: user.isHost,
        email: email ?? user.email,
      onboardingStep: OnboardingStep.personalInfo,
      createdAt: user.createdAt,
    );

    _users[userId] = updatedUser;
    return updatedUser;
  }

  @override
  Future<void> submitKycPersonalInfo({
    required String phone,
    required String fullName,
    required String dateOfBirth,
    required String nationality,
    String? email,
    String? city,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _lastPhone = phone;
    final userId = 'mock_user_id_${phone.replaceAll('+', '')}';
    final existing = _users[userId] ?? _createBaseUser(phone);
    _users[userId] = UserModel(
      id: existing.id,
      phone: phone,
      fullName: fullName,
      dateOfBirth: DateTime.tryParse(dateOfBirth) ?? existing.dateOfBirth,
      isMoroccan: nationality == 'MA',
      nationality: nationality,
      countryOfCitizenship: nationality == 'MA' ? null : nationality,
      profilePhotoUrl: existing.profilePhotoUrl,
      hasPin: true,
      isVerified: false,
      isHost: existing.isHost,
      email: email,
      onboardingStep: OnboardingStep.personalInfo,
      createdAt: existing.createdAt,
    );
  }

  @override
  Future<String> createSumsubAccessToken() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'mock_sumsub_token';
  }

  @override
  Future<String?> syncSumsubStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final phone = _lastPhone ?? '+212000000000';
    final userId = 'mock_user_id_${phone.replaceAll('+', '')}';
    final user = _users[userId] ?? _createBaseUser(phone);
    _users[userId] = UserModel(
      id: user.id,
      phone: user.phone,
      fullName: user.fullName,
      dateOfBirth: user.dateOfBirth,
      isMoroccan: user.isMoroccan,
      nationality: user.nationality,
      countryOfCitizenship: user.countryOfCitizenship,
      profilePhotoUrl: user.profilePhotoUrl,
      hasPin: true,
      isVerified: true,
      isHost: user.isHost,
      email: user.email,
      onboardingStep: OnboardingStep.complete,
      createdAt: user.createdAt,
    );
    return 'APPROVED';
  }

  @override
  Future<void> createPin(String userId, String pin) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!_users.containsKey(userId)) return;

    final user = _users[userId]!;
    _users[userId] = UserModel(
      id: user.id,
      phone: user.phone,
      fullName: user.fullName,
      dateOfBirth: user.dateOfBirth,
      isMoroccan: user.isMoroccan,
      nationality: user.nationality,
      countryOfCitizenship: user.countryOfCitizenship,
      profilePhotoUrl: user.profilePhotoUrl,
      hasPin: true,
      isVerified: user.isVerified,
      isHost: user.isHost,
      email: user.email,
      onboardingStep: OnboardingStep.pinSetup,
      createdAt: user.createdAt,
    );
  }

  @override
  Future<void> confirmPin(String userId, String pin) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> setPinWithOtpSession({
    required String otpSessionToken,
    required String pin,
  }) async {
    await createPin('mock', pin);
  }

  @override
  Future<Map<String, dynamic>> completeRegistration(
    String otpSessionToken,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final phone = _lastPhone ?? '+212000000000';
    final userId = 'mock_user_id_${phone.replaceAll('+', '')}';
    return {
      'access_token': _mockJwt(userId),
      'refresh_token': 'mock_refresh_$userId',
      'user_id': userId,
    };
  }

  @override
  Future<Map<String, dynamic>> loginWithPinRaw(String phone, String pin) async {
    await Future.delayed(const Duration(seconds: 1));
    _lastPhone = phone;
    final userId = 'mock_user_id_${phone.replaceAll('+', '')}';

    if (!_users.containsKey(userId)) {
      _users[userId] = UserModel(
        id: userId,
        phone: phone,
        fullName: 'Test User',
        dateOfBirth: DateTime(1990, 1, 1),
        isMoroccan: true,
        hasPin: true,
        isVerified: true,
        isHost: false,
        onboardingStep: OnboardingStep.complete,
        createdAt: DateTime.now(),
      );
    }

    return {
      'verified': true,
      'access_token': _mockJwt(userId),
      'refresh_token': 'mock_refresh_$userId',
      'user_id': userId,
    };
  }

  @override
  Future<void> resendOtp(String phone) async {
    await sendOtp(phone);
  }

  @override
  Future<void> logout(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
