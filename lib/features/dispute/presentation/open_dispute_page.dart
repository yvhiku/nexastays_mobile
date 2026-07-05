import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/app_routes.dart';
import '../domain/entities/dispute.dart';
import 'bloc/dispute_cubit.dart';
import 'bloc/dispute_state.dart';
import 'widgets/evidence_uploader.dart';

// =============================================================================
// Open Dispute Page
// =============================================================================

class OpenDisputePage extends StatefulWidget {
  const OpenDisputePage({
    super.key,
    required this.bookingId,
    required this.propertyId,
  });

  final String bookingId;
  final String propertyId;

  @override
  State<OpenDisputePage> createState() => _OpenDisputePageState();
}

class _OpenDisputePageState extends State<OpenDisputePage> {
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    context.read<DisputeCubit>().initForm(
          widget.bookingId,
          widget.propertyId,
        );
  }

  // ── Issue type data ──────────────────────────────────────────────────

  static const _issueTypes = <({String emoji, String label, DisputeType type})>[
    (emoji: '🏠', label: 'Not as described', type: DisputeType.propertyNotAsDescribed),
    (emoji: '🔑', label: 'Check-in issue', type: DisputeType.checkInIssue),
    (emoji: '❌', label: 'Amenity missing', type: DisputeType.amenityMissing),
    (emoji: '🧹', label: 'Cleanliness issue', type: DisputeType.cleanlinessIssue),
    (emoji: '🚨', label: 'Safety concern', type: DisputeType.safetyIssue),
    (emoji: '👻', label: 'Host no-show', type: DisputeType.hostNoShow),
    (emoji: '💳', label: 'Unauthorised charge', type: DisputeType.unauthorisedCharge),
    (emoji: '💬', label: 'Other', type: DisputeType.other),
  ];

  // ── Build ────────────────────────────────────────────────────────────

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
          'Open a dispute',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<DisputeCubit, DisputeState>(
        listener: _onStateChange,
        builder: (context, state) {
          if (state is DisputeEvidenceUploading) {
            return _buildUploadProgress(state);
          }
          if (state is DisputeSubmitting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
              ),
            );
          }
          if (state is! DisputeFormReady) {
            return const SizedBox.shrink();
          }
          return _buildForm(context, state);
        },
      ),
    );
  }

  void _onStateChange(BuildContext context, DisputeState state) {
    if (state is DisputeSubmitted) {
      context.pushReplacement(
        AppRoutes.disputeStatus,
        extra: {'disputeId': state.dispute.id},
      );
    } else if (state is DisputeError && state.isValidationError) {
      // Inline error — form rebuilds with the error message.
    } else if (state is DisputeError && !state.isValidationError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.message,
            style: const TextStyle(fontSize: 13),
          ),
          backgroundColor: const Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ── Form ──────────────────────────────────────────────────────────────

  Widget _buildForm(BuildContext context, DisputeFormReady state) {
    final cubit = context.read<DisputeCubit>();
    final descLen = state.description.length;
    final canSubmit = state.isValid && _confirmed;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Info banner ─────────────────────────────────────
                _buildInfoBanner(),
                const SizedBox(height: 24),

                // ── Issue type ──────────────────────────────────────
                const Text(
                  "What's the issue?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.9,
                  children: _issueTypes.map((item) {
                    final selected = state.selectedType == item.type;
                    return _IssueTypeCell(
                      emoji: item.emoji,
                      label: item.label,
                      selected: selected,
                      onTap: () => cubit.selectType(item.type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ── Description ─────────────────────────────────────
                const Text(
                  'Describe the issue',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: cubit.updateDescription,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        'Please describe what happened in detail...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFF7C3AED)),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    descLen < 20 ? '$descLen / 20 min' : '$descLen chars',
                    style: TextStyle(
                      fontSize: 11,
                      color: descLen < 20
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF16A34A),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Evidence ────────────────────────────────────────
                EvidenceUploader(
                  evidencePaths: state.evidencePaths,
                  onAdd: cubit.addEvidence,
                  onRemove: cubit.removeEvidence,
                ),
                const SizedBox(height: 24),

                // ── Confirmation ────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _confirmed,
                        onChanged: (v) =>
                            setState(() => _confirmed = v ?? false),
                        activeColor: const Color(0xFF7C3AED),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _confirmed = !_confirmed),
                        child: const Text(
                          'I confirm this report is accurate and I have evidence to support it.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF374151),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // ── Sticky bottom bar ──────────────────────────────────────
        _buildBottomBar(cubit, canSubmit),
      ],
    );
  }

  // ── Info banner ──────────────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        border: const Border(
          left: BorderSide(color: Color(0xFF7C3AED), width: 3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚖️ How disputes work',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF7C3AED),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '1. Submit your issue with evidence\n'
            '2. We review within 24–48 hours\n'
            '3. Host is given chance to respond\n'
            '4. Nexa makes a fair, evidence-based decision',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF374151),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ───────────────────────────────────────────────────────

  Widget _buildBottomBar(DisputeCubit cubit, bool canSubmit) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Submit dispute',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "We'll review within 24–48 hours",
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: canSubmit ? () => cubit.submitDispute() : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: canSubmit
                    ? const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                      )
                    : null,
                color: canSubmit ? null : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(50),
                boxShadow: canSubmit
                    ? [
                        BoxShadow(
                          color:
                              const Color(0xFF7C3AED).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                'Submit →',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: canSubmit
                      ? Colors.white
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Upload progress ──────────────────────────────────────────────────

  Widget _buildUploadProgress(DisputeEvidenceUploading state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.uploadProgress,
                minHeight: 6,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF7C3AED),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Uploading evidence ${state.uploadedCount} of ${state.totalCount}...',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Issue Type Cell
// =============================================================================

class _IssueTypeCell extends StatelessWidget {
  const _IssueTypeCell({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEDE9FE) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF7C3AED)
                : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                    color: selected
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF374151),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (selected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7C3AED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
