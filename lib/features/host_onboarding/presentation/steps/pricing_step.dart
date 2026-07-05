import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/host_onboarding_bloc.dart';
import '../bloc/host_onboarding_event.dart';
import '../bloc/host_onboarding_state.dart';
import '../widgets/payout_calculator_card.dart';

class PricingStep extends StatefulWidget {
  const PricingStep({
    super.key,
    required this.state,
    required this.bloc,
  });

  final HostOnboardingState state;
  final HostOnboardingBloc bloc;

  @override
  State<PricingStep> createState() => _PricingStepState();
}

class _PricingStepState extends State<PricingStep> {
  late final TextEditingController _rateController;
  late final TextEditingController _weeklyDiscountController;
  late final TextEditingController _monthlyDiscountController;

  bool _hasWeeklyDiscount = false;
  bool _hasMonthlyDiscount = false;

  final List<int> _quickSetValues = [300, 500, 750, 1000, 1500, 2000];
  final List<String> _minStayOptions = [
    '1 night',
    '2 nights',
    '3 nights',
    '1 week'
  ];
  String _selectedMinStay = '1 night';

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(
      text: widget.state.nightlyRate != null
          ? widget.state.nightlyRate!.toInt().toString()
          : '',
    );

    _weeklyDiscountController = TextEditingController(
      text: widget.state.weeklyDiscountPercent != null
          ? widget.state.weeklyDiscountPercent!.toInt().toString()
          : '',
    );
    _hasWeeklyDiscount = widget.state.weeklyDiscountPercent != null && widget.state.weeklyDiscountPercent! > 0;
    
    _monthlyDiscountController = TextEditingController(
      text: widget.state.monthlyDiscountPercent != null
          ? widget.state.monthlyDiscountPercent!.toInt().toString()
          : '',
    );
    _hasMonthlyDiscount = widget.state.monthlyDiscountPercent != null && widget.state.monthlyDiscountPercent! > 0;

    if (widget.state.minimumNights == 7) {
      _selectedMinStay = '1 week';
    } else if (widget.state.minimumNights > 1) {
      _selectedMinStay = '${widget.state.minimumNights} nights';
    } else {
      _selectedMinStay = '1 night';
    }

    _rateController.addListener(_dispatchUpdate);
    _weeklyDiscountController.addListener(_dispatchUpdate);
    _monthlyDiscountController.addListener(_dispatchUpdate);
  }

  @override
  void dispose() {
    _rateController.removeListener(_dispatchUpdate);
    _weeklyDiscountController.removeListener(_dispatchUpdate);

    _rateController.dispose();
    _weeklyDiscountController.dispose();
    _monthlyDiscountController.dispose();
    super.dispose();
  }

  void _dispatchUpdate() {
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final weeklyDiscount = _hasWeeklyDiscount
        ? (double.tryParse(_weeklyDiscountController.text) ?? 0.0)
        : null;
    final monthlyDiscount = _hasMonthlyDiscount
        ? (double.tryParse(_monthlyDiscountController.text) ?? 0.0)
        : null;

    int minNights = 1;
    if (_selectedMinStay == '2 nights') minNights = 2;
    if (_selectedMinStay == '3 nights') minNights = 3;
    if (_selectedMinStay == '1 week') minNights = 7;

    widget.bloc.add(
      HostPricingSaved(
        nightlyRate: rate > 0 ? rate : 0.0,
      ),
    );
    widget.bloc.add(
      HostDiscountsSaved(
        weeklyDiscountPercent: weeklyDiscount,
        monthlyDiscountPercent: monthlyDiscount,
        minimumNights: minNights,
      ),
    );
  }

  double get _currentRate => double.tryParse(_rateController.text) ?? 0.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STEP 7 OF 11',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE8507A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your pricing',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can update this anytime from your dashboard.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),

          // ── NIGHTLY RATE SECTION ──
          Text(
            'Nightly rate *',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 24),

          // LARGE PRICE INPUT
          Center(
            child: IntrinsicWidth(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 140, // Enough width for large numbers
                        child: TextField(
                          controller: _rateController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE8507A),
                            height: 1,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: GoogleFonts.dmSans(
                              color: const Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() {}), // re-render layout bounds & calculator
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 4),
                        child: Text(
                          'MAD',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: const Color(0xFFE8507A),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'per night',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // QUICK-SET CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickSetValues.map((val) {
                final isSelected = _currentRate == val.toDouble();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      _rateController.text = val.toString();
                      setState(() {});
                      _dispatchUpdate();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFF0F5) : Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFE8507A) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        // Formatting with commas for readability e.g. "1,000"
                        val >= 1000 
                            ? '${(val / 1000).floor()},${(val % 1000).toString().padLeft(3, '0')}'
                            : val.toString(),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? const Color(0xFFE8507A) : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),

          // PAYOUT CALCULATOR CARD (Live Preview)
          PayoutCalculatorCard(
            nightlyRate: _currentRate,
            onRateChanged: (newRate) {
              // Update text field if calculator child fires a change
              _rateController.text = newRate > 0 ? newRate.toInt().toString() : '';
              setState(() {});
              _dispatchUpdate();
            },
          ),
          const SizedBox(height: 32),

          const Divider(color: Color(0xFFE5E7EB), height: 1),
          const SizedBox(height: 24),

          // ── DISCOUNTS SECTION ──
          Text(
            'Discounts (optional)',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),

          // Weekly Discount Toggle
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _hasWeeklyDiscount,
                  onChanged: (val) {
                    setState(() {
                      _hasWeeklyDiscount = val;
                      if (!val) _weeklyDiscountController.clear();
                    });
                    _dispatchUpdate();
                  },
                  activeColor: const Color(0xFFE8507A),
                  title: Text(
                    'Weekly discount',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  subtitle: Text(
                    'Guests staying 7+ nights',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
                if (_hasWeeklyDiscount)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: _buildDiscountField(
                      hint: '10',
                      controller: _weeklyDiscountController,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Monthly Discount Toggle
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
               children: [
                SwitchListTile(
                  value: _hasMonthlyDiscount,
                  onChanged: (val) {
                    setState(() {
                      _hasMonthlyDiscount = val;
                      if (!val) _monthlyDiscountController.clear();
                    });
                    _dispatchUpdate();
                  },
                  activeColor: const Color(0xFFE8507A),
                  title: Text(
                    'Monthly discount',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  subtitle: Text(
                    'Guests staying 28+ nights',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
                if (_hasMonthlyDiscount)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: _buildDiscountField(
                      hint: '20',
                      controller: _monthlyDiscountController,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── MINIMUM STAY ──
          Text(
            'Minimum stay',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _minStayOptions.map((stay) {
              final isSelected = _selectedMinStay == stay;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMinStay = stay;
                  });
                  _dispatchUpdate();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE8507A) : Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFE8507A) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    stay,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDiscountField({
    required String hint,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF1A1A2E),
            ),
            decoration: InputDecoration(
              hintText: 'e.g. $hint',
              hintStyle: GoogleFonts.dmSans(
                 color: const Color(0xFF9CA3AF),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE8507A)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '%',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}
