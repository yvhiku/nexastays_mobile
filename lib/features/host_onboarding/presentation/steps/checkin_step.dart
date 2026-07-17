import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/host_onboarding_bloc.dart';
import '../bloc/host_onboarding_event.dart';
import '../bloc/host_onboarding_state.dart';

class CheckinStep extends StatefulWidget {
  const CheckinStep({
    super.key,
    required this.state,
    required this.bloc,
  });

  final HostOnboardingState state;
  final HostOnboardingBloc bloc;

  @override
  State<CheckinStep> createState() => _CheckinStepState();
}

class _CheckinStepState extends State<CheckinStep> {
  // House Rules
  late bool _petsAllowed;
  late bool _smokingAllowed;
  late bool _eventsAllowed;
  late bool _infantsAllowed;

  // Max Guests
  late int _maxGuests;

  // Quiet Hours
  TimeOfDay? _quietHoursFrom;
  TimeOfDay? _quietHoursUntil;

  // Check-in Method
  String _selectedMethod = '';

  // Additional Info
  late TextEditingController _additionalRulesController;

  final List<Map<String, String>> _checkInMethods = [
    {'emoji': '🔑', 'label': 'Self check-in (key lockbox)'},
    {'emoji': '🤝', 'label': 'Host meets guests'},
    {'emoji': '📱', 'label': 'Smart lock'},
    {'emoji': '🏢', 'label': 'Building reception'},
  ];

  @override
  void initState() {
    super.initState();
    _petsAllowed = widget.state.petsAllowed;
    _smokingAllowed = widget.state.smokingAllowed;
    _eventsAllowed = widget.state.eventsAllowed;
    _infantsAllowed = widget.state.suitableForInfants;
    _maxGuests = widget.state.maxGuests;

    _quietHoursFrom = _parseTime(widget.state.quietHoursFrom) ??
        const TimeOfDay(hour: 22, minute: 0);
    _quietHoursUntil = _parseTime(widget.state.quietHoursUntil) ??
        const TimeOfDay(hour: 8, minute: 0);

    _selectedMethod = widget.state.checkInMethod ?? '';
    _additionalRulesController =
        TextEditingController(text: widget.state.additionalRules ?? '');
    _additionalRulesController.addListener(_dispatchUpdate);
  }

  @override
  void dispose() {
    _additionalRulesController.removeListener(_dispatchUpdate);
    _additionalRulesController.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return null;
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _dispatchUpdate() {
    widget.bloc.add(
      HostCheckInSaved(
        petsAllowed: _petsAllowed,
        smokingAllowed: _smokingAllowed,
        eventsAllowed: _eventsAllowed,
        suitableForInfants: _infantsAllowed,
        quietHoursFrom: _formatTime(_quietHoursFrom),
        quietHoursUntil: _formatTime(_quietHoursUntil),
        maxGuests: _maxGuests,
        checkInMethod: _selectedMethod,
        additionalRules: _additionalRulesController.text.trim(),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isFrom) async {
    final initialTime = isFrom
        ? (_quietHoursFrom ?? const TimeOfDay(hour: 22, minute: 0))
        : (_quietHoursUntil ?? const TimeOfDay(hour: 8, minute: 0));

    final selected = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE8507A), // #E8185E main selection
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1A2E), // Text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() {
        if (isFrom) {
          _quietHoursFrom = selected;
        } else {
          _quietHoursUntil = selected;
        }
      });
      _dispatchUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STEP 8 OF 11',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE8507A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'House rules & check-in',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be clear so guests know what to expect.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),

          // ── HOUSE RULES ──
          Text(
            'House rules',
            style: GoogleFonts.playfairDisplay(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          _buildRuleToggle('🐾 Pets allowed', _petsAllowed, (val) {
            setState(() => _petsAllowed = val);
            _dispatchUpdate();
          }),
          _buildRuleToggle('🚬 Smoking allowed', _smokingAllowed, (val) {
            setState(() => _smokingAllowed = val);
            _dispatchUpdate();
          }),
          _buildRuleToggle('🎉 Events allowed', _eventsAllowed, (val) {
            setState(() => _eventsAllowed = val);
            _dispatchUpdate();
          }),
          _buildRuleToggle('👶 Suitable for infants', _infantsAllowed, (val) {
            setState(() => _infantsAllowed = val);
            _dispatchUpdate();
          }),
          const SizedBox(height: 24),

          // ── MAX GUESTS ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Max guests *',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Row(
                children: [
                  _buildStepperButton(Icons.remove, () {
                    if (_maxGuests > 1) {
                      setState(() => _maxGuests--);
                      _dispatchUpdate();
                    }
                  }),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$_maxGuests',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  _buildStepperButton(Icons.add, () {
                    if (_maxGuests < 20) {
                      setState(() => _maxGuests++);
                      _dispatchUpdate();
                    }
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── QUIET HOURS ──
          Text(
            'Quiet hours',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimePickerBox(
                    'From', _quietHoursFrom, () => _selectTime(context, true)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimePickerBox('Until', _quietHoursUntil,
                    () => _selectTime(context, false)),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── CHECK-IN METHOD ──
          Text(
            'How do guests check in?',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 80, // strict 80px block
            ),
            itemCount: _checkInMethods.length,
            itemBuilder: (context, index) {
              final method = _checkInMethods[index];
              final label = method['label']!;
              final emoji = method['emoji']!;
              final isSelected = _selectedMethod == label;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedMethod = label);
                  _dispatchUpdate();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFF0F5) : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE8507A)
                          : const Color(0xFFE5E7EB),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFFE8507A)
                              : const Color(0xFF4B5563),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // ── ADDITIONAL INFO ──
          Text(
            'Additional house rules (optional)',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _additionalRulesController,
            maxLines: 3,
            style: GoogleFonts.dmSans(
                fontSize: 14, color: const Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText: 'e.g. No parties, remove shoes at entrance',
              hintStyle: GoogleFonts.dmSans(color: const Color(0xFF9CA3AF)),
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
                borderSide: const BorderSide(color: Color(0xFFE8507A)),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRuleToggle(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFE8507A),
        title: Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          color: Colors.white,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1A1A2E)),
      ),
    );
  }

  Widget _buildTimePickerBox(
      String label, TimeOfDay? time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label: ${_formatTime(time)}',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
            const Icon(Icons.arrow_drop_down,
                color: Color(0xFF6B7280), size: 18),
          ],
        ),
      ),
    );
  }
}
