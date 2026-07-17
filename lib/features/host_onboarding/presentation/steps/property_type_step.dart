import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PropertyTypeStep extends StatelessWidget {
  const PropertyTypeStep({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.listingFlow = false,
  });

  final String? selectedType;
  final ValueChanged<String> onTypeSelected;
  final bool listingFlow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          listingFlow
              ? 'What kind of property is this?'
              : 'What type of host are you?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          listingFlow
              ? 'We will tailor the rooms, pricing, and details to this property.'
              : 'This helps us tailor the setup for you.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: (listingFlow ? _listingOptions : _hostOptions)
                .map(
                  (option) => _HostTypeCard(
                    icon: option.icon,
                    title: option.title,
                    subtitle: option.subtitle,
                    isSelected: selectedType == option.id,
                    onTap: () => onTypeSelected(option.id),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _TypeOption {
  const _TypeOption(this.id, this.icon, this.title, this.subtitle);

  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
}

const _listingOptions = [
  _TypeOption('APARTMENT', Icons.apartment_rounded, 'Apartment',
      'Flat, studio, or residential unit'),
  _TypeOption(
      'VILLA', Icons.villa_rounded, 'Villa', 'Private house and outdoor space'),
  _TypeOption(
      'RIAD', Icons.balcony_rounded, 'Riad', 'Entire riad, rooms, or both'),
  _TypeOption(
      'HOTEL', Icons.hotel_rounded, 'Hotel', 'Room categories and inventory'),
  _TypeOption('HOSTEL', Icons.bed_rounded, 'Hostel',
      'Dorm beds, private rooms, or both'),
];

const _hostOptions = [
  _TypeOption('individual', Icons.home_rounded, 'Individual', '1–4 properties'),
  _TypeOption(
      'portfolio', Icons.business_rounded, 'Portfolio', '5–9 properties'),
  _TypeOption('hotel', Icons.hotel_rounded, 'Hotel / Hostel', 'Full property'),
  _TypeOption('partner', Icons.handshake_rounded, 'Partner', '10+ units'),
];

class _HostTypeCard extends StatelessWidget {
  const _HostTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
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
            color:
                isSelected ? const Color(0xFFE8507A) : const Color(0xFFE5E7EB),
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected
                  ? const Color(0xFFE8507A)
                  : const Color(0xFF6B7280),
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
