import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../navigation/app_routes.dart';
import '../../../domain/entities/property.dart';
import '../listing/listing_colors.dart';

class ListingSimilarStays extends StatelessWidget {
  const ListingSimilarStays({
    super.key,
    required this.properties,
  });

  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ListingColors.marginMobile),
          child: Text(
            'Similar Sanctuaries',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: ListingColors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: ListingColors.marginMobile),
            itemCount: properties.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final property = properties[index];
              return _SimilarStayCard(
                property: property,
                onTap: () => context.push(AppRoutes.propertyDetailOf(property.id)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SimilarStayCard extends StatelessWidget {
  const _SimilarStayCard({
    required this.property,
    required this.onTap,
  });

  final Property property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        property.photoUrls.isNotEmpty ? property.photoUrls.first : null;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 288,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 192,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _imageFallback(),
                      )
                    else
                      _imageFallback(),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Icon(
                        Icons.favorite_border,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              property.name,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ListingColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              property.neighborhood.isNotEmpty
                  ? property.neighborhood
                  : property.city,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.05 * 12,
                color: ListingColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'MAD ${property.nightlyRate.toInt()} / night',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ListingColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: ListingColors.surfaceContainerHighest,
      child: const Icon(Icons.home_outlined, color: ListingColors.outline),
    );
  }
}
