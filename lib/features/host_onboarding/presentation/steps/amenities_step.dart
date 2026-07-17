import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmenitiesStep extends StatelessWidget {
  const AmenitiesStep({
    super.key,
    required this.selectedAmenities,
    required this.onChanged,
  });

  /// The list of currently selected amenity tags String.
  final List<String> selectedAmenities;

  /// Callback when an amenity is toggled or 'select all' is updated.
  final ValueChanged<List<String>> onChanged;

  static const List<Map<String, String>> _essentials = [
    {'emoji': '🌐', 'label': 'WiFi', 'tag': 'wifi'},
    {'emoji': '🅿️', 'label': 'Parking', 'tag': 'parking'},
    {'emoji': '❄️', 'label': 'Air con', 'tag': 'ac'},
    {'emoji': '🔥', 'label': 'Heating', 'tag': 'heating'},
    {'emoji': '🫧', 'label': 'Hot water', 'tag': 'hot_water'},
    {'emoji': '🍳', 'label': 'Kitchen', 'tag': 'kitchen'},
  ];

  static const List<Map<String, String>> _extras = [
    {'emoji': '🧺', 'label': 'Washing machine', 'tag': 'washing_machine'},
    {'emoji': '📺', 'label': 'TV', 'tag': 'tv'},
    {'emoji': '🏊', 'label': 'Pool', 'tag': 'pool'},
    {'emoji': '🛗', 'label': 'Elevator', 'tag': 'elevator'},
    {'emoji': '♿', 'label': 'Accessible', 'tag': 'accessible'},
    {'emoji': '🐾', 'label': 'Pets OK', 'tag': 'pets'},
    {'emoji': '🚬', 'label': 'Smoking area', 'tag': 'smoking'},
    {'emoji': '🧹', 'label': 'Daily cleaning', 'tag': 'cleaning'},
    {'emoji': '🔒', 'label': 'Safe box', 'tag': 'safe'},
    {'emoji': '☕', 'label': 'Coffee', 'tag': 'coffee'},
    {'emoji': '🏋️', 'label': 'Gym', 'tag': 'gym'},
    {'emoji': '🌿', 'label': 'Garden/terrace', 'tag': 'garden'},
  ];

  void _toggleAmenity(String tag) {
    final newList = List<String>.from(selectedAmenities);
    if (newList.contains(tag)) {
      newList.remove(tag);
    } else {
      newList.add(tag);
    }
    onChanged(newList);
  }

  void _toggleAllEssentials(bool select) {
    final newList = List<String>.from(selectedAmenities);
    for (final item in _essentials) {
      final tag = item['tag']!;
      if (select && !newList.contains(tag)) {
        newList.add(tag);
      } else if (!select && newList.contains(tag)) {
        newList.remove(tag);
      }
    }
    onChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    final bool allEssentialsSelected = _essentials.every(
      (item) => selectedAmenities.contains(item['tag']),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STEP 6 OF 11',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE8507A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What does your place offer?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all amenities available to guests.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // ── ESSENTIALS SECTION ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Essentials',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Select all essentials',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 24,
                    width: 40,
                    child: Switch(
                      value: allEssentialsSelected,
                      onChanged: _toggleAllEssentials,
                      activeColor: const Color(0xFFE8507A),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGrid(_essentials),
          const SizedBox(height: 24),

          // ── EXTRAS SECTION ──
          Text(
            'Extras',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          _buildGrid(_extras),
          const SizedBox(height: 24),

          // ── COUNTER BELOW GRID ──
          Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Color(0xFFE8507A), size: 16),
              const SizedBox(width: 6),
              Text(
                '${selectedAmenities.length} amenities selected',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE8507A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Map<String, String>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 80, // strict 80px height per spec
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final tag = item['tag']!;
        final isSelected = selectedAmenities.contains(tag);

        return GestureDetector(
          onTap: () => _toggleAmenity(tag),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF0F5) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFE8507A)
                    : const Color(0xFFE5E7EB),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['emoji']!,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        item['label']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFFE8507A)
                              : const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8507A),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
