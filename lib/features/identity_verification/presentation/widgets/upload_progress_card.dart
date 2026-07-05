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

import '../bloc/verification_state.dart';

class UploadProgressCard extends StatelessWidget {
  final String fileName;
  final UploadFileStatus status;
  final double progress;

  const UploadProgressCard({
    super.key,
    required this.fileName,
    required this.status,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case UploadFileStatus.queued:
        return _buildQueuedCard();
      case UploadFileStatus.uploading:
        return _buildUploadingCard();
      case UploadFileStatus.done:
        return _buildDoneCard();
    }
  }

  Widget _buildQueuedCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF9CA3AF),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
                ),
            ),
          ),
          const Text(
            'Queued',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8507A).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8507A)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFE8507A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(
              color: Color(0xFFE8507A),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(
                color: Color(0xFF16A34A),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                ),
            ),
          ),
          const Text(
            '✓ Done',
            style: TextStyle(
              color: Color(0xFF16A34A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              ),
          ),
        ],
      ),
    );
  }
}
