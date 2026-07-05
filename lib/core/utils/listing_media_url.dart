import '../../app/env/env_bootstrap.dart';
import '../constants/api_endpoints.dart';

/// Public URL for a listing photo or walkthrough (`GET /stays/listings/:id/media/:assetId`).
String listingMediaUrl(String listingId, String assetId) {
  final base = currentEnv.staysBaseUrl.replaceAll(RegExp(r'/+$'), '');
  return '$base${ApiEndpoints.listingMedia(listingId, assetId)}';
}

/// First PHOTO asset URL from a listing payload (search/detail/booking nested listing).
String firstListingPhotoUrl(Map<String, dynamic> listing) {
  final listingId = (listing['id'] ?? '').toString();
  if (listingId.isEmpty) return '';

  final media = listing['media'];
  if (media is! List) return '';

  for (final item in media) {
    if (item is! Map) continue;
    final kind = (item['kind'] ?? '').toString().toUpperCase();
    if (kind != 'PHOTO') continue;
    final assetId = (item['asset_id'] ?? '').toString();
    if (assetId.isNotEmpty) {
      return listingMediaUrl(listingId, assetId);
    }
  }
  return '';
}
