import 'package:equatable/equatable.dart';

import 'review.dart';

/// Result of `GET /stays/listings/:id/reviews` (one page + aggregate summary).
class ListingReviewsResult extends Equatable {
  const ListingReviewsResult({
    required this.reviews,
    required this.apiTotalCount,
    this.distributionPct = const {},
    this.summaryAvgRating,
  });

  final List<Review> reviews;
  /// Total reviews for the listing (`summary.total_count`); used for paging.
  final int apiTotalCount;
  /// Fraction of reviews per star 1–5 (`summary.distribution_pct` from API).
  final Map<int, double> distributionPct;
  final double? summaryAvgRating;

  @override
  List<Object?> get props => [reviews, apiTotalCount, distributionPct, summaryAvgRating];
}
