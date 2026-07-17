import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../property/presentation/widgets/stay_card.dart';
import '../../domain/entities/property.dart';

/// Featured Deals using the canonical stay card.
class FeaturedStays extends StatelessWidget {
  const FeaturedStays({
    super.key,
    required this.properties,
    required this.onSeeAll,
    required this.onPropertyTap,
    this.title = 'Featured Deals',
  });

  final List<Property> properties;
  final VoidCallback onSeeAll;
  final ValueChanged<Property> onPropertyTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Section header ──────────────────────────────────────────
        _SectionHeader(onSeeAll: onSeeAll, title: title),
        const SizedBox(height: 12),

        // ── Horizontal property cards ───────────────────────────────
        SizedBox(
          height: 330,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: properties.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) => StayCard(
              stay: StayCardData.fromHomeProperty(properties[index]),
              onTap: () => onPropertyTap(properties[index]),
              width: 236,
              compact: true,
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
  const _SectionHeader({required this.onSeeAll, required this.title});

  final VoidCallback onSeeAll;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
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
