import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/stays_image_assets.dart';

class TrendingDestinations extends StatelessWidget {
  const TrendingDestinations({
    super.key,
    required this.destinations,
    required this.counts,
    required this.onDestinationTap,
  });

  final List<String> destinations;
  final Map<String, int> counts;
  final ValueChanged<String> onDestinationTap;

  @override
  Widget build(BuildContext context) {
    final cities = _orderedCities();
    if (cities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trending destinations',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Morocco is calling. Pick a city and start exploring.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final city = cities[index];
              return _DestinationCard(
                city: city,
                count: counts[city] ?? 0,
                onTap: () => onDestinationTap(city),
              );
            },
          ),
        ),
      ],
    );
  }

  List<String> _orderedCities() {
    const curated = [
      'Casablanca',
      'Marrakech',
      'Agadir',
      'Tangier',
      'Fez',
      'Taghazout',
      'Chefchaouen',
    ];
    final available = <String>{...destinations};
    final ordered = <String>[
      ...curated.where((city) =>
          available.any((value) => value.toLowerCase() == city.toLowerCase())),
      ...destinations.where((city) =>
          !curated.any((value) => value.toLowerCase() == city.toLowerCase())),
    ];
    return ordered.take(7).toList();
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.city,
    required this.count,
    required this.onTap,
  });

  final String city;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final asset =
        StaysImageAssets.cityAssetPath(city) ?? StaysImageAssets.casablanca;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 154,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(asset, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC111827)],
                    stops: [0.35, 1],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$count ${count == 1 ? 'stay' : 'stays'}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.84),
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
