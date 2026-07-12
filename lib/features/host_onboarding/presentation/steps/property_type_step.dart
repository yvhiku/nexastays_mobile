import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PropertyTypeStep extends StatelessWidget {
  const PropertyTypeStep({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  /// The currently selected host type ('individual', 'portfolio', 'hotel', 'partner').
  final String? selectedType;

  /// Callback when a type is selected.
  final ValueChanged<String> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What type of host are you?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us tailor the setup for you.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 32),

        // 2x2 Grid of Host Type Cards
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                // Adjust ratio based on typical tablet/desktop layout
                childAspectRatio: constraints.maxWidth /
                    (constraints.maxHeight > 0
                        ? constraints.maxHeight
                        : constraints.maxWidth),
                children: [
                  _HostTypeCard(
                    id: 'individual',
                    emoji: '🏠',
                    title: 'Individual',
                    subtitle: '1–4 properties',
                    isSelected: selectedType == 'individual',
                    onTap: () => onTypeSelected('individual'),
                  ),
                  _HostTypeCard(
                    id: 'portfolio',
                    emoji: '🏢',
                    title: 'Portfolio',
                    subtitle: '5–9 properties',
                    isSelected: selectedType == 'portfolio',
                    onTap: () => onTypeSelected('portfolio'),
                  ),
                  _HostTypeCard(
                    id: 'hotel',
                    emoji: '🏨',
                    title: 'Hotel / Hostel',
                    subtitle: 'Full property',
                    isSelected: selectedType == 'hotel',
                    onTap: () => onTypeSelected('hotel'),
                  ),
                  _HostTypeCard(
                    id: 'partner',
                    emoji: '🤝',
                    title: 'Partner',
                    subtitle: '10+ units',
                    isSelected: selectedType == 'partner',
                    onTap: () => onTypeSelected('partner'),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HostTypeCard extends StatelessWidget {
  const _HostTypeCard({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFE8507A) : const Color(0xFFE5E7EB),
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
