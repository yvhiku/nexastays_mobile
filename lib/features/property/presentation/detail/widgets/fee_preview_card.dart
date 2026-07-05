import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/config/stays_fee_config.dart';
import '../../../domain/entities/fee_breakdown.dart';

class FeePreviewCard extends StatelessWidget {
  const FeePreviewCard({
    super.key,
    required this.nightlyRate,
    required this.maxGuests,
    this.selectedCheckIn,
    this.selectedCheckOut,
    this.selectedGuests = 1,
    this.feeBreakdown,
    required this.onDatesSelected,
    required this.onGuestsChanged,
  });

  final double nightlyRate;
  final int maxGuests;
  final DateTime? selectedCheckIn;
  final DateTime? selectedCheckOut;
  final int selectedGuests;
  final FeeBreakdown? feeBreakdown;
  final Function(DateTime, DateTime) onDatesSelected;
  final ValueChanged<int> onGuestsChanged;

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialDateRange = selectedCheckIn != null && selectedCheckOut != null
        ? DateTimeRange(start: selectedCheckIn!, end: selectedCheckOut!)
        : null;

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE8507A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A2E),
              primaryContainer: Color(0xFFFFF0F5),
              onPrimaryContainer: Color(0xFFE8507A),
              surfaceTint: Colors.transparent,
            ),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1A1A2E),
              elevation: 0,
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: Colors.white,
              headerForegroundColor: Color(0xFF1A1A2E),
              surfaceTintColor: Colors.transparent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      onDatesSelected(pickedRange.start, pickedRange.end);
    }
  }

  void _showInfoTooltip(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Platform Fee',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(
          'NexaStays charges a ${StaysFeeConfig.instance.guestFeePercentLabel} guest service fee. This helps us run our platform and offer 24/7 customer support for your trip.',
          style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF374151)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: GoogleFonts.dmSans(
                color: const Color(0xFFE8507A),
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Add date';
    return DateFormat('MMM d, yyyy').format(date);
  }

  int get _nightsCount {
    if (selectedCheckIn != null && selectedCheckOut != null) {
      return selectedCheckOut!.difference(selectedCheckIn!).inDays;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final hasDates = selectedCheckIn != null && selectedCheckOut != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ────────────────────────────────────────────────
          Row(
            children: [
              Text(
                'Price breakdown',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showInfoTooltip(context),
                child: const Icon(Icons.info_outline, size: 16, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Date Selector Row ─────────────────────────────────────────
          Row(
            children: [
              Expanded(child: _buildDateBox(context, 'CHECK-IN', selectedCheckIn)),
              const SizedBox(width: 8),
              Expanded(child: _buildDateBox(context, 'CHECK-OUT', selectedCheckOut)),
            ],
          ),
          const SizedBox(height: 20),

          // ── Calculation Details (Only if dates selected) ──────────────
          if (hasDates && feeBreakdown != null) ...[
            _buildCalculationRow(
              '${nightlyRate.toStringAsFixed(0)} MAD × $_nightsCount nights',
              '${feeBreakdown!.basePrice.toStringAsFixed(0)} MAD',
            ),
            const SizedBox(height: 8),
            _buildCalculationRow(
              'Guest service fee (${StaysFeeConfig.instance.guestFeePercentLabel})',
              '+${feeBreakdown!.serviceFee.toStringAsFixed(0)} MAD',
            ),
            if (feeBreakdown!.cleaningFee > 0) ...[
              const SizedBox(height: 8),
              _buildCalculationRow(
                'Cleaning fee',
                '+${feeBreakdown!.cleaningFee.toStringAsFixed(0)} MAD',
              ),
            ],
            if (feeBreakdown!.taxes > 0) ...[
              const SizedBox(height: 8),
              _buildCalculationRow(
                'Taxes',
                '+${feeBreakdown!.taxes.toStringAsFixed(0)} MAD',
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  '${feeBreakdown!.total.toStringAsFixed(0)} MAD',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE8507A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Host receives: ${StaysFeeConfig.instance.calculateFees(feeBreakdown!.basePrice).hostPayout.toStringAsFixed(0)} MAD (after ${StaysFeeConfig.instance.hostFeePercentLabel} platform fee)',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Guests Selector ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Guests',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              Row(
                children: [
                  _buildStepperButton(
                    icon: Icons.remove,
                    enabled: selectedGuests > 1,
                    onTap: () => onGuestsChanged(selectedGuests - 1),
                  ),
                  SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        '$selectedGuests',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                  ),
                  _buildStepperButton(
                    icon: Icons.add,
                    enabled: selectedGuests < maxGuests,
                    onTap: () => onGuestsChanged(selectedGuests + 1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(BuildContext context, String label, DateTime? date) {
    return GestureDetector(
      onTap: () => _selectDateRange(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(date),
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: date == null ? FontWeight.w500 : FontWeight.w600,
                color: date == null ? const Color(0xFF9CA3AF) : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF374151),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? const Color(0xFFE5E7EB) : const Color(0xFFF3F4F6),
          ),
          color: enabled ? Colors.white : const Color(0xFFF9FAFB),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
        ),
      ),
    );
  }
}
