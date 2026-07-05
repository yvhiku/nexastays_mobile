import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/stays_image_assets.dart';

/// "Choose your vibe" — horizontal scrollable destination cards.
///
/// Uses the same local artwork as nexastays_web (`images/assets/`).
class DestinationCards extends StatelessWidget {
  const DestinationCards({super.key, required this.onVibeTap});

  final ValueChanged<String> onVibeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Choose your vibe',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: StaysImageAssets.vibeCards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final vibe = StaysImageAssets.vibeCards[index];
              return _VibeCard(
                vibe: vibe,
                onTap: () => onVibeTap(vibe.tag),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VibeCard extends StatelessWidget {
  const _VibeCard({required this.vibe, required this.onTap});

  final VibeCardAsset vibe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              vibe.assetPath,
              fit: BoxFit.cover,
              alignment: vibe.alignment,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image, size: 20, color: Colors.white54),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xA6000000),
                  ],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Text(
                vibe.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
