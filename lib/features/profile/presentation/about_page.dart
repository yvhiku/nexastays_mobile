import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/stays_fee_config.dart';

// =============================================================================
// About Page
// =============================================================================

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: const Color(0xFF1A1A2E),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Overline ──────────────────────────────────────────────────
            Text(
              'ABOUT NEXA STAYS',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE8507A),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            // ── Title ─────────────────────────────────────────────────────
            Text.rich(
              TextSpan(
                text: "Because booking shouldn't feel like ",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                  height: 1.2,
                ),
                children: const [
                  TextSpan(
                    text: 'gambling.',
                    style: TextStyle(color: Color(0xFFE8507A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Subtitle ──────────────────────────────────────────────────
            Text(
              'We built Nexa Stays to solve a real problem — guests getting surprised, hosts getting disputed. Real trust into every step, for both sides.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // ── 2x2 Feature Grid ──────────────────────────────────────────
            const _FeatureGrid(),
            const SizedBox(height: 32),

            // ── Stats Banner ──────────────────────────────────────────────
            const _StatsBanner(),
            const SizedBox(height: 32),

            // ── Problems we solve ─────────────────────────────────────────
            Text(
              'Problems we solve',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),

            const _StepRow(
              emoji: '😮',
              title: 'Property not as advertised',
              description: 'Walkthrough videos let guests verify before booking.',
            ),
            const SizedBox(height: 16),
            _StepRow(
              emoji: '🤔',
              title: 'Double bookings & hidden fees',
              description:
                  'Live availability and a flat ${StaysFeeConfig.instance.guestFeePercentLabel} checkout fee.',
            ),
            const SizedBox(height: 16),
            const _StepRow(
              emoji: '😠',
              title: 'Unfair resolutions',
              description: 'Evidence-based disputes mean fair outcomes.',
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 2×2 feature grid
// ═════════════════════════════════════════════════════════════════════════════

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const List<_Feature> _features = [
    _Feature(
      emoji: '🎬',
      title: 'Verified\nWalkthrough',
      subtitle: 'Face → door → full walkthrough. No surprises on arrival.',
    ),
    _Feature(
      emoji: '🪪',
      title: 'Verified Identity',
      subtitle: 'Real names + ID for guests and hosts. Less fraud.',
    ),
    _Feature(
      emoji: '🔑',
      title: 'Clear Check-in',
      subtitle: 'Know exactly who will meet you before arrival.',
    ),
    _Feature(
      emoji: '⚖️',
      title: 'Fair Protection',
      subtitle: 'Evidence-based resolution — not one-sided policies.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (_, index) => _FeatureCell(feature: _features[index]),
    );
  }
}

class _Feature {
  final String emoji;
  final String title;
  final String subtitle;

  const _Feature({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

class _FeatureCell extends StatelessWidget {
  const _FeatureCell({required this.feature});

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(feature.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          Text(
            feature.title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
               feature.subtitle,
               style: GoogleFonts.dmSans(
                 fontSize: 11,
                 color: const Color(0xFF6B7280),
                 height: 1.4,
               ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Stats Row
// ═════════════════════════════════════════════════════════════════════════════

class _StatsBanner extends StatelessWidget {
  const _StatsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFDE3163), // Pink shade resembling the screenshot
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const _StatItem(value: '3K+', label: 'Waitlist'),
          const _StatDivider(),
          const _StatItem(value: '250+', label: 'Listings'),
          const _StatDivider(),
          const _StatItem(value: '6', label: 'Cities'),
          const _StatDivider(),
          _StatItem(
            value: StaysFeeConfig.instance.guestFeePercentLabel,
            label: 'Guest fee',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Step row list
// ═════════════════════════════════════════════════════════════════════════════

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.emoji,
    required this.title,
    required this.description,
  });

  final String emoji;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Emoji badge
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),

          // Text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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
      ),
    );
  }
}
