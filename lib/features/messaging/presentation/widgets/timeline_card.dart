import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/tokens/colors.dart';
import '../../domain/entities/message.dart';

class TimelineCard extends StatelessWidget {
  const TimelineCard({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final metadata = message.metadata;
    final title = metadata['title'] as String? ??
        metadata['kind'] as String? ??
        _defaultTitle(message.type);
    final body = message.body ?? metadata['body'] as String?;
    final iconName = metadata['icon'] as String?;
    final actions = metadata['actions'] as List<dynamic>? ?? const [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: DSColors.background2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DSColors.line),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _iconFor(iconName, message.type),
                        size: 20,
                        color: DSColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: DSColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (body != null && body.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      body,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: DSColors.ink3,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: actions.map((action) {
                        final map = action as Map<String, dynamic>;
                        final label = map['label'] as String? ?? 'Open';
                        return OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DSColors.primary,
                            side: const BorderSide(color: DSColors.line),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(label),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _defaultTitle(String type) => switch (type) {
        'BOOKING_CARD' => 'Booking details',
        'PROPERTY_CARD' => 'Property',
        'SYSTEM_EVENT' => 'Update',
        _ => 'Message',
      };

  IconData _iconFor(String? iconName, String type) {
    if (iconName != null) {
      return switch (iconName) {
        'calendar' => Icons.calendar_today_outlined,
        'home' => Icons.home_outlined,
        'check' => Icons.check_circle_outline,
        _ => Icons.info_outline,
      };
    }
    return switch (type) {
      'BOOKING_CARD' => Icons.receipt_long_outlined,
      'PROPERTY_CARD' => Icons.home_outlined,
      _ => Icons.info_outline,
    };
  }
}
