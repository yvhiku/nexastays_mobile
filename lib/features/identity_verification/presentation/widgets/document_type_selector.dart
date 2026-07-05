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

import '../../domain/entities/verification.dart';

class DocumentTypeSelector extends StatelessWidget {
  final IdType? selectedType;
  final ValueChanged<IdType> onChanged;

  const DocumentTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  static String displayName(IdType type) {
    switch (type) {
      case IdType.cnie:
        return 'CNIE';
      case IdType.passport:
        return 'Passport';
      case IdType.drivingLicense:
        return 'Driving License';
    }
  }

  static String _subtitle(IdType type) {
    switch (type) {
      case IdType.cnie:
        return 'Moroccan National ID';
      case IdType.passport:
        return 'International passport';
      case IdType.drivingLicense:
        return 'Moroccan license';
    }
  }

  void _showBottomSheet(BuildContext context) {
    IdType? tempSelected = selectedType;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Select ID type',
                    style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      ),
                  ),
                  const SizedBox(height: 20),

                  // Options
                  ...IdType.values.map((type) {
                    final isSelected = tempSelected == type;
                    return InkWell(
                      onTap: () {
                        setSheetState(() => tempSelected = type);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE8507A)
                                : const Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? const Color(0xFFFFF0F5)
                              : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName(type),
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFFE8507A)
                                          : const Color(0xFF1A1A2E),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _subtitle(type),
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 12,
                                      ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFE8507A)
                                      : const Color(0xFFD1D5DB),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFE8507A),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Confirm button
                  Container(
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
                      onPressed: tempSelected != null
                          ? () {
                              onChanged(tempSelected!);
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
                        'Select',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ID Type *',
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showBottomSheet(context),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedType != null
                    ? const Color(0xFFE8507A)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedType != null
                        ? displayName(selectedType!)
                        : 'Select document type',
                    style: TextStyle(
                      color: selectedType != null
                          ? const Color(0xFF1A1A2E)
                          : const Color(0xFF9CA3AF),
                      fontSize: 14,
                      ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
