// ─── NEXASTAYS IDENTITY VERIFICATION — SYNC CONTRACT ─────────────────────
// Design tokens:
//   Primary       : Color(0xFFE8507A)
//   Success       : Color(0xFF16A34A)  bg: Color(0xFFF0FDF4)
//   Error         : Color(0xFFDC2626)  bg: Color(0xFFFEF2F2)
//   Warning       : Color(0xFFD97706)  bg: Color(0xFFFFFBEB)
//   Upload dashed : dashed border Color(0xFFE8507A), bg Color(0xFFFFF0F5)
//
// Cubit contract : VerificationCubit → VerificationState
//   (lib/features/identity_verification/presentation/bloc/)
//
// Entities       : Verification, IdType, VerificationStatus
//   (lib/features/identity_verification/domain/entities/verification.dart)
//
// Repository     : VerificationRepository (domain) → VerificationRepositoryImpl (data)
// UseCases       : UploadIdUseCase, SubmitSelfieUseCase
//
// Upload stream  : repository.uploadProgressStream → Stream<UploadProgressEvent>
//   UploadProgressEvent { String fileName, double progress, bool isDone }
//
// Navigation routes (app/router.dart):
//   /verify-id           → IdUploadPage       (step 3)
//   /selfie-capture      → SelfiePage         (camera, returns path)
//   /verification-status → VerificationStatusPage (step 4)
//
// Stepper (shared widget from auth feature):
//   StepIndicator(currentStep: 3) on IdUploadPage
//   StepIndicator(currentStep: 4) on VerificationStatusPage
//
// User userId sourced from: AuthBloc → AuthAuthenticated state → user.id
//
// After VerificationApproved:
//   Update cached User.isVerified = true via AuthBloc or SessionManager
// ─────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../navigation/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart' as auth_state;

import 'bloc/verification_cubit.dart';
import 'bloc/verification_state.dart';
import 'widgets/verification_checklist_row.dart';

class VerificationPendingPage extends StatefulWidget {
  const VerificationPendingPage({super.key});

  @override
  State<VerificationPendingPage> createState() =>
      _VerificationPendingPageState();
}

class _VerificationPendingPageState extends State<VerificationPendingPage> {
  @override
  void initState() {
    super.initState();
    // Check status immediately on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is auth_state.AuthAuthenticated) {
        context.read<VerificationCubit>().checkStatus(authState.user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<VerificationCubit, VerificationState>(
        builder: (context, state) {
          if (state is VerificationLoading || state is VerificationInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8507A)),
            );
          } else if (state is VerificationSubmitted) {
            return _buildSubmittedView();
          } else if (state is VerificationApproved) {
            return _buildApprovedView();
          } else if (state is VerificationRejected) {
            return _buildRejectedView(state);
          } else if (state is VerificationError) {
            return _buildErrorView(state.message);
          }
          // Fallback (e.g. if state is FormReady, they shouldn't be on this page, but handle gracefully)
          return _buildErrorView('Invalid verification state');
        },
      ),
    );
  }

  // ─── STATE 1: VerificationSubmitted ─────────────────────────────────────────

  Widget _buildSubmittedView() {
    return SafeArea(
      child: Column(
        children: [

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF0F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('⏳', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Verification submitted',
                    style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Your account is under review. We'll notify you once approved — usually within a few hours.",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Checklist
                  const VerificationChecklistRow(
                    label: 'Account created',
                    status: RowStatus.done,
                  ),
                  const VerificationChecklistRow(
                    label: 'Phone & email confirmed',
                    status: RowStatus.done,
                  ),
                  const VerificationChecklistRow(
                    label: 'ID submitted for review',
                    status: RowStatus.done,
                  ),
                  const VerificationChecklistRow(
                    label: 'Book stays — unlocks after verification',
                    status: RowStatus.locked,
                  ),
                  const VerificationChecklistRow(
                    label: 'Publish listings — unlocks after verification',
                    status: RowStatus.locked,
                  ),

                  const SizedBox(height: 24),

                  // Info tip
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💡', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You can browse all listings and save favorites while we review your account.',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8507A), Color(0xFFFF6B9D)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'Browse Stays →',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STATE 2: VerificationApproved ──────────────────────────────────────────

  Widget _buildApprovedView() {
    return Column(
      children: [
        // Green Header
        Container(
          width: double.infinity,
          height: 240,
          padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF16A34A), Color(0xFF4ADE80)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎉', style: TextStyle(fontSize: 56)),
              SizedBox(height: 16),
              Text(
                "You're verified!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  ),
              ),
              SizedBox(height: 8),
              Text(
                "Your identity has been confirmed. All features are now unlocked.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Body
        Expanded(
          child: Container(
            transform: Matrix4.translationValues(0, -20, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔓 All features unlocked',
                    style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      ),
                  ),
                  const SizedBox(height: 16),
                  const VerificationChecklistRow(
                    label: 'Book any stay instantly',
                    status: RowStatus.done,
                  ),
                  const VerificationChecklistRow(
                    label: 'Publish your property as a host',
                    status: RowStatus.done,
                  ),
                  const VerificationChecklistRow(
                    label: 'Access contact details after booking',
                    status: RowStatus.done,
                  ),
                  const VerificationChecklistRow(
                    label: 'Verified badge on your profile',
                    status: RowStatus.done,
                  ),

                  const SizedBox(height: 24),

                  // Verification Badge Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child:
                              const Icon(Icons.badge, color: Color(0xFF16A34A)),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Identity Verified',
                                style: TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Nexa Stays · Verified Member · 2026',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12,
                                  ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle,
                            color: Color(0xFF16A34A)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'Start Exploring →',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── STATE 3: VerificationRejected ─────────────────────────────────────────

  Widget _buildRejectedView(VerificationRejected state) {
    return Column(
      children: [
        // Red Header
        Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFFF87171)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                "Verification failed",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We couldn't verify your identity. See reasons below and try again.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Body
        Expanded(
          child: Container(
            transform: Matrix4.translationValues(0, -20, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reason(s):',
                    style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      ),
                  ),
                  const SizedBox(height: 12),

                  ...state.reasons.map((reason) => _buildReasonCard(reason)),

                  if (state.reasons.isEmpty)
                    _buildReasonCard('Documents were invalid or unreadable.'),

                  const SizedBox(height: 24),

                  // Attempts Warning
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F5),
                      border: Border.all(color: const Color(0xFFFFB3C1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 13,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'You have '),
                          TextSpan(
                            text: '${state.attemptsRemaining}',
                            style: const TextStyle(
                              color: Color(0xFFE8507A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                              text: ' more attempts to resubmit. After that, '),
                          const TextSpan(
                            text: 'contact support.',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Buttons
                  Opacity(
                    opacity: state.attemptsRemaining > 0 ? 1.0 : 0.5,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8507A), Color(0xFFFF6B9D)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: state.attemptsRemaining > 0
                            ? () {
                                // Reset cubit to initial/form state is handled by app navigation
                                // Usually we pop back to the upload page
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          '🔄 Resubmit Documents',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        // Launch support mailto or in-app view
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        'Contact Support',
                        style: TextStyle(
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonCard(String description) {
    // Simple heuristic for title/icon based on text
    String title = 'Document issue';
    IconData icon = Icons.description_outlined;

    if (description.toLowerCase().contains('blurry') ||
        description.toLowerCase().contains('clear')) {
      title = 'ID photo unclear';
      icon = Icons.blur_on;
    } else if (description.toLowerCase().contains('match') ||
        description.toLowerCase().contains('face')) {
      title = "Selfie doesn't match ID";
      icon = Icons.face_retouching_off;
    } else if (description.toLowerCase().contains('expire')) {
      title = 'ID Document Expired';
      icon = Icons.event_busy;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        border: Border.all(color: const Color(0xFFFECACA)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFDC2626), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
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

  // ─── ERROR FALLBACK ───────────────────────────────────────────────────────

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading status',
              style: const TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is auth_state.AuthAuthenticated) {
                  context
                      .read<VerificationCubit>()
                      .checkStatus(authState.user.id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8507A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text('Try Again',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
