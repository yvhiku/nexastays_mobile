import '../../property/domain/entities/property.dart';
import 'entities/search_filter.dart';

/// Client-side filter pass — mirrors web listings page behavior for fields
/// the search API does not filter server-side (guest type, vibes, price, etc.).
List<Property> applySearchFilter(List<Property> properties, SearchFilter filter) {
  var list = List<Property>.from(properties);

  if (filter.city != null && filter.city!.trim().isNotEmpty) {
    final q = filter.city!.trim().toLowerCase();
    list = list
        .where((p) => p.city.toLowerCase().contains(q))
        .toList();
  }

  if (filter.verifiedOnly) {
    list = list.where((p) => p.isVerified || p.hasVideo).toList();
  }

  if (filter.instantBookOnly) {
    list = list.where((p) => p.isInstantBook).toList();
  }

  if (filter.guestType == 'couples') {
    list = list.where((p) => p.maxGuests <= 2).toList();
  } else if (filter.guestType == 'family') {
    list = list.where((p) => p.maxGuests >= 4).toList();
  }

  if (filter.vibes.isNotEmpty) {
    list = list.where((p) {
      if (p.vibeTags.isNotEmpty) {
        return filter.vibes.any(p.vibeTags.contains);
      }
      final haystack =
          '${p.description} ${p.amenities.join(' ')} ${p.propertyType} ${p.name}'
              .toLowerCase();
      return filter.vibes.any((v) => haystack.contains(v.toLowerCase()));
    }).toList();
  }

  if (filter.minPrice != null) {
    list = list.where((p) => p.nightlyRate >= filter.minPrice!).toList();
  }
  if (filter.maxPrice != null) {
    list = list.where((p) => p.nightlyRate <= filter.maxPrice!).toList();
  }
  if (filter.minBeds != null) {
    list = list.where((p) => p.beds >= filter.minBeds!).toList();
  }
  if (filter.guestCount > 1) {
    list = list.where((p) => p.maxGuests >= filter.guestCount).toList();
  }

  switch (filter.sortOrder) {
    case SortOrder.priceLow:
      list.sort((a, b) => a.nightlyRate.compareTo(b.nightlyRate));
    case SortOrder.priceHigh:
      list.sort((a, b) => b.nightlyRate.compareTo(a.nightlyRate));
    case SortOrder.newest:
      list.sort((a, b) => b.listedAt.compareTo(a.listedAt));
    case SortOrder.bestMatch:
      break;
  }

  return list;
}
