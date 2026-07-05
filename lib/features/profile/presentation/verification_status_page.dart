import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/app_routes.dart';
import '../../identity_verification/domain/entities/verification.dart';
import '../../identity_verification/presentation/widgets/verification_checklist_row.dart';
import 'bloc/profile_cubit.dart';
import 'bloc/profile_state.dart';

// =============================================================================
// Verification Status Page (Profile Section — read-only)
// =============================================================================

class VerificationStatusPage extends StatelessWidget {
  const VerificationStatusPage({super.key});

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
          'Identity Verification',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is! ProfileLoaded) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFFE8507A)),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status card ──────────────────────────────────
                _buildStatusCard(state.verificationStatus),
                const SizedBox(height: 20),

                // ── What verification unlocks ────────────────────
                const Text(
                  'What verification unlocks',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                _buildChecklist(state.verificationStatus),

                // ── Rejection reasons ────────────────────────────
                // TODO: access rejection reasons from Verification entity
                // when available in ProfileLoaded state.

                const SizedBox(height: 24),

                // ── Action button ────────────────────────────────
                _buildActionSection(context, state.verificationStatus),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Status card ──────────────────────────────────────────────────────

  Widget _buildStatusCard(VerificationStatus status) {
    final (gradient, emoji, title, subtitle) = switch (status) {
      VerificationStatus.approved => (
          const [Color(0xFF16A34A), Color(0xFF4ADE80)],
          '🎉',
          "You're verified!",
          'Nexa Stays · Verified Member · 2026',
        ),
      VerificationStatus.pending || VerificationStatus.submitted => (
          const [Color(0xFFD97706), Color(0xFFF59E0B)],
          '⏳',
          'Verification pending',
          'Usually reviewed within a few hours.',
        ),
      VerificationStatus.rejected => (
          const [Color(0xFFDC2626), Color(0xFFF87171)],
          '✗',
          'Verification failed',
          'See reasons below and resubmit.',
        ),
      VerificationStatus.notStarted => (
          const [Color(0xFF6B7280), Color(0xFF9CA3AF)],
          '🪪',
          'Not yet verified',
          'Required before booking or hosting.',
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.85),
            ),
            textAlign: TextAlign.center,
          ),
          if (status == VerificationStatus.approved) ...[
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user,
                  color: Colors.white, size: 22),
            ),
          ],
        ],
      ),
    );
  }

  // ── Checklist ────────────────────────────────────────────────────────

  Widget _buildChecklist(VerificationStatus status) {
    final isVerified = status == VerificationStatus.approved;
    final rowStatus = isVerified ? RowStatus.done : RowStatus.locked;

    return Column(
      children: [
        VerificationChecklistRow(
          label: 'Book any stay instantly',
          status: rowStatus,
        ),
        VerificationChecklistRow(
          label: 'Publish your property as a host',
          status: rowStatus,
        ),
        VerificationChecklistRow(
          label: 'Access contact details after booking',
          status: rowStatus,
        ),
        VerificationChecklistRow(
          label: 'Verified badge on your profile',
          status: rowStatus,
        ),
      ],
    );
  }

  // ── Action section ───────────────────────────────────────────────────

  Widget _buildActionSection(
    BuildContext context,
    VerificationStatus status,
  ) {
    return switch (status) {
      VerificationStatus.notStarted => SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => context.push(AppRoutes.verifyId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8507A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: const Text(
              'Start Verification →',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      VerificationStatus.pending ||
      VerificationStatus.submitted =>
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => context.read<ProfileCubit>().loadProfile(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD97706),
              side: const BorderSide(color: Color(0xFFFDE68A)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: const Text(
              'Check status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      VerificationStatus.rejected => SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => context.push(AppRoutes.verifyId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8507A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: const Text(
              'Resubmit Documents →',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      VerificationStatus.approved => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            border: Border.all(color: const Color(0xFFBBF7D0)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.badge_outlined,
                    color: Color(0xFF16A34A), size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identity Verified',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Nexa Stays · Verified Member · 2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    };
  }
}
