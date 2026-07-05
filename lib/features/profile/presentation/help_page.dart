import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/stays_fee_config.dart';

// =============================================================================
// Help & Support Page
// =============================================================================

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),

          // ── Contact cards ──────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ContactCard(
                  emoji: '📧',
                  title: 'Email us',
                  subtitle: 'support@nexastays.ma',
                  onTap: () => launchUrl(
                    Uri.parse('mailto:support@nexastays.ma'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ContactCard(
                  emoji: '📞',
                  title: 'Call us',
                  subtitle: '+212 6 90 28 33 39',
                  onTap: () => launchUrl(
                    Uri.parse('tel:+212690283339'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ContactCard(
                  emoji: '💬',
                  title: 'WhatsApp',
                  subtitle: 'Chat with us',
                  onTap: () => launchUrl(
                    Uri.parse('https://wa.me/212690283339'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ),
            ],
          ),

          // ── FAQ section ────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(top: 24, bottom: 8),
            child: Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),

          ..._faqs.map((faq) => _FaqTile(
                question: faq.$1,
                answer: faq.$2,
              )),

          // ── Report an issue ────────────────────────────────────
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              border: Border.all(color: const Color(0xFFFECACA)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚨 Report a serious issue',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Safety concern, fraud, or abuse',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => launchUrl(
                    Uri.parse('mailto:safety@nexastays.ma'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'Report now →',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── FAQ data ───────────────────────────────────────────────────────

  static List<(String, String)> get _faqs {
    final c = StaysFeeConfig.instance;
    final guest = c.guestFeePercentLabel;
    final host = c.hostFeePercentLabel;
    final total = c.totalCommissionPercentLabel;
    final example = c.calculateFees(600);
    return [
      (
        'How does the $guest fee work?',
        'NexaStays charges a $guest service fee to guests and a $host platform '
            'fee to hosts, totalling $total per booking. Example: a 600 MAD/night booking '
            'means guests pay ${example.totalGuestPays.toInt()} MAD and hosts receive ${example.hostPayout.toInt()} MAD.',
      ),
    (
      'When do I get the exact address?',
      'For your safety, the exact address and check-in contact are '
          'shared immediately after your booking is confirmed — not before. '
          'Until then, the neighborhood and city are shown.',
    ),
    (
      'How does identity verification work?',
      'All users must verify their identity before booking or hosting. '
          "You'll upload a government-issued ID (CNIE, passport, or "
          'driving license) and take a selfie. Our team reviews and '
          'approves within a few hours.',
    ),
    (
      'What is a verified walkthrough video?',
      'Every listing must have a video recorded in a specific sequence: '
          'face on camera → exterior door → full interior walkthrough. '
          'This ensures the property matches its description.',
    ),
    (
      'How do I open a dispute?',
      'Go to My Bookings → find your completed booking → tap '
          "'Open a dispute'. Submit your evidence and description. "
          'We review within 24–48 hours.',
    ),
    (
      'Can I cancel my booking?',
      'Free cancellation is available more than 24 hours before '
          'check-in. Within 24 hours, the first night is non-refundable.',
    ),
    (
      'How do I become a host?',
      "Tap 'Become a Host' from your profile. Complete the 11-step "
          'listing process including identity verification, property '
          'photos, and a verified walkthrough video.',
    ),
  ];
  }
}

// =============================================================================
// Contact Card
// =============================================================================

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F5),
          border: Border.all(color: const Color(0xFFFFB3C1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// FAQ Tile
// =============================================================================

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: const Color(0xFF9CA3AF),
        collapsedIconColor: const Color(0xFF9CA3AF),
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF1A1A2E),
          ),
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
