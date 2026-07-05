import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../navigation/app_routes.dart';

// =============================================================================
// Contact Main Page
// =============================================================================

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

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
              'CONTACT',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE8507A),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              "We're here to help",
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),

            // ── Subtitle ──────────────────────────────────────────────────
            Text(
              'We respond within 24 hours, usually faster.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),

            // ── Contact Options ───────────────────────────────────────────
            _ActionCard(
              emoji: '🎧',
              title: 'Customer Support',
              subtitle: 'Booking questions, account help',
              isSelected: true,
              onTap: () => context.push(
                AppRoutes.contactForm,
                extra: 'Support',
              ),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              emoji: '🏢',
              title: 'Partnership (10+ units)',
              subtitle: 'Multi-unit property operators',
              isSelected: false,
              onTap: () => context.push(
                AppRoutes.contactForm,
                extra: 'Partnership',
              ),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              emoji: '📈',
              title: 'Investments & Partnerships',
              subtitle: 'Strategic & investment discussions',
              isSelected: false,
              onTap: () => context.push(
                AppRoutes.contactForm,
                extra: 'Investments',
              ),
            ),
            const SizedBox(height: 32),

            // ── Direct Contacts ───────────────────────────────────────────
            _DirectContactCard(
              title: 'Customer Relations',
              phone: '+212 6 9028 3339',
              onTap: () => launchUrl(Uri.parse('tel:+212690283339')),
            ),
            const SizedBox(height: 12),
            _DirectContactCard(
              title: 'Investments',
              phone: '+7 995 558-21-75',
              onTap: () => launchUrl(Uri.parse('tel:+79955582175')),
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Action Card
// ═════════════════════════════════════════════════════════════════════════════

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F5) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFE8507A) : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8507A) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
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
                    subtitle,
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
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Direct Contact Card
// ═════════════════════════════════════════════════════════════════════════════

class _DirectContactCard extends StatelessWidget {
  const _DirectContactCard({
    required this.title,
    required this.phone,
    required this.onTap,
  });

  final String title;
  final String phone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Color(0xFFE8507A)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              phone,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE8507A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
