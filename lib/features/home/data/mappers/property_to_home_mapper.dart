import '../../../property/domain/entities/property.dart' as stays_prop;
import '../../domain/entities/property.dart' as home_entity;

/// Maps full Stays [stays_prop.Property] into the home feature model.
home_entity.Property propertyToHome(stays_prop.Property p) {
  return home_entity.Property(
    id: p.id,
    title: p.name,
    description: p.description,
    city: p.city,
    address: p.exactAddress,
    pricePerNight: p.nightlyRate,
    rating: p.rating,
    reviewCount: p.reviewCount,
    imageUrl: p.photoUrls.isNotEmpty ? p.photoUrls.first : '',
    images: List<String>.from(p.photoUrls),
    hostId: p.hostId,
    isFeatured: false,
    isTrending: p.isTrending,
    propertyType: p.propertyType,
    maxGuests: p.maxGuests,
    bedrooms: p.beds,
    bathrooms: p.bathrooms,
    amenities: List<String>.from(p.amenities),
    createdAt: p.listedAt,
    listingStatus: p.listingStatus,
    isVerified: p.isVerified,
    isInstantBook: p.isInstantBook,
    latitude: p.latitude,
    longitude: p.longitude,
  );
}
