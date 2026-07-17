import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/stays_image_assets.dart';

/// Large, poster-like discovery cards. About two are visible at a time.
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
          'Find your vibe',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 136,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _discoverVibes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final vibe = _discoverVibes[index];
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

  final _DiscoverVibe vibe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.43,
        height: 136,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                vibe.assetPath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child:
                      const Icon(Icons.image, size: 20, color: Colors.white54),
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
                    stops: [0.3, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Row(
                  children: [
                    Icon(vibe.icon, size: 22, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vibe.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoverVibe {
  const _DiscoverVibe({
    required this.label,
    required this.tag,
    required this.assetPath,
    required this.icon,
  });

  final String label;
  final String tag;
  final String assetPath;
  final IconData icon;
}

const _discoverVibes = [
  _DiscoverVibe(
    label: 'Beach escapes',
    tag: 'ocean',
    assetPath: StaysImageAssets.oceanView,
    icon: Icons.beach_access_rounded,
  ),
  _DiscoverVibe(
    label: 'City stays',
    tag: 'city',
    assetPath: StaysImageAssets.rooftopRiad,
    icon: Icons.location_city_rounded,
  ),
  _DiscoverVibe(
    label: 'Mountain calm',
    tag: 'mountain',
    assetPath: StaysImageAssets.cozy,
    icon: Icons.landscape_rounded,
  ),
  _DiscoverVibe(
    label: 'Desert nights',
    tag: 'desert',
    assetPath: StaysImageAssets.riadMagic,
    icon: Icons.wb_sunny_outlined,
  ),
  _DiscoverVibe(
    label: 'Country homes',
    tag: 'farm',
    assetPath: StaysImageAssets.familyReady,
    icon: Icons.cottage_outlined,
  ),
  _DiscoverVibe(
    label: 'Quiet luxury',
    tag: 'luxury',
    assetPath: StaysImageAssets.luxury,
    icon: Icons.diamond_outlined,
  ),
];
