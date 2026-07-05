import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../home/domain/entities/property.dart';

/// A horizontal card displaying a property listing in the search results.
/// Matches the design of the "Today's Drops" cards but full width.
class PropertyListCard extends StatelessWidget {
  const PropertyListCard({
    super.key,
    required this.property,
    this.onTap,
  });

  final Property property;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // ── Left: Image ───────────────────────────────────────────
            SizedBox(
              width: 130,
              height: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: property.images.isNotEmpty
                        ? property.images.first
                        : 'https://via.placeholder.com/400',
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),

            // ── Right: Details ────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            property.city.toUpperCase(),
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: const Color(0xFF9CA3AF),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 2),
                            Text(
                              property.rating.toStringAsFixed(1),
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      property.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Description snippet
                    Text(
                      property.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${property.pricePerNight.toInt()} MAD',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFE8507A),
                                ),
                              ),
                              TextSpan(
                                text: ' /night',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
