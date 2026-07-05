// =============================================================================
// NexaStays Generic API Response Wrapper
// =============================================================================
// Standardised envelope for all JSON responses returned by the NexaStays API.
//
// Expected server JSON shape:
// {
//   "success": true,
//   "message": "Operation completed",
//   "data": { ... }
// }
// =============================================================================

/// A generic, reusable wrapper for API responses.
///
/// [T] is the type of the payload contained in the `data` field.
///
/// ```dart
/// final response = ApiResponse<User>.fromJson(
///   json,
///   (data) => User.fromJson(data as Map<String, dynamic>),
/// );
/// ```
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  /// Whether the server reported a successful operation.
  final bool success;

  /// Optional human-readable message from the server.
  final String? message;

  /// Parsed payload (may be `null` for operations with no return data).
  final T? data;

  // ── Convenience ─────────────────────────────────────────────────────

  /// Alias for [success] — useful in conditional expressions.
  bool get isSuccess => success == true;

  /// `true` when the response indicates failure.
  bool get isFailure => !isSuccess;

  // ── Serialisation ───────────────────────────────────────────────────

  /// Creates an [ApiResponse] from a raw JSON map.
  ///
  /// [fromJsonT] converts the raw `data` value into [T]. Pass `null` if the
  /// endpoint does not return a data payload.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  /// Creates an [ApiResponse] for endpoints that return no typed payload.
  factory ApiResponse.simple(Map<String, dynamic> json) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: null,
    );
  }

  /// Converts this response back to a JSON-compatible map.
  ///
  /// [toJsonT] serialises the [data] payload. If [data] is `null` the `data`
  /// key is omitted from the output.
  Map<String, dynamic> toJson([Object? Function(T value)? toJsonT]) {
    return <String, dynamic>{
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': toJsonT != null ? toJsonT(data as T) : data,
    };
  }

  @override
  String toString() =>
      'ApiResponse(success: $success, message: $message, data: $data)';
}
