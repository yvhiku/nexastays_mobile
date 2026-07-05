import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/review.dart';

class ReviewsList extends StatelessWidget {
  const ReviewsList({
    super.key,
    required this.reviews,
    required this.overallRating,
    required this.totalCount,
    /// Star → fraction with that rating (`summary.distribution_pct` from stays API).
    this.distributionPct,
    required this.hasMore,
    required this.isLoading,
    required this.onLoadMore,
  });

  final List<Review> reviews;
  final double overallRating;
  final int totalCount;
  final Map<int, double>? distributionPct;
  final bool hasMore;
  final bool isLoading;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty && !isLoading && totalCount <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Row ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews',
              style: GoogleFonts.playfairDisplay(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  overallRating.toStringAsFixed(2),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  ' ($totalCount reviews)',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_hasHistogram(distributionPct)) ...[
          Text(
            'Rating breakdown',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          ..._histogramRows(distributionPct!),
          const SizedBox(height: 24),
        ],

        // ── Review Cards ───────────────────────────────────────────────
        ...reviews.take(3).map((r) => _ReviewCard(review: r)),
        const SizedBox(height: 16),

        // ── Load More / View All Button ────────────────────────────────
        if (hasMore)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: isLoading ? null : onLoadMore,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF374151),
                      ),
                    )
                  : Text(
                      'Load more reviews',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  bool _hasHistogram(Map<int, double>? d) {
    if (d == null || d.isEmpty) return false;
    for (final v in d.values) {
      if (v > 0) return true;
    }
    return false;
  }

  List<Widget> _histogramRows(Map<int, double> d) {
    final rows = <Widget>[];
    for (var star = 5; star >= 1; star--) {
      final pct = d[star] ?? 0.0;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: star > 1 ? 4 : 0),
          child: _StarHistogramBar(stars: star, fraction: pct),
        ),
      );
    }
    return rows;
  }
}

class _StarHistogramBar extends StatelessWidget {
  const _StarHistogramBar({required this.stars, required this.fraction});

  final int stars;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final r = fraction.clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 12,
          child: Text(
            '$stars',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 6,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Container(
                        height: 6,
                        width: constraints.maxWidth * r,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatefulWidget {
  const _ReviewCard({required this.review});
  final Review review;

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _isExpanded = false;

  String get _initials {
    if (widget.review.guestName.isEmpty) return '?';
    return widget.review.guestName.substring(0, 1).toUpperCase();
  }

  // Assuming Review has some commonly designed fields: authorName, isVerified, date, rating, comment
  // If the entity differs, these accessors will surface compilation errors to adapt.

  // Simulate a timeAgo getter or method if not on the entity
  String get _timeAgo {
    return widget.review.timeAgo; 
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE8507A),
                child: Text(
                  _initials,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.review.guestName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (widget.review.isVerifiedStay)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          '✓ Verified stay',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _timeAgo,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Stars row
          Row(
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  index < widget.review.rating.floor()
                      ? Icons.star
                      : Icons.star_border,
                  size: 14,
                  color: const Color(0xFFF59E0B),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),

          // Comment
          Text(
            widget.review.comment,
            maxLines: _isExpanded ? null : 3,
            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              height: 1.6,
              color: const Color(0xFF374151),
            ),
          ),
          
          if (!_isExpanded && widget.review.comment.length > 100) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = true;
                });
              },
              child: Text(
                'Show more',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
