import '../../domain/entities/host_preferences.dart';
import '../../domain/entities/property.dart';

class HostPreferencesModel extends HostPreferences {
  const HostPreferencesModel({
    super.petsAllowed = false,
    super.smokingAllowed = false,
    super.eventsAllowed = false,
    super.suitableForInfants = true,
    super.quietHoursFrom = "22:00",
    super.quietHoursUntil = "08:00",
    super.maxGuests = 2,
    super.additionalRules,
    required super.checkInFrom,
    required super.checkOutBefore,
  });

  factory HostPreferencesModel.fromJson(Map<String, dynamic> json) {
    return HostPreferencesModel(
      petsAllowed: json['pets_allowed'] ?? false,
      smokingAllowed: json['smoking_allowed'] ?? false,
      eventsAllowed: json['events_allowed'] ?? false,
      suitableForInfants: json['suitable_for_infants'] ?? true,
      quietHoursFrom: json['quiet_hours_from'] ?? "22:00",
      quietHoursUntil: json['quiet_hours_until'] ?? "08:00",
      maxGuests: json['max_guests'] ?? 2,
      additionalRules: json['additional_rules'],
      checkInFrom: json['check_in_from'] ?? "14:00",
      checkOutBefore: json['check_out_before'] ?? "11:00",
    );
  }

  factory HostPreferencesModel.fromEntity(HostPreferences entity) {
    return HostPreferencesModel(
      petsAllowed: entity.petsAllowed,
      smokingAllowed: entity.smokingAllowed,
      eventsAllowed: entity.eventsAllowed,
      suitableForInfants: entity.suitableForInfants,
      quietHoursFrom: entity.quietHoursFrom,
      quietHoursUntil: entity.quietHoursUntil,
      maxGuests: entity.maxGuests,
      additionalRules: entity.additionalRules,
      checkInFrom: entity.checkInFrom,
      checkOutBefore: entity.checkOutBefore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pets_allowed': petsAllowed,
      'smoking_allowed': smokingAllowed,
      'events_allowed': eventsAllowed,
      'suitable_for_infants': suitableForInfants,
      'quiet_hours_from': quietHoursFrom,
      'quiet_hours_until': quietHoursUntil,
      'max_guests': maxGuests,
      if (additionalRules != null) 'additional_rules': additionalRules,
      'check_in_from': checkInFrom,
      'check_out_before': checkOutBefore,
    };
  }
}

class PropertyModel extends Property {
  const PropertyModel({
    required super.id,
    required super.hostId,
    required super.name,
    required super.description,
    required super.city,
    required super.neighborhood,
    required super.exactAddress,
    required super.propertyType,
    required super.hostType,
    required super.beds,
    required super.bathrooms,
    required super.maxGuests,
    required super.nightlyRate,
    super.weeklyDiscount,
    super.monthlyDiscount,
    super.minimumNights = 1,
    required super.photoUrls,
    super.walkthroughVideoUrl,
    required super.amenities,
    required HostPreferencesModel super.rules,
    required super.rating,
    required super.reviewCount,
    required super.isVerified,
    required super.isInstantBook,
    required super.vibeTags,
    required super.checkInContact,
    required super.checkInInstructions,
    required super.checkInMethod,
    required super.isTrending,
    required super.listedAt,
    super.listingStatus = 'LIVE',
    super.latitude,
    super.longitude,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] ?? '',
      hostId: json['host_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      exactAddress: (json['exact_address'] ?? json['address'] ?? '').toString(),
      propertyType: json['property_type'] ?? '',
      hostType: json['host_type'] ?? '',
      beds: json['beds'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      maxGuests: json['max_guests'] ?? 0,
      nightlyRate: (json['nightly_rate'] as num?)?.toDouble() ?? 0.0,
      weeklyDiscount: (json['weekly_discount'] as num?)?.toDouble(),
      monthlyDiscount: (json['monthly_discount'] as num?)?.toDouble(),
      minimumNights: json['minimum_nights'] ?? 1,
      photoUrls: (json['photo_urls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      walkthroughVideoUrl: json['walkthrough_video_url'],
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      rules: json['rules'] != null 
          ? HostPreferencesModel.fromJson(json['rules']) 
          : const HostPreferencesModel(checkInFrom: "14:00", checkOutBefore: "11:00"),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      isInstantBook: json['is_instant_book'] ?? false,
      vibeTags: (json['vibe_tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      checkInContact: json['check_in_contact'] ?? '',
      checkInInstructions: json['check_in_instructions'] ?? '',
      checkInMethod: json['check_in_method'] ?? '',
      isTrending: json['is_trending'] ?? false,
      listedAt: json['listed_at'] != null 
          ? DateTime.parse(json['listed_at']) 
          : DateTime.now(),
      listingStatus: (json['status'] ?? 'LIVE').toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ??
          (json['geo_lat'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble() ??
          (json['geo_lng'] as num?)?.toDouble(),
    );
  }

  factory PropertyModel.fromEntity(Property entity) {
    return PropertyModel(
      id: entity.id,
      hostId: entity.hostId,
      name: entity.name,
      description: entity.description,
      city: entity.city,
      neighborhood: entity.neighborhood,
      exactAddress: entity.exactAddress,
      propertyType: entity.propertyType,
      hostType: entity.hostType,
      beds: entity.beds,
      bathrooms: entity.bathrooms,
      maxGuests: entity.maxGuests,
      nightlyRate: entity.nightlyRate,
      weeklyDiscount: entity.weeklyDiscount,
      monthlyDiscount: entity.monthlyDiscount,
      minimumNights: entity.minimumNights,
      photoUrls: entity.photoUrls,
      walkthroughVideoUrl: entity.walkthroughVideoUrl,
      amenities: entity.amenities,
      rules: HostPreferencesModel.fromEntity(entity.rules),
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      isVerified: entity.isVerified,
      isInstantBook: entity.isInstantBook,
      vibeTags: entity.vibeTags,
      checkInContact: entity.checkInContact,
      checkInInstructions: entity.checkInInstructions,
      checkInMethod: entity.checkInMethod,
      isTrending: entity.isTrending,
      listedAt: entity.listedAt,
      listingStatus: entity.listingStatus,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'host_id': hostId,
      'name': name,
      'description': description,
      'city': city,
      'neighborhood': neighborhood,
      'exact_address': exactAddress,
      'property_type': propertyType,
      'host_type': hostType,
      'beds': beds,
      'bathrooms': bathrooms,
      'max_guests': maxGuests,
      'nightly_rate': nightlyRate,
      if (weeklyDiscount != null) 'weekly_discount': weeklyDiscount,
      if (monthlyDiscount != null) 'monthly_discount': monthlyDiscount,
      'minimum_nights': minimumNights,
      'photo_urls': photoUrls,
      if (walkthroughVideoUrl != null) 'walkthrough_video_url': walkthroughVideoUrl,
      'amenities': amenities,
      'rules': (rules as HostPreferencesModel).toJson(),
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'is_instant_book': isInstantBook,
      'vibe_tags': vibeTags,
      'check_in_contact': checkInContact,
      'check_in_instructions': checkInInstructions,
      'check_in_method': checkInMethod,
      'is_trending': isTrending,
      'listed_at': listedAt.toIso8601String(),
      'status': listingStatus,
    };
  }
}
