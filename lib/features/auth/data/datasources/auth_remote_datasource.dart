import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// ISO-3166 alpha-2 for KYC document issuing country (defaults from nationality).
String _documentCountryCode(String nationality) {
  final code = nationality.trim().toUpperCase();
  if (code != 'OTHER' && RegExp(r'^[A-Z]{2}$').hasMatch(code)) {
    return code;
  }
  return code;
}

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phone);

  /// Backend: [POST /auth/otp/verify] — returns tokens and/or identity session (not [verify-otp]).
  Future<Map<String, dynamic>> verifyOtpRaw(String phone, String otp);

  /// When OTP returns multiple accounts, exchange identity session for JWT.
  Future<Map<String, dynamic>> selectAccount({
    required String identitySessionToken,
    required String accountId,
  });

  /// [GET /users/me] — requires Bearer access token.
  Future<Map<String, dynamic>> fetchCurrentUserMe();

  Future<UserModel> savePersonalInfo({
    required String userId,
    required String fullName,
    required String dateOfBirth,
    required bool isMoroccan,
    String? email,
    String? city,
    String? nationality,
    String? countryOfCitizenship,
  });

  Future<void> submitKycPersonalInfo({
    required String phone,
    required String fullName,
    required String dateOfBirth,
    required String nationality,
    String? email,
    String? city,
  });

  Future<String> createSumsubAccessToken();

  Future<String?> syncSumsubStatus();

  Future<void> createPin(String userId, String pin);
  Future<void> confirmPin(String userId, String pin);

  /// [POST /auth/pin/set] — new users after OTP (requires otp session token).
  Future<void> setPinWithOtpSession({
    required String otpSessionToken,
    required String pin,
  });

  /// [POST /auth/registration/complete] — exchange otp session for JWT after KYC.
  Future<Map<String, dynamic>> completeRegistration(String otpSessionToken);

  /// [POST /auth/pin/verify] — flat body, not wrapped in `data`.
  Future<Map<String, dynamic>> loginWithPinRaw(String phone, String pin);

  Future<void> resendOtp(String phone);
  Future<void> logout(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  String _getErrorMessage(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          final m = data['message'];
          if (m is String) return m;
          if (m is List && m.isNotEmpty) return m.first.toString();
        }
        if (data.containsKey('error')) return data['error'].toString();
      }
    }
    return 'An unexpected error occurred';
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> raw) {
    final inner = raw['data'];
    if (inner is Map<String, dynamic>) return inner;
    return raw;
  }

  @override
  Future<void> sendOtp(String phone) async {
    try {
      await dio.post(
        ApiEndpoints.sendOtp,
        data: {'phone_number': phone},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw ServerException('Too many requests. Please wait.');
      }
      throw ServerException(_getErrorMessage(e));
    } catch (e) {
      throw ServerException('Failed to send OTP');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtpRaw(String phone, String otp) async {
    try {
      final response = await dio.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone_number': phone,
          'otp': otp,
        },
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerException('Invalid response from server');
      }
      return _unwrap(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final msg = _getErrorMessage(e);
        if (msg.contains('Too many') || msg.contains('Try again')) {
          throw ServerException(msg);
        }
        throw ServerException(
          msg == 'An unexpected error occurred'
              ? 'Invalid or expired code'
              : msg,
        );
      }
      if (e.response?.statusCode == 429) {
        throw ServerException('Too many attempts. Please wait.');
      }
      throw ServerException(_getErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> selectAccount({
    required String identitySessionToken,
    required String accountId,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.accountSelect,
        data: {
          'identity_session_token': identitySessionToken,
          'account_id': accountId,
        },
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerException('Invalid response from server');
      }
      return _unwrap(data);
    } on DioException catch (e) {
      throw ServerException(_getErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> fetchCurrentUserMe() async {
    try {
      final response = await dio.get(ApiEndpoints.usersMe);
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerException('Invalid user profile response');
      }
      return _unwrap(data);
    } on DioException catch (e) {
      throw ServerException(_getErrorMessage(e));
    }
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
    try {
      final data = <String, dynamic>{
        'user_id': userId,
        'full_name': fullName,
        'date_of_birth': dateOfBirth,
        'is_moroccan': isMoroccan,
      };

      if (nationality != null) {
        data['nationality'] = nationality;
      }
      if (countryOfCitizenship != null) {
        data['country_of_citizenship'] = countryOfCitizenship;
      }
      if (email != null && email.trim().isNotEmpty) {
        data['email'] = email.trim();
      }
      if (city != null && city.trim().isNotEmpty) {
        data['city'] = city.trim();
      }

      final response = await dio.post(
        ApiEndpoints.personalInfo,
        data: data,
      );
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final inner = body['data'];
        if (inner is Map<String, dynamic>) {
          return UserModel.fromJson(inner);
        }
      }
      throw ServerException('Unexpected personal-info response');
    } on DioException catch (e) {
      throw ServerException(_getErrorMessage(e));
    } catch (e) {
      throw ServerException('Failed to save personal info');
    }
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
    try {
      await dio.post(
        ApiEndpoints.kycSubmit,
        data: {
          'phone_number': phone,
          'documents': {
            'id_document': true,
            'selfie': true,
            'liveness': true,
          },
          'full_name': fullName.trim(),
          'date_of_birth': dateOfBirth,
          'nationality': nationality,
          'document_country': _documentCountryCode(nationality),
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
          'source': 'STAYS',
        },
      );
    } on DioException catch (e) {
      throw ServerException(_getErrorMessage(e));
    } catch (_) {
      throw ServerException('Failed to save KYC profile');
    }
  }

  @override
  Future<String> createSumsubAccessToken() async {
    try {
      final response = await dio.post(
        ApiEndpoints.kycSumsubToken,
        data: {'source': 'STAYS'},
      );
      final body = response.data;
      final data = body is Map<String, dynamic>
          ? (body['data'] is Map<String, dynamic>
              ? body['data'] as Map<String, dynamic>
              : body)
          : <String, dynamic>{};
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw ServerException('Sumsub access token missing from backend response');
      }
      return token;
    } on DioException catch (e) {
      throw ServerException(_getErrorMessage(e));
    }
  }

  @override
  Future<String?> syncSumsubStatus() async {
    try {
      final response = await dio.post(
        ApiEndpoints.kycSumsubSync,
        data: {'source': 'STAYS'},
      );
      final body = response.data;
      final data = body is Map<String, dynamic>
          ? (body['data'] is Map<String, dynamic>
              ? body['data'] as Map<String, dynamic>
              : body)
          : <String, dynamic>{};
      return data['status'] as String?;
    } on DioException catch (e) {
      throw ServerException(_getErrorMessage(e));
    }
  }

  @override
  Future<void> createPin(String userId, String pin) async {
    throw ServerException(
      'PIN setup requires an OTP session. Use setPinWithOtpSession.',
    );
  }

  @override
  Future<void> setPinWithOtpSession({
    required String otpSessionToken,
    required String pin,
  }) async {
    try {
      await dio.post(
        ApiEndpoints.pinSet,
        data: {
          'otp_session_token': otpSessionToken,
          'pin': pin,
        },
      );
    } on DioException catch (e) {
      throw ServerException(_getErrorMessage(e));
    } catch (e) {
      throw ServerException('Failed to create PIN');
    }
  }

  @override
  Future<Map<String, dynamic>> completeRegistration(
    String otpSessionToken,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.registrationComplete,
        data: {'otp_session_token': otpSessionToken},
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerException('Invalid registration response');
      }
      return _unwrap(data);
    } on DioException catch (e) {
      throw ServerException(_getErrorMessage(e));
    }
  }

  @override
  Future<void> confirmPin(String userId, String pin) async {
    // Single-step PIN setup via [pinSet]; confirmation is validated client-side.
  }

  @override
  Future<Map<String, dynamic>> loginWithPinRaw(String phone, String pin) async {
    try {
      final response = await dio.post(
        ApiEndpoints.pinVerify,
        data: {
          'phone_number': phone,
          'pin': pin,
          'account_type': 'CONSUMER',
        },
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerException('Invalid response from server');
      }
      return _unwrap(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data['code'] == 'PIN_INVALID') {
          throw ServerException('Wrong PIN. Try again.');
        }
      } else if (e.response?.statusCode == 423) {
        throw ServerException('Account locked. Contact support.');
      }
      throw ServerException(_getErrorMessage(e));
    } catch (e) {
      throw ServerException('Failed to login');
    }
  }

  @override
  Future<void> resendOtp(String phone) async {
    try {
      await dio.post(
        ApiEndpoints.sendOtp,
        data: {'phone_number': phone},
      );
    } on DioException catch (e) {
      throw ServerException(_getErrorMessage(e));
    } catch (e) {
      throw ServerException('Failed to resend OTP');
    }
  }

  @override
  Future<void> logout(String userId) async {
    try {
      await dio.post(
        ApiEndpoints.logout,
        data: {'user_id': userId},
      );
    } catch (_) {
      // Ignore non-200 (best effort)
    }
  }
}
