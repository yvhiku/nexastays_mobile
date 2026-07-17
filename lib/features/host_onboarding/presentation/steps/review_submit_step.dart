import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/host_onboarding_state.dart';

class ReviewSubmitStep extends StatelessWidget {
  const ReviewSubmitStep({
    super.key,
    required this.state,
    required this.onSubmit,
    required this.isSubmitting,
    required this.onEditStep,
  });

  /// The current state of the onboarding block to derive checklist completion.
  final HostOnboardingState state;

  /// Callback when the Submit button is pressed.
  final VoidCallback onSubmit;

  /// True if the submission request is in-flight.
  final bool isSubmitting;

  /// Callback to jump the user back to a previous step if it's incomplete.
  final ValueChanged<int> onEditStep;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final kycVerified =
        authState is AuthAuthenticated && authState.user.isVerified;

    // Determine checklist status dynamically from state
    final bool hostIdVerified = kycVerified;
    final bool photosReady = state.photoPaths.length >= 12; // Step 9
    final bool videoReady =
        state.videoPath != null && state.videoPath!.isNotEmpty; // Step 10
    final bool pricingSet = state.nightlyRate != null; // Step 7
    final bool checkInReady = state.isListingFlow
        ? state.checkInMethod?.isNotEmpty == true
        : state.checkInContact?.isNotEmpty == true;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit your listing',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your checklist before going live.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),

          // ── CHECKLIST ──
          _buildChecklistRow(
            label: state.isListingFlow
                ? 'Host account verified'
                : 'Identity verified (Nexa KYC)',
            isComplete: hostIdVerified,
            onTap: () => onEditStep(state.isListingFlow ? 1 : 2),
          ),
          const SizedBox(height: 12),
          _buildChecklistRow(
            label: 'Photos uploaded (12 minimum)',
            isComplete: photosReady,
            onTap: () => onEditStep(9),
          ),
          const SizedBox(height: 12),
          _buildChecklistRow(
            label: 'Walkthrough video uploaded',
            isComplete: videoReady,
            onTap: () => onEditStep(10),
          ),
          const SizedBox(height: 12),
          _buildChecklistRow(
            label: 'Pricing set',
            isComplete: pricingSet,
            onTap: () => onEditStep(7),
          ),
          const SizedBox(height: 12),
          _buildChecklistRow(
            label: 'House rules set',
            // Or use state.stepValidation[6] ?? false
            isComplete: state.stepValidation[6] ?? false,
            onTap: () => onEditStep(6),
          ),
          const SizedBox(height: 12),
          _buildChecklistRow(
            label: 'Check-in contact added',
            isComplete: checkInReady,
            onTap: () => onEditStep(8),
          ),
          const SizedBox(height: 32),

          // ── INFO BANNER ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 20, color: Color(0xFF6B7280)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'After submission, your listing is reviewed by Nexa. '
                    'You\'ll be notified once approved and ready to go live.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // ── SUBMIT BUTTON (Only shown here if omitted from shell bottom bar,
          //                 or as an explicit call to action if shell bar changes) ──
          //                 Per instructions, it's explicitly rendered.
          GestureDetector(
            onTap: state.allRequiredComplete && !isSubmitting ? onSubmit : null,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: state.allRequiredComplete
                    ? const LinearGradient(
                        colors: [Color(0xFFE8507A), Color(0xFFED4B82)],
                      )
                    : null,
                color:
                    state.allRequiredComplete ? null : const Color(0xFFF3F4F6),
              ),
              alignment: Alignment.center,
              child: isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      '🚀 Submit for Review',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: state.allRequiredComplete
                            ? Colors.white
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChecklistRow({
    required String label,
    required bool isComplete,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isComplete ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isComplete ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isComplete ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
          ),
        ),
        child: Row(
          children: [
            Text(
              isComplete ? '✅' : '🔒',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isComplete
                      ? const Color(0xFF166534)
                      : const Color(0xFFb45309), // Darker amber for readability
                ),
              ),
            ),
            if (!isComplete)
              Text(
                'Fix',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF59E0B),
                  decoration: TextDecoration.underline,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
