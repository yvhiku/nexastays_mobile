import '../models/property_model.dart';
import '../models/review_model.dart';
import '../../../search/domain/entities/search_filter.dart';

/// Contract for fetching property data from any source (remote API, local mock).
abstract class PropertyDataSource {
  Future<List<PropertyModel>> getProperties({
    SearchFilter? filter,
    bool featured = false,
    bool trending = false,
  });

  Future<PropertyModel> getPropertyById(String id);

  Future<List<ReviewModel>> getReviews({
    required String propertyId,
    int page = 1,
    int limit = 10,
  });

  Future<List<PropertyModel>> getFeaturedProperties();

  Future<List<PropertyModel>> getTrendingProperties();

  Future<List<PropertyModel>> getSavedProperties(String userId);

  Future<void> saveProperty({
    required String userId,
    required String propertyId,
  });

  Future<void> unsaveProperty({
    required String userId,
    required String propertyId,
  });

  Future<bool> isPropertySaved({
    required String userId,
    required String propertyId,
  });
}
