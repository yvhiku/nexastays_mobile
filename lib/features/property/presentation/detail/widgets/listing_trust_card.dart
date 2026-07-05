import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../listing/listing_colors.dart';

class ListingTrustCard extends StatelessWidget {
  const ListingTrustCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ListingColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: ListingColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield,
                  color: ListingColors.onPrimaryContainer,
                  size: 20,
                  fill: 1,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Nexa Trust Guarantee',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ListingColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TrustItem(
            text: 'Identity of the host has been fully verified.',
          ),
          const SizedBox(height: 12),
          _TrustItem(
            text: 'Secure payment protection through Nexa Pay.',
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle,
          size: 20,
          color: ListingColors.tertiary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              height: 1.5,
              color: ListingColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
