import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../listing/listing_colors.dart';

class ListingAmenitiesSection extends StatelessWidget {
  const ListingAmenitiesSection({super.key, required this.amenities});

  final List<String> amenities;

  static IconData _iconFor(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi') || lower.contains('wi-fi')) return Icons.wifi;
    if (lower.contains('kitchen')) return Icons.kitchen_outlined;
    if (lower.contains('air') || lower.contains('ac')) return Icons.ac_unit_outlined;
    if (lower.contains('washer') || lower.contains('laundry')) {
      return Icons.local_laundry_service_outlined;
    }
    if (lower.contains('tv')) return Icons.tv_outlined;
    if (lower.contains('parking')) return Icons.local_parking_outlined;
    if (lower.contains('pool')) return Icons.pool_outlined;
    if (lower.contains('gym')) return Icons.fitness_center_outlined;
    if (lower.contains('workspace') || lower.contains('desk')) {
      return Icons.laptop_mac_outlined;
    }
    return Icons.check_circle_outline;
  }

  void _showAllAmenities(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ListingColors.surfaceBright,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          initialChildSize: 0.6,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'What this place offers',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: ListingColors.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: amenities.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final amenity = amenities[index];
                        return Row(
                          children: [
                            Icon(
                              _iconFor(amenity),
                              color: ListingColors.outline,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                amenity,
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  color: ListingColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = amenities.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What this place offers',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: ListingColors.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 24,
            crossAxisSpacing: 16,
            childAspectRatio: 4,
          ),
          itemCount: preview.length,
          itemBuilder: (context, index) {
            final amenity = preview[index];
            return Row(
              children: [
                Icon(
                  _iconFor(amenity),
                  color: ListingColors.outline,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    amenity,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: ListingColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
        if (amenities.length > 4) ...[
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showAllAmenities(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ListingColors.onSurface,
                side: BorderSide(color: ListingColors.outlineVariant),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: Text('Show all ${amenities.length} amenities'),
            ),
          ),
        ],
      ],
    );
  }
}
