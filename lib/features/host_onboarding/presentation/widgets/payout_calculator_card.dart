import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/config/stays_fee_config.dart';

class PayoutCalculatorCard extends StatefulWidget {
  const PayoutCalculatorCard({
    super.key,
    required this.nightlyRate,
    required this.onRateChanged,
  });

  /// The current nightly rate amount in MAD.
  final double nightlyRate;

  /// Callback when the nightly rate changes via text input.
  final ValueChanged<double> onRateChanged;

  @override
  State<PayoutCalculatorCard> createState() => _PayoutCalculatorCardState();
}

class _PayoutCalculatorCardState extends State<PayoutCalculatorCard> {
  late final TextEditingController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.nightlyRate > 0 ? widget.nightlyRate.toInt().toString() : '',
    );
  }

  @override
  void didUpdateWidget(PayoutCalculatorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nightlyRate != oldWidget.nightlyRate) {
      final String currentText =
          widget.nightlyRate > 0 ? widget.nightlyRate.toInt().toString() : '';
      if (_controller.text != currentText &&
          double.tryParse(_controller.text) != widget.nightlyRate) {
        _controller.text = currentText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (value.isEmpty) {
      widget.onRateChanged(0);
      return;
    }
    final parsed = double.tryParse(value);
    if (parsed != null) {
      widget.onRateChanged(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fee logic
    final config = StaysFeeConfig.instance;
    final double rate = widget.nightlyRate;
    final fees = config.calculateFees(rate);
    final double hostFee = fees.hostFee;
    final double payout = fees.hostPayout;
    final double guestFee = fees.guestFee;
    // final double guestTotal = rate + guestFee; // Explicitly kept in thought but unused directly right now besides guestFee

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your estimated payout',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),

          // ── INPUT ROW ──
          Row(
            children: [
              Text(
                'Nightly rate',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              ),
              const Spacer(),
              Container(
                width: 120,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: _onTextChanged,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textAlign: TextAlign.right,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          isDense: true,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        'MAD',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          const SizedBox(height: 16),

          // ── CALCULATION BREAKDOWN ──
          _buildCalculationRow(
            label: 'Your nightly rate',
            value: '${rate.toInt()} MAD',
            valueColor: const Color(0xFF374151),
          ),
          const SizedBox(height: 10),
          _buildCalculationRow(
            label: 'Host platform fee',
            subtitle: '(${config.hostFeePercentLabel} of ${rate.toInt()})',
            value: '−${hostFee.toInt()} MAD',
            valueColor: const Color(0xFFDC2626), // generic red
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1, height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your payout',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '${payout.toInt()} MAD',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF16A34A), // Green
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── GUEST SIDE INFO (Expandable) ──
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                Text(
                  'Guest price details',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                    decoration: TextDecoration.underline,
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0, width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'ℹ️ Guests also pay a ${config.guestFeePercentLabel} service fee (${guestFee.toInt()} MAD)',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow({
    required String label,
    String? subtitle,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF4B5563),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ],
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '................................................................................',
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(color: Color(0xFFE5E7EB), fontSize: 10),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
