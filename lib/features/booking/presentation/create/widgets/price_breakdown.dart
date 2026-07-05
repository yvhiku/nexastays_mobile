import 'package:flutter/material.dart';
import '../../../../../core/config/stays_fee_config.dart';
import '../../../domain/entities/fee_breakdown.dart';

class PriceBreakdown extends StatelessWidget {
  final FeeBreakdown feeBreakdown;
  final bool showFeeNote;

  const PriceBreakdown({
    super.key,
    required this.feeBreakdown,
    this.showFeeNote = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${feeBreakdown.totalGuestPays.toInt()} MAD',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFFE8507A),
              ),
            ),
            const SizedBox(height: 2),
            if (feeBreakdown.nights > 0)
              Text(
                '${feeBreakdown.nights} nights · ${feeBreakdown.nightlyRate.toInt()} MAD/night',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              )
            else
              Text(
                '${feeBreakdown.nightlyRate.toInt()} MAD/night',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
          ],
        ),
        const Spacer(),
        if (showFeeNote)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'incl. ${StaysFeeConfig.instance.guestFeePercentLabel} fee',
              style: const TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
      ],
    );
  }
}
