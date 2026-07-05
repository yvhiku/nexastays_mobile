// =============================================================================
// NexaStays Design System — Empty State
// =============================================================================
// A visually pleasing placeholder displayed when lists (like favorites,
// bookings, or search results) are empty.
// =============================================================================

import 'package:flutter/material.dart';


import '../../../core/constants/app_assets.dart';
import '../../tokens/colors.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../buttons/primary_button.dart';

/// A friendly placeholder displayed when there's no data to show.
///
/// Wraps an illustration, title, description, and an optional call to action
/// in a vertically centered layout.
///
/// ```dart
/// EmptyState(
///   title: 'No saved stays yet',
///   subtitle: 'Properties you favorite will appear here.',
///   actionLabel: 'Explore Stays',
///   action: () => _goToHome(),
/// )
/// ```
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.subtitle,
    this.assetPath = AppAssets.placeholderProperty,
    this.action,
    this.actionLabel,
    super.key,
  }) : assert(
          (action != null && actionLabel != null) ||
              (action == null && actionLabel == null),
          'Both action and actionLabel must be provided together, or both null.',
        );

  /// The primary headline for the empty state.
  final String title;

  /// Optional explanatory text beneath the title.
  final String? subtitle;

  /// The local asset path for the illustration.
  /// Defaults to [AppAssets.placeholderProperty].
  final String assetPath;

  /// The callback triggered when the user taps the action button.
  final VoidCallback? action;

  /// The text displayed on the action button (e.g. 'Refresh').
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: DSSpacing.paddingAllL,
        margin: DSSpacing.paddingAllM,
        decoration: BoxDecoration(
          color: DSColors.muted,
          borderRadius: BorderRadius.circular(DSSpacing.borderRadius * 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Hug content vertically
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Illustration ───────────────────────────────────────────
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: DSColors.surface,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: DSColors.neutral,
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.l),

            // ── Text Content ──────────────────────────────────────────
            Text(
              title,
              style: DSTypography.heading3,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: DSSpacing.s),
              Text(
                subtitle!,
                style: DSTypography.bodySmall.copyWith(
                  // Slightly tighten the line height for centered text
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // ── Call to Action ────────────────────────────────────────
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: DSSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: actionLabel!,
                  onPressed: action!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
