import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/property.dart';
import '../listing/listing_colors.dart';

class ListingLocationSection extends StatelessWidget {
  const ListingLocationSection({super.key, required this.property});

  final Property property;

  Future<void> _openInMaps() async {
    final query = property.fullMapsSearchQuery;
    if (query.isEmpty) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationText = property.displayAddress;
    final hasCoords = property.hasMapCoordinates;
    final hasArea = property.shortLocationLabel.isNotEmpty;
    final hasAddress = locationText.trim().isNotEmpty &&
        locationText.toLowerCase() != 'morocco';

    if (!hasAddress && !hasCoords && !hasArea) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where you\'ll stay',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: ListingColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: ListingColors.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                locationText,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: ListingColors.onSurface,
                ),
              ),
            ),
          ],
        ),
        if (hasCoords || hasAddress || hasArea) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: property.staticMapUrl != null
                  ? CachedNetworkImage(
                      imageUrl: property.staticMapUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _mapPlaceholder(),
                      errorWidget: (_, __, ___) => _mapPlaceholder(),
                    )
                  : _mapPlaceholder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openInMaps,
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Open in Maps'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ListingColors.primary,
                side: const BorderSide(color: ListingColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check-in contact and access instructions are shared after your booking is confirmed.',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: ListingColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _mapPlaceholder() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: const Center(
        child: Icon(Icons.map_outlined, color: Color(0xFF9CA3AF), size: 40),
      ),
    );
  }
}
