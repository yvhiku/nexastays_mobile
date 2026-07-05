import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/stays_fee_config.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── SECTION LABEL ──
        Text(
          'HOW IT WORKS',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE8507A),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),

        // ── TITLE & SUBTITLE ──
        Text(
          'Simple to book.\nSerious about trust.',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'No confusion, no double bookings, no surprises.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 20),

        // ── 3 NUMBERED STEPS ──
        _buildStepItem(
          number: 1,
          title: 'Search and choose',
          description: 'Find stays with verified walkthrough videos and clear rules.',
        ),
        const SizedBox(height: 20),
        _buildStepItem(
          number: 2,
          title: 'Book instantly',
          description: 'Availability is real-time. No double booking. No hidden fees.',
        ),
        const SizedBox(height: 20),
        _buildStepItem(
          number: 3,
          title: 'Arrive with confidence',
          description: 'Exact location + check-in contact shared after confirmation.',
        ),
        const SizedBox(height: 16),

        // ── CONFIRMATION CARD ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-in confirmed',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Contact details shared · Meet at 14:00',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Divider(color: Color(0xFFE5E7EB), height: 1),
        const SizedBox(height: 24),

        // ── "WHY NEXA STAYS?" HEADER ──
        Text(
          'WHY NEXA STAYS?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),

        // ── 2x2 FEATURE GRID ──
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1, // Adjust as necessary for content fit
          children: [
            _buildFeatureCell(
              emoji: '🎥',
              title: 'Verified Walkthrough',
              subtitle: 'Real video — face · door · full tour.',
            ),
            _buildFeatureCell(
              emoji: '🪪',
              title: 'Verified Identity',
              subtitle: 'Real names + ID. Less fraud.',
            ),
            _buildFeatureCell(
              emoji: '🔑',
              title: 'Fair Pricing',
              subtitle: '${StaysFeeConfig.instance.guestFeePercentLabel} fee only. No surprises.',
            ),
            _buildFeatureCell(
              emoji: '⚖️',
              title: 'Fair Disputes',
              subtitle: 'Evidence-based resolution.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required int number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFE8507A),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number.toString(),
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCell({
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              subtitle,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
