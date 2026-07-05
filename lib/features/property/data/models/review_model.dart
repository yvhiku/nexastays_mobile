import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.propertyId,
    required super.guestId,
    required super.guestName,
    super.guestPhotoUrl,
    required super.rating,
    required super.comment,
    required super.createdAt,
    required super.isVerifiedStay,
    required super.subRatings,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      propertyId:
          json['property_id']?.toString() ?? json['listing_id']?.toString() ?? '',
      guestId: json['guest_id'] ?? '',
      guestName: json['guest_name'] ?? '',
      guestPhotoUrl: json['guest_photo_url'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isVerifiedStay: json['is_verified_stay'] ?? false,
      subRatings: (json['sub_ratings'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ) ??
          const {},
    );
  }

  factory ReviewModel.fromEntity(Review entity) {
    return ReviewModel(
      id: entity.id,
      propertyId: entity.propertyId,
      guestId: entity.guestId,
      guestName: entity.guestName,
      guestPhotoUrl: entity.guestPhotoUrl,
      rating: entity.rating,
      comment: entity.comment,
      createdAt: entity.createdAt,
      isVerifiedStay: entity.isVerifiedStay,
      subRatings: entity.subRatings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'guest_id': guestId,
      'guest_name': guestName,
      if (guestPhotoUrl != null) 'guest_photo_url': guestPhotoUrl,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'is_verified_stay': isVerifiedStay,
      'sub_ratings': subRatings,
    };
  }
}
