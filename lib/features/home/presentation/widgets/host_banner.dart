import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/components/buttons/pill_button.dart';

/// Dark gradient banner prompting users to become a host.
///
/// Layout: rounded card with a left text column ("Become a Host",
/// subtitle, CTA button) and a right house emoji.
class HostBanner extends StatelessWidget {
  const HostBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF2D1B35)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          // ── Left text column ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Become a Host',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Earn with your property.',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 12),

                // CTA button
                NexaPillButton(
                  label: 'Get Started →',
                  onTap: onTap,
                  expandWidth: false,
                  height: 36,
                  fontSize: 12,
                  gradient: null,
                  backgroundColor: const Color(0xFFE8507A),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Right illustration ────────────────────────────────────
          const Text(
            '🏠',
            style: TextStyle(fontSize: 52),
          ),
        ],
      ),
    );
  }
}
