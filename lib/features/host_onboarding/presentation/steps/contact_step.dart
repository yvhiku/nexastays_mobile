import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/host_onboarding_bloc.dart';
import '../bloc/host_onboarding_event.dart';
import '../bloc/host_onboarding_state.dart';

class ContactStep extends StatefulWidget {
  const ContactStep({
    super.key,
    required this.state,
    required this.bloc,
  });

  final HostOnboardingState state;
  final HostOnboardingBloc bloc;

  @override
  State<ContactStep> createState() => _ContactStepState();
}

class _ContactStepState extends State<ContactStep> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _lateInstructionsController;

  final List<String> _timeOptions = [
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    'Flexible'
  ];
  String _selectedTime = '14:00';
  bool _allowLateCheckIn = false;

  @override
  void initState() {
    super.initState();
    // In a real app we'd parse this from state.checkInContact, state.checkInInstructions
    // For this UI, we initialize empty and dispatch to state on changes.
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _instructionsController =
        TextEditingController(text: widget.state.checkInInstructions ?? '');
    _lateInstructionsController = TextEditingController();

    _nameController.addListener(_dispatchUpdate);
    _phoneController.addListener(_dispatchUpdate);
    _instructionsController.addListener(_dispatchUpdate);
    _lateInstructionsController.addListener(_dispatchUpdate);
  }

  @override
  void dispose() {
    _nameController.removeListener(_dispatchUpdate);
    _phoneController.removeListener(_dispatchUpdate);
    _instructionsController.removeListener(_dispatchUpdate);
    _lateInstructionsController.removeListener(_dispatchUpdate);

    _nameController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    _lateInstructionsController.dispose();
    super.dispose();
  }

  void _dispatchUpdate() {
    // Combine name + phone into the single contact field the state expects currently
    final String combinedContact =
        '${_nameController.text.trim()} | ${_phoneController.text.trim()}';

    // Combine standard instructions + late instructions + time
    String fullInstructions =
        '${_instructionsController.text.trim()}\nStandard Time: $_selectedTime';
    if (_allowLateCheckIn && _lateInstructionsController.text.isNotEmpty) {
      fullInstructions +=
          '\nLate Check-in: ${_lateInstructionsController.text.trim()}';
    }

    widget.bloc.add(
      HostContactSaved(
        whatsapp: '', // Or add whatsapp logic if added to this step later
        checkInContact: combinedContact.length > 3 ? combinedContact : '',
        checkInInstructions: fullInstructions.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STEP 3 OF 11',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE8507A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check-in contact',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Who will guests meet or hear from at check-in?',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // ── INFO CARD ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB3C1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔑', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This contact is shared with guests only after booking confirmed.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF7C3AED), // Purple-ish
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Not your personal phone — can be a co-host or assistant.',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── FORM FIELDS ──
          _buildInputField(
            label: 'Check-in contact name *',
            hint: 'e.g. Karim (co-host)',
            controller: _nameController,
          ),
          const SizedBox(height: 14),

          _buildInputField(
            label: 'Check-in phone *',
            hint: '+212 6 XX XX XX XX',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixText: '📞  ',
          ),
          const SizedBox(height: 14),

          _buildInputField(
            label: 'Check-in instructions',
            hint: 'e.g. Ring doorbell, ask for Karim at 2nd floor',
            controller: _instructionsController,
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // ── TIME SELECTOR ──
          Text(
            'Standard check-in time',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeOptions.map((time) {
              final isSelected = _selectedTime == time;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTime = time;
                  });
                  _dispatchUpdate();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE8507A) : Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE8507A)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    time,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── LATE CHECK-IN TOGGLE ──
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _allowLateCheckIn,
                  onChanged: (val) {
                    setState(() {
                      _allowLateCheckIn = val;
                    });
                    _dispatchUpdate();
                  },
                  activeColor: const Color(0xFFE8507A),
                  title: Text(
                    'Allow late check-in (after 20:00)',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                if (_allowLateCheckIn)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: _buildInputField(
                      label: '', // No label needed here based on spec flow
                      hint:
                          'Late check-in instructions (e.g. key lockbox code)',
                      controller: _lateInstructionsController,
                      maxLines: 2,
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

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: const Color(0xFF1A1A2E),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            prefixText: prefixText,
            prefixStyle: const TextStyle(fontSize: 14),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFFE8507A), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
