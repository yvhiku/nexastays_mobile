// =============================================================================
// NexaStays Onboarding Slide
// =============================================================================
// A single, reusable onboarding page with an illustration, title, and
// description. Designed to be used inside a PageView.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';

/// A single onboarding slide that displays an [image], [title], and
/// [description] in a vertically centred column.
///
/// ```dart
/// OnboardingSlide(
///   image: 'assets/images/onboarding/discover.png',
///   title: 'Discover Unique Stays',
///   description: 'Explore hand-picked homes, riads, and villas.',
/// )
/// ```
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  /// Asset path for the illustration image.
  final String image;

  /// Large heading displayed below the illustration.
  final String title;

  /// Supporting paragraph displayed below the title.
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Illustration ─────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                top: DSSpacing.xl,
                bottom: DSSpacing.m,
                left: DSSpacing.l,
                right: DSSpacing.l,
              ),
              decoration: BoxDecoration(
                color: DSColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: DSColors.primary.withValues(alpha: 0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              // Wrap image in ClipRRect so it is actually cropped by the container's shape
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover, // Fill the whole rounded shape
                ),
              ),
            ),
          ),

          // ── Title ────────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  title,
                  style: DSTypography.heading1.copyWith(
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: DSSpacing.m),

                // ── Description ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.s),
                  child: Text(
                    description,
                    style: DSTypography.bodyLarge.copyWith(
                      // DSColors.muted is a background color, not text!
                      color: DSColors.neutral.withValues(alpha: 0.6),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
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
