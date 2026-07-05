import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String propertyId;
  final String guestId;
  final String guestName;
  final String? guestPhotoUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final bool isVerifiedStay;
  final Map<String, double> subRatings;

  const Review({
    required this.id,
    required this.propertyId,
    required this.guestId,
    required this.guestName,
    this.guestPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.isVerifiedStay,
    required this.subRatings,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String get ratingDisplay => rating.toStringAsFixed(1);

  bool get isHighRating => rating >= 4.0;

  Review copyWith({
    String? id,
    String? propertyId,
    String? guestId,
    String? guestName,
    String? guestPhotoUrl,
    double? rating,
    String? comment,
    DateTime? createdAt,
    bool? isVerifiedStay,
    Map<String, double>? subRatings,
  }) {
    return Review(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      guestId: guestId ?? this.guestId,
      guestName: guestName ?? this.guestName,
      guestPhotoUrl: guestPhotoUrl ?? this.guestPhotoUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      isVerifiedStay: isVerifiedStay ?? this.isVerifiedStay,
      subRatings: subRatings ?? this.subRatings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        guestId,
        guestName,
        guestPhotoUrl,
        rating,
        comment,
        createdAt,
        isVerifiedStay,
        subRatings,
      ];
}
