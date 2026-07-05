import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/host_preferences.dart';

class HostRulesSection extends StatelessWidget {
  const HostRulesSection({super.key, required this.rules});

  final HostPreferences rules;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'House rules',
          style: GoogleFonts.playfairDisplay(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),

        // ── Check-in / Check-out Row ──────────────────────────────────
        Row(
          children: [
            _buildTimeBadge('Check-in: ${rules.checkInFrom}'),
            const SizedBox(width: 8),
            _buildTimeBadge('Check-out: ${rules.checkOutBefore}'),
          ],
        ),
        const SizedBox(height: 16),

        // ── Rules List ───────────────────────────────────────────────
        _buildRuleRow('👥', 'Max guests: ${rules.maxGuests}'),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        
        _buildRuleRow('🕙', 'Quiet hours: ${rules.quietHoursFrom} – ${rules.quietHoursUntil}'),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),

        if (!rules.petsAllowed) ...[
          _buildRuleRow('🚫🐾', 'No pets'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
        ] else ...[
          _buildRuleRow('🐾', 'Pets welcome'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
        ],

        if (!rules.smokingAllowed) ...[
          _buildRuleRow('🚭', 'No smoking'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
        ] else ...[
          _buildRuleRow('🚬', 'Smoking area available'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
        ],

        if (!rules.eventsAllowed) ...[
          _buildRuleRow('🎉🚫', 'No parties or events'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
        ],

        if (rules.suitableForInfants) ...[
          _buildRuleRow('👶', 'Suitable for infants'),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
        ],

        // ── Additional Rules ─────────────────────────────────────────
        if (rules.additionalRules != null && rules.additionalRules!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional rules:',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rules.additionalRules!,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        border: Border.all(color: const Color(0xFFBAE6FD)),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0369A1),
        ),
      ),
    );
  }

  Widget _buildRuleRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
