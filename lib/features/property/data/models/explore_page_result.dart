import '../models/property_model.dart';

/// Cursor page from GET /stays/explore.
class ExplorePageResult {
  const ExplorePageResult({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<PropertyModel> items;
  final bool hasMore;
  final String? nextCursor;
}

/// Pin page from GET /stays/explore/map.
class ExploreMapResult {
  const ExploreMapResult({
    required this.items,
    required this.truncated,
  });

  final List<PropertyModel> items;
  final bool truncated;
}
