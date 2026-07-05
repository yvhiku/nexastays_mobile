import 'package:dio/dio.dart';

import '../../app/env/env_bootstrap.dart';
import '../session/session_manager.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// HTTP client for Identity or Stays backends (same JWT, different base URL).
class DioClient {
  DioClient({
    required SessionManager sessionManager,
    required String baseUrl,
  }) : _baseUrl = baseUrl {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )
      ..interceptors.addAll([
        AuthInterceptor(sessionManager: sessionManager),
        ErrorInterceptor(),
        if (currentEnv.enableLogging)
          LogInterceptor(
            request: true,
            requestHeader: true,
            requestBody: true,
            responseHeader: false,
            responseBody: true,
            error: true,
          ),
      ]);
  }

  final String _baseUrl;
  late final Dio _dio;

  String get baseUrl => _baseUrl;

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return _dio.post(path, data: data, options: options);
  }

  Future<Response> put(
    String path, {
    dynamic data,
  }) {
    return _dio.put(path, data: data);
  }

  Future<Response> patch(
    String path, {
    dynamic data,
  }) {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
