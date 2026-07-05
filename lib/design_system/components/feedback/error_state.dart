// =============================================================================
// NexaStays Design System — Error State
// =============================================================================
// Reusable placeholder displayed when a screen or list fails to load due
// to network or server exceptions. Focuses heavily on the retry action.
// =============================================================================

import 'package:flutter/material.dart';

import '../../tokens/colors.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../buttons/secondary_button.dart';

/// A friendly error notification replacing screen content when a failure occurs.
///
/// Features a prominent illustration, a clear error message, and a
/// [SecondaryButton] allowing the user to retry the failed operation.
///
/// ```dart
/// ErrorState(
///   title: 'Connection Lost',
///   message: 'We couldn’t reach the server. Please check your internet.',
///   onRetry: () => ref.refresh(propertiesProvider),
/// )
/// ```
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.title,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Try Again',
    super.key,
  });

  /// The overarching error title (e.g., 'Oops!', 'Connection Lost').
  final String title;

  /// The exact user-friendly error string returned by an [AppException]
  /// or [Failure].
  final String message;

  /// The callback triggered when the user taps to retry.
  final VoidCallback onRetry;

  /// Text displayed on the retry button. Defaults to `'Try Again'`.
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Error: $title. $message',
      hint: 'Double tap the retry button to attempt the action again.',
      child: Center(
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
              // ── Illustration Placeholder ────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DSColors.danger.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.report_problem_rounded,
                  size: 48,
                  color: DSColors.danger,
                ),
              ),
              const SizedBox(height: DSSpacing.l),

              // ── Text Content ──────────────────────────────────────────
              Text(
                title,
                style: DSTypography.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DSSpacing.s),
              Text(
                message,
                style: DSTypography.bodySmall.copyWith(
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              // ── Retry Action ──────────────────────────────────────────
              const SizedBox(height: DSSpacing.xl),
              Semantics(
                button: true,
                label: retryLabel,
                child: SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    label: retryLabel,
                    leading: const Icon(Icons.refresh),
                    onPressed: onRetry,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
