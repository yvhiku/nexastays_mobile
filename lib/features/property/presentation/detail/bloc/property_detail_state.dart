import 'package:equatable/equatable.dart';

import '../../../domain/entities/fee_breakdown.dart';
import '../../../domain/entities/property.dart';
import '../../../domain/entities/review.dart';

sealed class PropertyDetailState extends Equatable {
  const PropertyDetailState();

  @override
  List<Object?> get props => [];
}

final class PropertyDetailInitial extends PropertyDetailState {
  const PropertyDetailInitial();
}

final class PropertyDetailLoading extends PropertyDetailState {
  const PropertyDetailLoading();
}

final class PropertyDetailLoaded extends PropertyDetailState {
  const PropertyDetailLoaded({
    required this.property,
    required this.reviews,
    required this.isSaved,
    this.similarProperties = const [],
    this.reviewsApiTotal,
    this.reviewsDistributionPct,
    this.reviewsSummaryAvgRating,
    this.isLoadingReviews = false,
    this.hasMoreReviews = true,
    this.reviewPage = 1,
    this.isVideoPlaying = false,
    this.contactRevealed = false,
    this.feePreview,
    this.selectedCheckIn,
    this.selectedCheckOut,
    this.selectedGuests = 1,
  });

  final Property property;
  final List<Review> reviews;
  final bool isSaved;
  final List<Property> similarProperties;
  /// From stays reviews API aggregate (optional; strengthens header vs listing snippet).
  final int? reviewsApiTotal;
  final Map<int, double>? reviewsDistributionPct;
  final double? reviewsSummaryAvgRating;
  final bool isLoadingReviews;
  final bool hasMoreReviews;
  final int reviewPage;
  final bool isVideoPlaying;
  final bool contactRevealed;
  final FeeBreakdown? feePreview;
  final DateTime? selectedCheckIn;
  final DateTime? selectedCheckOut;
  final int selectedGuests;

  PropertyDetailLoaded copyWith({
    Property? property,
    List<Review>? reviews,
    bool? isSaved,
    List<Property>? similarProperties,
    int? reviewsApiTotal,
    Map<int, double>? reviewsDistributionPct,
    double? reviewsSummaryAvgRating,
    bool? isLoadingReviews,
    bool? hasMoreReviews,
    int? reviewPage,
    bool? isVideoPlaying,
    bool? contactRevealed,
    FeeBreakdown? feePreview,
    DateTime? selectedCheckIn,
    DateTime? selectedCheckOut,
    int? selectedGuests,
  }) {
    return PropertyDetailLoaded(
      property: property ?? this.property,
      reviews: reviews ?? this.reviews,
      isSaved: isSaved ?? this.isSaved,
      similarProperties: similarProperties ?? this.similarProperties,
      reviewsApiTotal: reviewsApiTotal ?? this.reviewsApiTotal,
      reviewsDistributionPct: reviewsDistributionPct ?? this.reviewsDistributionPct,
      reviewsSummaryAvgRating:
          reviewsSummaryAvgRating ?? this.reviewsSummaryAvgRating,
      isLoadingReviews: isLoadingReviews ?? this.isLoadingReviews,
      hasMoreReviews: hasMoreReviews ?? this.hasMoreReviews,
      reviewPage: reviewPage ?? this.reviewPage,
      isVideoPlaying: isVideoPlaying ?? this.isVideoPlaying,
      contactRevealed: contactRevealed ?? this.contactRevealed,
      feePreview: feePreview ?? this.feePreview,
      selectedCheckIn: selectedCheckIn ?? this.selectedCheckIn,
      selectedCheckOut: selectedCheckOut ?? this.selectedCheckOut,
      selectedGuests: selectedGuests ?? this.selectedGuests,
    );
  }

  @override
  List<Object?> get props => [
        property,
        reviews,
        isSaved,
        similarProperties,
        reviewsApiTotal,
        reviewsDistributionPct,
        reviewsSummaryAvgRating,
        isLoadingReviews,
        hasMoreReviews,
        reviewPage,
        isVideoPlaying,
        contactRevealed,
        feePreview,
        selectedCheckIn,
        selectedCheckOut,
        selectedGuests,
      ];
}

final class PropertyDetailError extends PropertyDetailState {
  const PropertyDetailError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class PropertyDetailSaving extends PropertyDetailState {
  const PropertyDetailSaving();
}
