import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../navigation/app_routes.dart';
import '../../../domain/entities/property.dart';
import '../../widgets/stay_card.dart';
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
          padding: const EdgeInsets.symmetric(
              horizontal: ListingColors.marginMobile),
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
          height: 330,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: ListingColors.marginMobile),
            itemCount: properties.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final property = properties[index];
              return StayCard(
                stay: StayCardData.fromProperty(property),
                onTap: () =>
                    context.push(AppRoutes.propertyDetailOf(property.id)),
                width: 250,
                compact: true,
              );
            },
          ),
        ),
      ],
    );
  }
}
