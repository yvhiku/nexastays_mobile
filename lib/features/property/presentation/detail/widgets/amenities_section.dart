import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmenitiesSection extends StatelessWidget {
  const AmenitiesSection({super.key, required this.amenities});

  final List<String> amenities;

  static const Map<String, String> _amenityEmojis = {
    'WiFi': '🌐',
    'Parking': '🅿️',
    'Air con': '❄️',
    'Heating': '🔥',
    'Hot water': '🫧',
    'Kitchen': '🍳',
    'Washing machine': '🧺',
    'TV': '📺',
    'Pool': '🏊',
    'Elevator': '🛗',
    'Accessible': '♿',
    'Pets OK': '🐾',
    'Smoking area': '🚬',
    'Daily cleaning': '🧹',
    'Safe box': '🔒',
    'Coffee': '☕',
    'Gym': '🏋️',
    'Garden': '🌿',
  };

  void _showAllAmenities(BuildContext context, List<String> available, List<String> unavailable) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          initialChildSize: 0.6,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'What this place offers',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        if (available.isNotEmpty) ...[
                          Text(
                            'Available',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...available.map((a) => _buildAmenityTile(a, true)),
                          const SizedBox(height: 24),
                        ],
                        if (unavailable.isNotEmpty) ...[
                          Text(
                            'Not included',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...unavailable.map((a) => _buildAmenityTile(a, false)),
                        ],
                      ],
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

  Widget _buildAmenityTile(String name, bool isAvailable) {
    final emoji = _amenityEmojis[name] ?? '✨';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 24, // Slightly larger for the list
              color: isAvailable ? null : Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: isAvailable ? const Color(0xFF1A1A2E) : const Color(0xFF9CA3AF),
                decoration: isAvailable ? TextDecoration.none : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine available and unavailable
    final available = _amenityEmojis.keys.where((k) => amenities.contains(k)).toList();
    final unavailable = _amenityEmojis.keys.where((k) => !amenities.contains(k)).toList();

    // Limit grid to 8 items total. Prioritize available, then fill with up to 3 unavailable.
    List<Widget> gridItems = [];
    int count = 0;

    for (final am in available) {
      if (count >= 8) break;
      gridItems.add(_buildGridItem(am, true));
      count++;
    }

    int unavailableCount = 0;
    for (final am in unavailable) {
      if (count >= 8 || unavailableCount >= 3) break;
      gridItems.add(_buildGridItem(am, false));
      count++;
      unavailableCount++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What this place offers',
          style: GoogleFonts.playfairDisplay(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 5, // Width/Height ratio to make them look like rows
          children: gridItems,
        ),
        if (amenities.length > 8) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showAllAmenities(context, available, unavailable),
            child: Text(
              'Show all ${amenities.length} amenities',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE8507A),
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFFE8507A),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGridItem(String name, bool isAvailable) {
    final emoji = _amenityEmojis[name] ?? '✨';

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.4,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF374151),
                decoration: isAvailable ? TextDecoration.none : TextDecoration.lineThrough,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
