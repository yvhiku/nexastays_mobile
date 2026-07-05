import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/property.dart';

/// "Today's Drops" section — a **horizontal scroll** of compact property cards
/// with a section header row.
class FeaturedStays extends StatelessWidget {
  const FeaturedStays({
    super.key,
    required this.properties,
    required this.onSeeAll,
    required this.onPropertyTap,
  });

  final List<Property> properties;
  final VoidCallback onSeeAll;
  final ValueChanged<Property> onPropertyTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Section header ──────────────────────────────────────────
        _SectionHeader(onSeeAll: onSeeAll),
        const SizedBox(height: 12),

        // ── Horizontal property cards ───────────────────────────────
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: properties.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) => _PropertyCard(
              property: properties[index],
              onTap: () => onPropertyTap(properties[index]),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Section Header
// ═════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '🔥 Today\'s Drops',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'See all',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE8507A),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Compact horizontal property card
// ═════════════════════════════════════════════════════════════════════════════

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({
    required this.property,
    required this.onTap,
  });

  final Property property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Cover image ───────────────────────────────────────────
            CachedNetworkImage(
              imageUrl: property.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image,
                    size: 32, color: Colors.white54),
              ),
            ),

            // ── Dark gradient overlay ─────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xCC000000), // ~80% opacity
                  ],
                  stops: [0.4, 1.0],
                ),
              ),
            ),

            // ── Badge (top-left) ──────────────────────────────────────
            Positioned(
              top: 8,
              left: 8,
              child: _buildBadge(),
            ),

            // ── Bottom info overlay ───────────────────────────────────
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // City (uppercase)
                  Text(
                    '${property.address}, ${property.city}'.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Property name
                  Text(
                    property.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Price
                  Text(
                    '${property.pricePerNight.toInt()} MAD',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE8507A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    final bool isTrending = property.isTrending;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isTrending ? const Color(0xFFFBBF24) : const Color(0xFFE8507A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isTrending ? '🔥 Trending' : '✅ Verified',
        style: GoogleFonts.dmSans(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: isTrending ? const Color(0xFF1A1A2E) : Colors.white,
        ),
      ),
    );
  }
}
