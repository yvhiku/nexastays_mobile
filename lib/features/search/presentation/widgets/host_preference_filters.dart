import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/search_filter.dart';
import '../bloc/filters_cubit.dart';
import 'filter_chip.dart';

/// Filter section for guest type, price range, and minimum beds.
///
/// Reads from [currentFilter] and calls setters on [cubit] when
/// the user interacts with the controls.
class HostPreferenceFilters extends StatelessWidget {
  const HostPreferenceFilters({
    super.key,
    required this.currentFilter,
    required this.cubit,
  });

  final SearchFilter currentFilter;
  final FiltersCubit cubit;

  // ── Constants ───────────────────────────────────────────────────────────

  static const double _priceMin = 200;
  static const double _priceMax = 5000;

  static const List<String> _guestTypes = [
    'Solo',
    'Couples',
    'Family',
    'Business',
  ];

  static const List<_BedOption> _bedOptions = [
    _BedOption(label: '1', value: 1),
    _BedOption(label: '2', value: 2),
    _BedOption(label: '3', value: 3),
    _BedOption(label: '4+', value: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Guest type ────────────────────────────────────────────────
        _sectionLabel('Guest type'),
        const SizedBox(height: 10),
        _buildGuestTypeChips(),
        const SizedBox(height: 24),

        // ── Price range ───────────────────────────────────────────────
        _sectionLabel('Price range (MAD)'),
        const SizedBox(height: 6),
        _buildPriceLabel(),
        _buildPriceSlider(),
        const SizedBox(height: 24),

        // ── Minimum beds ──────────────────────────────────────────────
        _sectionLabel('Minimum beds'),
        const SizedBox(height: 10),
        _buildBedSelector(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Guest type chips
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildGuestTypeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _guestTypes.map((type) {
        final tag = type.toLowerCase();
        final isActive = currentFilter.guestType == tag;
        return GestureDetector(
          onTap: () => cubit.setGuestType(isActive ? null : tag),
          child: Container(
            height: NexaFilterChip.chipHeight,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFFF0F5) : Colors.white,
              border: Border.all(
                color: isActive
                    ? const Color(0xFFE8507A)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              type,
              textHeightBehavior: NexaFilterChip.chipTextHeight,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                height: 1,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? const Color(0xFFE8507A)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Price range
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPriceLabel() {
    final fmt = NumberFormat('#,###');
    final low = fmt.format((currentFilter.minPrice ?? _priceMin).toInt());
    final high = fmt.format((currentFilter.maxPrice ?? _priceMax).toInt());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '$low MAD — $high MAD',
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  Widget _buildPriceSlider() {
    return SliderTheme(
      data: const SliderThemeData(
        activeTrackColor: Color(0xFFE8507A),
        inactiveTrackColor: Color(0xFFE5E7EB),
        thumbColor: Color(0xFFE8507A),
        overlayColor: Color(0x29E8185E),
        trackHeight: 3,
      ),
      child: RangeSlider(
        min: _priceMin,
        max: _priceMax,
        divisions: 48,
        values: RangeValues(
          currentFilter.minPrice ?? _priceMin,
          currentFilter.maxPrice ?? _priceMax,
        ),
        onChanged: (values) {
          cubit.setPriceRange(values.start, values.end);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Minimum beds
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBedSelector() {
    return Row(
      children: _bedOptions.map((opt) {
        final isSelected = currentFilter.minBeds == opt.value;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => cubit.setMinBeds(
              isSelected ? 0 : opt.value,
            ),
            child: Container(
              width: 48,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8507A) : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE8507A)
                      : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                opt.label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A2E),
      ),
    );
  }
}

// ── Bed option data ─────────────────────────────────────────────────────────

class _BedOption {
  final String label;
  final int value;

  const _BedOption({required this.label, required this.value});
}
