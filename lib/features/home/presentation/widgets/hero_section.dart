import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../navigation/app_routes.dart';
import '../../domain/entities/property.dart';

/// Full-width hero card showcasing a single featured property.
///
/// Layout (200 px tall, rounded 20 px):
///   • Background: property cover image with a dark gradient overlay.
///   • Top-left: "✓ Verified" badge (#E8185E).
///   • Bottom: property name, city, rating & price over the gradient.
class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.propertyDetailOf(property.id)),
      child: Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background image ──────────────────────────────────────
            CachedNetworkImage(
              imageUrl: property.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, size: 48, color: Colors.white54),
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
                    Color(0xA6000000), // rgba(0,0,0,0.65)
                  ],
                  stops: [0.35, 1.0],
                ),
              ),
            ),

            // ── Verified badge (top-left) ─────────────────────────────
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8507A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom overlay content ────────────────────────────────
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Property name
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // City · ⭐ Rating · Price
                  Row(
                    children: [
                      // City
                      Flexible(
                        child: Text(
                          property.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Rating
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        property.rating.toStringAsFixed(1),
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),

                      const Spacer(),

                      // Price
                      Text(
                        '${property.pricePerNight.toInt()} MAD/night',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
