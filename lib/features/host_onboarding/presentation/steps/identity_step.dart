import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/host_onboarding_bloc.dart';
import '../bloc/host_onboarding_event.dart';
import '../bloc/host_onboarding_state.dart';

/// Step 4 — Host Identity Verification
///
/// A simplified ID-check step where the host confirms their identity
/// type and provides their ID number. In a real app this would connect
/// to the full identity-verification flow.
class IdentityStep extends StatefulWidget {
  const IdentityStep({
    super.key,
    required this.state,
    required this.bloc,
  });

  final HostOnboardingState state;
  final HostOnboardingBloc bloc;

  @override
  State<IdentityStep> createState() => _IdentityStepState();
}

class _IdentityStepState extends State<IdentityStep> {
  String? _selectedIdType;
  final TextEditingController _idNumberController = TextEditingController();
  bool _frontUploaded = false;
  bool _backUploaded = false;

  static const _primary = Color(0xFFE8507A);
  static const _bg = Color(0xFFFFF0F5);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);

  final _idTypes = [
    {'key': 'cnie', 'label': 'National ID Card (CNIE)', 'icon': Icons.badge},
    {'key': 'passport', 'label': 'Passport', 'icon': Icons.flight},
    {
      'key': 'driving_license',
      'label': "Driver's License",
      'icon': Icons.directions_car
    },
  ];

  @override
  void initState() {
    super.initState();
    _idNumberController.addListener(_validateAndNotifyBloc);
  }

  @override
  void dispose() {
    _idNumberController.removeListener(_validateAndNotifyBloc);
    _idNumberController.dispose();
    super.dispose();
  }

  void _validateAndNotifyBloc() {
    final isValid = _selectedIdType != null &&
        _idNumberController.text.trim().isNotEmpty &&
        _frontUploaded &&
        _backUploaded;
    widget.bloc.add(HostStepValidated(step: 4, isValid: isValid));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──
          Text(
            'Verify your identity',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Required by Moroccan law for hosting. Your ID is encrypted and never shared with guests.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // ── ID Type selector ──
          Text(
            'ID Document Type *',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._idTypes.map((type) => _buildIdTypeOption(
                key: type['key'] as String,
                label: type['label'] as String,
                icon: type['icon'] as IconData,
              )),

          const SizedBox(height: 24),

          // ── ID Number ──
          Text(
            'ID Number *',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _idNumberController,
            style: GoogleFonts.dmSans(fontSize: 14, color: _textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. AB123456',
              hintStyle: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF9CA3AF)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Document Upload ──
          Text(
            'Upload Document Photos *',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildUploadCard(
                  label: 'Front Side',
                  icon: Icons.credit_card,
                  isUploaded: _frontUploaded,
                  onTap: () {
                    setState(() => _frontUploaded = true);
                    _validateAndNotifyBloc();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUploadCard(
                  label: 'Back Side',
                  icon: Icons.credit_card,
                  isUploaded: _backUploaded,
                  onTap: () {
                    setState(() => _backUploaded = true);
                    _validateAndNotifyBloc();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Security Note ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: Color(0xFF22C55E), width: 3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined,
                    color: Color(0xFF16A34A), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your documents are encrypted end-to-end and stored securely. They are used only for identity verification and are never shared with guests.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF15803D),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildIdTypeOption({
    required String key,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedIdType == key;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIdType = key);
        _validateAndNotifyBloc();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _bg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primary : _border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? _primary.withValues(alpha: 0.1)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  color: isSelected ? _primary : const Color(0xFF3B82F6),
                  size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? _primary : _textPrimary,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _primary : _border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String label,
    required IconData icon,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isUploaded ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUploaded ? const Color(0xFF22C55E) : _border,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUploaded ? Icons.check_circle : icon,
              size: 32,
              color: isUploaded
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 8),
            Text(
              isUploaded ? 'Uploaded ✓' : label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isUploaded
                    ? const Color(0xFF16A34A)
                    : _textSecondary,
              ),
            ),
            if (!isUploaded) ...[
              const SizedBox(height: 4),
              Text(
                'Tap to upload',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
