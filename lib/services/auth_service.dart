// =============================================================================
// NexaStays Auth Service
// =============================================================================
// Handles communication with the backend authentication endpoints.
// Responsible for parsing tokens and handing them off to the SessionManager.
// =============================================================================

import 'package:dio/dio.dart';
import '../core/constants/api_endpoints.dart';
import '../core/error/exceptions.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';
import '../core/session/session_manager.dart';

/// Service responsible for user authentication and session negotiation.
///
/// Uses [DioClient] to make requests and [SessionManager] to persist
/// the lifecycle of JWT tokens.
class AuthService {
  const AuthService({
    required this.dioClient,
    required this.sessionManager,
  });

  /// The underlying network client (configured with interceptors).
  final DioClient dioClient;

  /// The thread-safe session storage.
  final SessionManager sessionManager;

  /// Authenticates a user with [email] and [password].
  ///
  /// On success, automatically persists the returned tokens and userId
  /// to the [SessionManager].
  ///
  /// Throws [AppException] subtypes on failure.
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
        options: Options(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      // Extract tokens from the mapped data payload and save to session
      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        final accessToken = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        final user = data['user'] as Map<String, dynamic>?;
        final userId = user?['id'] as String?;

        if (accessToken != null && refreshToken != null) {
          await sessionManager.saveSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            userId: userId ?? '',
          );
        }
      }

      return apiResponse;
    } catch (e) {
      // The ErrorInterceptor guarantees this is already an AppException
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  /// Registers a new user.
  ///
  /// Note: The backend may or may not return tokens immediately on register.
  /// If it does, we pass them to [SessionManager]. Otherwise, the user
  /// must explicitly log in afterwards.
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
        options: Options(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      // If backend auto-logs in after registration, save tokens.
      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        final accessToken = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        final user = data['user'] as Map<String, dynamic>?;
        final userId = user?['id'] as String?;

        if (accessToken != null && refreshToken != null) {
          await sessionManager.saveSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            userId: userId ?? '',
          );
        }
      }

      return apiResponse;
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  /// Logs the user out by wiping the session from storage and memory.
  Future<void> logout() async {
    // We do not strictly need a network call to logout on stateless JWT,
    // but if you add a /logout endpoint to invalidate the refresh token
    // on the db side, call it here before clearing local session.
    await sessionManager.clear();
  }

  /// Attempts to manually negotiate a new access token using the refresh token.
  ///
  /// Used primarily by the [AuthInterceptor] behind the scenes.
  Future<bool> refreshToken() async {
    try {
      final currentRefresh = await sessionManager.getRefreshToken();
      if (currentRefresh == null || currentRefresh.isEmpty) {
        return false;
      }

      final response = await dioClient.post(
        ApiEndpoints.refreshToken,
        data: {
          'refreshToken': currentRefresh,
        },
        options: Options(),
        // We might want to bypass the AuthInterceptor here to avoid infinite loops,
        // but the interceptor is typically smart enough if we don't send auth headers
        // or uses a specific Dio instance. For now, assume a standard POST.
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await sessionManager.updateTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          return true;
        }
      }

      return false;
    } catch (e) {
      // If refresh fails for any reason (network timeout, 401 unauthorized, etc),
      // consider the session dead.
      return false;
    }
  }
}
