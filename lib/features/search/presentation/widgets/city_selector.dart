import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/components/buttons/pill_button.dart';
import '../../../../core/constants/stays_image_assets.dart';

/// Bottom-sheet city picker with a 2-column image grid.
///
/// Usage:
/// ```dart
/// final city = await CitySelector.show(context, current: 'Marrakech');
/// ```
class CitySelector extends StatefulWidget {
  const CitySelector({
    super.key,
    required this.selectedCity,
    required this.onCitySelected,
  });

  final String? selectedCity;
  final ValueChanged<String> onCitySelected;

  // ── Static launcher ─────────────────────────────────────────────────────

  /// Shows the city selector as a modal bottom sheet and returns
  /// the chosen city name, or `null` if dismissed.
  static Future<String?> show(BuildContext context, {String? current}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        String? selected = current;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return CitySelector(
              selectedCity: selected,
              onCitySelected: (city) {
                setModalState(() => selected = city);
              },
            );
          },
        );
      },
    );
  }

  @override
  State<CitySelector> createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  late String? _selected = widget.selectedCity;

  // ── City data ───────────────────────────────────────────────────────────

  static final List<DestinationCityAsset> _cities =
      StaysImageAssets.destinationCities;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle bar ──────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Title ───────────────────────────────────────────────────
          Text(
            'Where to?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 20),

          // ── City grid ───────────────────────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cities.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (_, index) {
              final city = _cities[index];
              final isSelected = _selected == city.name;
              return _CityCard(
                city: city,
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selected = city.name);
                  widget.onCitySelected(city.name);
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // ── Confirm button ──────────────────────────────────────────
          NexaPillButton(
            label: 'Confirm',
            enabled: _selected != null,
            onTap: _selected != null
                ? () => Navigator.of(context).pop(_selected)
                : null,
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Single city card
// ═════════════════════════════════════════════════════════════════════════════

class _CityCard extends StatelessWidget {
  const _CityCard({
    required this.city,
    required this.isSelected,
    required this.onTap,
  });

  final DestinationCityAsset city;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: const Color(0xFFE8507A), width: 2.5)
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // City image
            Image.asset(
              city.assetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.location_city, color: Colors.white54),
              ),
            ),

            // Dark overlay
            Container(
              color: isSelected
                  ? const Color(0xFFE8507A).withValues(alpha: 0.20)
                  : Colors.black.withValues(alpha: 0.40),
            ),

            // City name
            Center(
              child: Text(
                city.name,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
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
