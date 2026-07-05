import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/data/models/user_model.dart';

// =============================================================================
// Profile Remote Data Source
// =============================================================================

/// Contract for profile API calls.
abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile(String userId);

  Future<UserModel> updateProfile({
    required String userId,
    bool identityLocked = false,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? profilePhotoPath,
  });

  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteAccount(String userId);

  Future<void> updateNotificationPreferences({
    required String userId,
    required Map<String, bool> preferences,
  });

  Future<void> updateLanguagePreference({
    required String userId,
    required String languageCode,
  });
}

// =============================================================================
// Implementation
// =============================================================================

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._client);

  final DioClient _client;

  Never _throwOnError(DioException e) {
    final message =
        e.response?.data?['message'] as String? ?? e.message ?? 'Server error';
    throw ServerException(message);
  }

  // ── Get profile ──────────────────────────────────────────────────────

  Map<String, dynamic> _unwrapPayload(dynamic raw) {
    if (raw is! Map) {
      throw ServerException('Invalid profile response');
    }
    final map = Map<String, dynamic>.from(raw);
    final inner = map['data'];
    if (inner is Map<String, dynamic>) {
      return Map<String, dynamic>.from(inner);
    }
    return map;
  }

  @override
  Future<UserModel> getProfile(String userId) async {
    try {
      final response = await _client.get(ApiEndpoints.usersMe);
      final payload = _unwrapPayload(response.data);
      final phone = payload['phone_number'] as String? ?? '';
      return UserModel.fromUsersMe(payload, phoneFallback: phone);
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  // ── Update profile ───────────────────────────────────────────────────

  @override
  Future<UserModel> updateProfile({
    required String userId,
    bool identityLocked = false,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? profilePhotoPath,
  }) async {
    try {
      if (profilePhotoPath != null) {
        await _client.dio.post(
          ApiEndpoints.usersProfilePhoto,
          data: FormData.fromMap({
            'file': await MultipartFile.fromFile(profilePhotoPath),
          }),
        );
      }

      final body = <String, dynamic>{};
      if (!identityLocked) {
        final nameParts = <String>[
          if (firstName != null && firstName.trim().isNotEmpty) firstName.trim(),
          if (lastName != null && lastName.trim().isNotEmpty) lastName.trim(),
        ];
        if (nameParts.isNotEmpty) {
          body['full_name'] = nameParts.join(' ');
        }
      }
      if (email != null && email.trim().isNotEmpty) {
        body['email'] = email.trim();
      }

      if (body.isNotEmpty) {
        await _client.dio.patch(ApiEndpoints.usersProfile, data: body);
      }

      return getProfile(userId);
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  // ── Change password ──────────────────────────────────────────────────

  @override
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _client.dio.post(
        '/users/$userId/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  // ── Delete account ───────────────────────────────────────────────────

  @override
  Future<void> deleteAccount(String userId) async {
    try {
      await _client.delete(ApiEndpoints.usersMe);
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  // ── Notification preferences ─────────────────────────────────────────

  @override
  Future<void> updateNotificationPreferences({
    required String userId,
    required Map<String, bool> preferences,
  }) async {
    try {
      await _client.dio.patch(
        '/users/$userId/notifications',
        data: {'preferences': preferences},
      );
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  // ── Language preference ──────────────────────────────────────────────

  @override
  Future<void> updateLanguagePreference({
    required String userId,
    required String languageCode,
  }) async {
    try {
      await _client.dio.patch(
        '/users/$userId/language',
        data: {'language': languageCode},
      );
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }
}
