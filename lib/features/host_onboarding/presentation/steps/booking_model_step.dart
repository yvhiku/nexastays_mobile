import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../listing_wizard/listing_step_config.dart';

class BookingModelStep extends StatelessWidget {
  const BookingModelStep({
    super.key,
    required this.propertyType,
    required this.selectedModel,
    required this.onSelected,
  });

  final String propertyType;
  final String? selectedModel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = bookingModelOptions(propertyType);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How can guests book?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            propertyType == 'HOSTEL'
                ? 'Choose dorm beds, private rooms, or both.'
                : propertyType == 'HOTEL'
                    ? 'Hotels are organized by room type and quantity.'
                    : 'Choose the booking structure that matches your property.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onSelected(option.id),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selectedModel == option.id
                        ? const Color(0xFFFFF0F5)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selectedModel == option.id
                          ? const Color(0xFFE8507A)
                          : const Color(0xFFE5E7EB),
                      width: selectedModel == option.id ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedModel == option.id
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selectedModel == option.id
                            ? const Color(0xFFE8507A)
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option.subtitle,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
