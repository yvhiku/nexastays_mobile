// =============================================================================
// NexaStays Auth Interceptor
// =============================================================================
// Attaches JWT access tokens to outgoing requests and transparently handles
// 401 responses by refreshing the token and retrying the original request
// exactly once.
// =============================================================================

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../app/env/env_bootstrap.dart';
import '../../constants/api_endpoints.dart';
import '../../session/session_manager.dart';

/// Header key used to mark a request as a retry so we don't loop infinitely.
const String _kRetryHeader = 'x-nexastays-retry';

/// Dio [Interceptor] that manages JWT authentication.
///
/// • **onRequest** — injects `Authorization: Bearer <token>`.
/// • **onError**   — on 401, attempts a silent token refresh and retries once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    SessionManager? sessionManager,
  }) : _session = sessionManager ?? SessionManager();

  final SessionManager _session;

  // ── Attach token ────────────────────────────────────────────────────

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = _session.accessToken;

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  // ── Handle 401 — refresh & retry ────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;

    // Only handle 401 Unauthorized.
    if (response?.statusCode != HttpStatus.unauthorized) {
      return handler.next(err);
    }

    // Prevent infinite retry loops.
    if (err.requestOptions.headers.containsKey(_kRetryHeader)) {
      await _session.clear();
      return handler.next(err);
    }

    // Attempt a token refresh.
    final refreshed = await _tryRefreshToken();

    if (!refreshed) {
      await _session.clear();
      return handler.next(err);
    }

    // Retry the original request with the new access token.
    try {
      final retryOptions = err.requestOptions.copyWith(
        headers: {
          ...err.requestOptions.headers,
          'Authorization': 'Bearer ${_session.accessToken}',
          _kRetryHeader: '1',
        },
      );

      final dio = Dio();
      final retryResponse = await dio.fetch(retryOptions);
      return handler.resolve(retryResponse);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  // ── Token refresh logic ─────────────────────────────────────────────

  /// Attempts to obtain a new access token using the stored refresh token.
  ///
  /// Returns `true` if the refresh succeeded and [SessionManager] has been
  /// updated, `false` otherwise.
  Future<bool> _tryRefreshToken() async {
    final refreshToken = _session.refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      // Use a standalone Dio instance to avoid triggering this interceptor
      // recursively.
      final dio = Dio(BaseOptions(
        baseUrl: currentEnv.identityBaseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == HttpStatus.ok && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await _session.updateTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          return true;
        }
      }
    } catch (_) {
      // Refresh failed — caller will clear the session.
    }

    return false;
  }
}
