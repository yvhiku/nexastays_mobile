import '../../app/env/env_bootstrap.dart';
import '../constants/api_endpoints.dart';

/// Whether the user has uploaded a profile photo (API stores a path marker, not a CDN URL).
bool userHasProfilePhoto(String? profilePhotoUrl) =>
    profilePhotoUrl != null && profilePhotoUrl.trim().isNotEmpty;

/// Authenticated GET URL for profile photo bytes (`GET /users/me/profile-photo`).
String profilePhotoImageUrl({int cacheRevision = 0}) {
  final base = currentEnv.identityBaseUrl.replaceAll(RegExp(r'/+$'), '');
  final url = '$base${ApiEndpoints.usersProfilePhoto}';
  if (cacheRevision > 0) return '$url?v=$cacheRevision';
  return url;
}
