/// Response from `GET /stays/host/reviews`.
class HostReviewsPayload {
  const HostReviewsPayload({
    required this.reviews,
    required this.summary,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<HostReviewItem> reviews;
  final HostReviewsSummary summary;
  final int page;
  final int limit;
  final int total;

  factory HostReviewsPayload.fromJson(Map<String, dynamic> json) {
    final rawList = json['reviews'];
    final list = rawList is List
        ? rawList.whereType<Map<String, dynamic>>().map(HostReviewItem.fromJson).toList()
        : <HostReviewItem>[];
    final sum = json['summary'];
    final summaryMap = sum is Map<String, dynamic>
        ? sum
        : <String, dynamic>{};
    return HostReviewsPayload(
      reviews: list,
      summary: HostReviewsSummary.fromJson(summaryMap),
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class HostReviewsSummary {
  const HostReviewsSummary({
    required this.overallAvgRating,
    required this.totalCount,
    required this.distributionPct,
  });

  final double? overallAvgRating;
  final int totalCount;
  /// Keys "5" .. "1" → fraction of reviews (0–1) for histogram bars.
  final Map<int, double> distributionPct;

  factory HostReviewsSummary.fromJson(Map<String, dynamic> json) {
    final pctRaw = json['distribution_pct'];
    final map = <int, double>{};
    if (pctRaw is Map) {
      for (final e in pctRaw.entries) {
        final k = int.tryParse(e.key.toString());
        final v = (e.value as num?)?.toDouble();
        if (k != null && v != null && k >= 1 && k <= 5) {
          map[k] = v;
        }
      }
    }
    for (var i = 1; i <= 5; i++) {
      map.putIfAbsent(i, () => 0);
    }
    return HostReviewsSummary(
      overallAvgRating: (json['overall_avg_rating'] as num?)?.toDouble(),
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      distributionPct: map,
    );
  }
}

class HostReviewItem {
  const HostReviewItem({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.guestName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String listingId;
  final String listingTitle;
  final String guestName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  factory HostReviewItem.fromJson(Map<String, dynamic> json) {
    return HostReviewItem(
      id: (json['id'] ?? '').toString(),
      listingId: (json['listing_id'] ?? '').toString(),
      listingTitle: (json['listing_title'] ?? 'Listing').toString(),
      guestName: (json['guest_name'] ?? 'Guest').toString(),
      rating: (json['rating'] as num?)?.toInt().clamp(1, 5) ?? 1,
      comment: (json['comment'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
