import 'package:equatable/equatable.dart';

class Property extends Equatable {
  final String id;
  final String title;
  final String description;
  final String city;
  final String address;
  final double pricePerNight;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> images;
  final String hostId;
  final bool isFeatured;
  final bool isTrending;
  final String propertyType;
  final int maxGuests;
  final int bedrooms;
  final int bathrooms;
  final List<String> amenities;
  final DateTime createdAt;
  final String listingStatus;
  final bool isVerified;
  final bool isInstantBook;

  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.address,
    required this.pricePerNight,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.images,
    required this.hostId,
    required this.isFeatured,
    required this.isTrending,
    required this.propertyType,
    required this.maxGuests,
    required this.bedrooms,
    required this.bathrooms,
    required this.amenities,
    required this.createdAt,
    this.listingStatus = 'LIVE',
    this.isVerified = false,
    this.isInstantBook = false,
  });

  Property copyWith({
    String? id,
    String? title,
    String? description,
    String? city,
    String? address,
    double? pricePerNight,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    List<String>? images,
    String? hostId,
    bool? isFeatured,
    bool? isTrending,
    String? propertyType,
    int? maxGuests,
    int? bedrooms,
    int? bathrooms,
    List<String>? amenities,
    DateTime? createdAt,
    String? listingStatus,
    bool? isVerified,
    bool? isInstantBook,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      city: city ?? this.city,
      address: address ?? this.address,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      hostId: hostId ?? this.hostId,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      propertyType: propertyType ?? this.propertyType,
      maxGuests: maxGuests ?? this.maxGuests,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      amenities: amenities ?? this.amenities,
      createdAt: createdAt ?? this.createdAt,
      listingStatus: listingStatus ?? this.listingStatus,
      isVerified: isVerified ?? this.isVerified,
      isInstantBook: isInstantBook ?? this.isInstantBook,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        city,
        address,
        pricePerNight,
        rating,
        reviewCount,
        imageUrl,
        images,
        hostId,
        isFeatured,
        isTrending,
        propertyType,
        maxGuests,
        bedrooms,
        bathrooms,
        amenities,
        createdAt,
        listingStatus,
        isVerified,
        isInstantBook,
      ];
}
