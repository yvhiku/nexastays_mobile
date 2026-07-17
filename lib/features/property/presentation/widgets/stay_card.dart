import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../home/domain/entities/property.dart' as home;
import '../../domain/entities/property.dart' as stays;

class StayCardData {
  const StayCardData({
    required this.id,
    required this.title,
    required this.location,
    required this.propertyType,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.beds,
    required this.maxGuests,
    required this.nightlyRate,
    required this.isVerified,
    required this.isInstantBook,
  });

  factory StayCardData.fromProperty(stays.Property property) {
    return StayCardData(
      id: property.id,
      title: property.name,
      location: property.city,
      propertyType: property.propertyType,
      imageUrl: property.photoUrls.isNotEmpty ? property.photoUrls.first : '',
      rating: property.rating,
      reviewCount: property.reviewCount,
      beds: property.beds,
      maxGuests: property.maxGuests,
      nightlyRate: property.nightlyRate,
      isVerified: property.isVerified,
      isInstantBook: property.isInstantBook,
    );
  }

  factory StayCardData.fromHomeProperty(home.Property property) {
    return StayCardData(
      id: property.id,
      title: property.title,
      location: property.city,
      propertyType: property.propertyType,
      imageUrl: property.imageUrl,
      rating: property.rating,
      reviewCount: property.reviewCount,
      beds: property.bedrooms,
      maxGuests: property.maxGuests,
      nightlyRate: property.pricePerNight,
      isVerified: property.isVerified,
      isInstantBook: property.isInstantBook,
    );
  }

  final String id;
  final String title;
  final String location;
  final String propertyType;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int beds;
  final int maxGuests;
  final double nightlyRate;
  final bool isVerified;
  final bool isInstantBook;
}

/// Canonical listing card used across Discover, Explore, Saved and Similar.
class StayCard extends StatelessWidget {
  const StayCard({
    super.key,
    required this.stay,
    required this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.compact = false,
    this.width,
  });

  final StayCardData stay;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final bool compact;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final imageHeight = compact ? 156.0 : 228.0;
    return Semantics(
      button: true,
      label: '${stay.title}, ${stay.location}',
      child: SizedBox(
        width: width,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: double.infinity,
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _StayImage(url: stay.imageUrl),
                      if (stay.isVerified || stay.isInstantBook)
                        Positioned(
                          left: 12,
                          top: 12,
                          child: Wrap(
                            spacing: 6,
                            children: [
                              if (stay.isVerified)
                                const _StayBadge(
                                  icon: Icons.verified_rounded,
                                  label: 'Verified',
                                ),
                              if (stay.isInstantBook)
                                const _StayBadge(
                                  icon: Icons.bolt_rounded,
                                  label: 'Instant',
                                  dark: true,
                                ),
                            ],
                          ),
                        ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: isFavorite ? 'Remove from saved' : 'Save',
                            onPressed: onFavoriteTap,
                            iconSize: 21,
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? const Color(0xFFE8507A)
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _titleCase(stay.propertyType),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: const Color(0xFF7C5260),
                      ),
                    ),
                  ),
                  _RatingLabel(
                    rating: stay.rating,
                    reviewCount: stay.reviewCount,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                stay.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: compact ? 12 : 13,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stay.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  fontSize: compact ? 15 : 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${stay.beds} ${stay.beds == 1 ? 'bed' : 'beds'}'
                '  •  ${stay.maxGuests} ${stay.maxGuests == 1 ? 'guest' : 'guests'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '${NumberFormat('#,##0').format(stay.nightlyRate)} MAD',
                      style: GoogleFonts.dmSans(
                        fontSize: compact ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    TextSpan(
                      text: ' / night',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _titleCase(String value) {
    if (value.trim().isEmpty) return 'Stay';
    return value
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

class _StayImage extends StatelessWidget {
  const _StayImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return _fallback();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: const Color(0xFFF1F3F5)),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    return const ColoredBox(
      color: Color(0xFFF1F3F5),
      child: Center(
        child:
            Icon(Icons.home_work_outlined, size: 42, color: Color(0xFF9CA3AF)),
      ),
    );
  }
}

class _StayBadge extends StatelessWidget {
  const _StayBadge({
    required this.icon,
    required this.label,
    this.dark = false,
  });

  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final background = dark ? const Color(0xFF1A1A2E) : const Color(0xFFE8507A);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingLabel extends StatelessWidget {
  const _RatingLabel({required this.rating, required this.reviewCount});

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    if (reviewCount <= 0 || rating <= 0) {
      return Text(
        'New',
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFE8507A),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF2A900)),
        const SizedBox(width: 2),
        Text(
          '${rating.toStringAsFixed(1)} ($reviewCount)',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}
