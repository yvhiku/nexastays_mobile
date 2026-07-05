import 'package:equatable/equatable.dart';

import '../../../../core/config/stays_fee_config.dart';
import 'host_preferences.dart';

class Property extends Equatable {
  final String id;
  final String hostId;
  final String name;
  final String description;
  final String city;
  final String neighborhood;
  final String exactAddress;
  final String propertyType;
  final String hostType;
  final int beds;
  final int bathrooms;
  final int maxGuests;
  final double nightlyRate;
  final double? weeklyDiscount;
  final double? monthlyDiscount;
  final int minimumNights;
  final List<String> photoUrls;
  final String? walkthroughVideoUrl;
  final List<String> amenities;
  final HostPreferences rules;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isInstantBook;
  final List<String> vibeTags;
  final String checkInContact;
  final String checkInInstructions;
  final String checkInMethod;
  final bool isTrending;
  final DateTime listedAt;
  final String listingStatus;
  final double? latitude;
  final double? longitude;

  const Property({
    required this.id,
    required this.hostId,
    required this.name,
    required this.description,
    required this.city,
    required this.neighborhood,
    required this.exactAddress,
    required this.propertyType,
    required this.hostType,
    required this.beds,
    required this.bathrooms,
    required this.maxGuests,
    required this.nightlyRate,
    this.weeklyDiscount,
    this.monthlyDiscount,
    this.minimumNights = 1,
    required this.photoUrls,
    this.walkthroughVideoUrl,
    required this.amenities,
    required this.rules,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.isInstantBook,
    required this.vibeTags,
    required this.checkInContact,
    required this.checkInInstructions,
    required this.checkInMethod,
    required this.isTrending,
    required this.listedAt,
    this.listingStatus = 'LIVE',
    this.latitude,
    this.longitude,
  });

  String get cityNeighborhood => '$neighborhood, $city';
  
  bool get hasVideo => walkthroughVideoUrl != null;
  
  bool get isFullyVerified => isVerified && hasVideo;
  
  String get priceDisplay => '${nightlyRate.toInt()} MAD/night';
  
  double get guestTotal {
    final fees = StaysFeeConfig.instance.calculateFees(nightlyRate);
    return fees.totalGuestPays;
  }

  double get hostPayout {
    final fees = StaysFeeConfig.instance.calculateFees(nightlyRate);
    return fees.hostPayout;
  }
  
  String get maskedAddress => '$neighborhood, $city';

  String get shortLocationLabel {
    final area = neighborhood.trim();
    final cityLabel = city.trim();
    if (area.isNotEmpty && cityLabel.isNotEmpty) {
      return '$area, $cityLabel';
    }
    if (exactAddress.isNotEmpty) return exactAddress;
    if (cityLabel.isNotEmpty) return '$cityLabel, Morocco';
    return 'Morocco';
  }

  bool get hasMapCoordinates => latitude != null && longitude != null;

  String get displayAddress {
    if (exactAddress.trim().isNotEmpty) return exactAddress.trim();
    return fullMapsSearchQuery;
  }

  String get fullMapsSearchQuery {
    final raw = exactAddress.trim();
    final cityLabel = city.trim();

    if (raw.isNotEmpty) {
      var query = raw.replaceAll(RegExp(r'\.\s+'), ', ');
      final lower = query.toLowerCase();
      if (cityLabel.isNotEmpty && !lower.contains(cityLabel.toLowerCase())) {
        query = '$query, $cityLabel';
      }
      if (!query.toLowerCase().contains('morocco')) {
        query = '$query, Morocco';
      }
      return query;
    }

    final area = neighborhood.trim();
    if (area.isNotEmpty && cityLabel.isNotEmpty) {
      return '$area, $cityLabel, Morocco';
    }
    if (cityLabel.isNotEmpty) return '$cityLabel, Morocco';
    return 'Morocco';
  }

  String? get staticMapUrl {
    if (!hasMapCoordinates) return null;
    final lat = latitude!.toStringAsFixed(6);
    final lng = longitude!.toStringAsFixed(6);
    return 'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=$lat,$lng&zoom=15&size=600x280&maptype=mapnik'
        '&markers=$lat,$lng,red-pushpin';
  }

  Property copyWith({
    String? id,
    String? hostId,
    String? name,
    String? description,
    String? city,
    String? neighborhood,
    String? exactAddress,
    String? propertyType,
    String? hostType,
    int? beds,
    int? bathrooms,
    int? maxGuests,
    double? nightlyRate,
    double? weeklyDiscount,
    double? monthlyDiscount,
    int? minimumNights,
    List<String>? photoUrls,
    String? walkthroughVideoUrl,
    List<String>? amenities,
    HostPreferences? rules,
    double? rating,
    int? reviewCount,
    bool? isVerified,
    bool? isInstantBook,
    List<String>? vibeTags,
    String? checkInContact,
    String? checkInInstructions,
    String? checkInMethod,
    bool? isTrending,
    DateTime? listedAt,
    String? listingStatus,
    double? latitude,
    double? longitude,
  }) {
    return Property(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      name: name ?? this.name,
      description: description ?? this.description,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      exactAddress: exactAddress ?? this.exactAddress,
      propertyType: propertyType ?? this.propertyType,
      hostType: hostType ?? this.hostType,
      beds: beds ?? this.beds,
      bathrooms: bathrooms ?? this.bathrooms,
      maxGuests: maxGuests ?? this.maxGuests,
      nightlyRate: nightlyRate ?? this.nightlyRate,
      weeklyDiscount: weeklyDiscount ?? this.weeklyDiscount,
      monthlyDiscount: monthlyDiscount ?? this.monthlyDiscount,
      minimumNights: minimumNights ?? this.minimumNights,
      photoUrls: photoUrls ?? this.photoUrls,
      walkthroughVideoUrl: walkthroughVideoUrl ?? this.walkthroughVideoUrl,
      amenities: amenities ?? this.amenities,
      rules: rules ?? this.rules,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      isInstantBook: isInstantBook ?? this.isInstantBook,
      vibeTags: vibeTags ?? this.vibeTags,
      checkInContact: checkInContact ?? this.checkInContact,
      checkInInstructions: checkInInstructions ?? this.checkInInstructions,
      checkInMethod: checkInMethod ?? this.checkInMethod,
      isTrending: isTrending ?? this.isTrending,
      listedAt: listedAt ?? this.listedAt,
      listingStatus: listingStatus ?? this.listingStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
        id,
        hostId,
        name,
        description,
        city,
        neighborhood,
        exactAddress,
        propertyType,
        hostType,
        beds,
        bathrooms,
        maxGuests,
        nightlyRate,
        weeklyDiscount,
        monthlyDiscount,
        minimumNights,
        photoUrls,
        walkthroughVideoUrl,
        amenities,
        rules,
        rating,
        reviewCount,
        isVerified,
        isInstantBook,
        vibeTags,
        checkInContact,
        checkInInstructions,
        checkInMethod,
        isTrending,
        listedAt,
        listingStatus,
        latitude,
        longitude,
      ];
}
