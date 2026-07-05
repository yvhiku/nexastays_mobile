import 'dart:convert';

/// Reads JWT [sub] claim (user id) without verifying the signature.
String? decodeJwtSub(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    var payload = parts[1];
    final mod = payload.length % 4;
    if (mod > 0) payload = payload.padRight(payload.length + (4 - mod), '=');
    final json = utf8.decode(base64Url.decode(payload));
    final map = jsonDecode(json) as Map<String, dynamic>;
    return map['sub'] as String?;
  } catch (_) {
    return null;
  }
}
