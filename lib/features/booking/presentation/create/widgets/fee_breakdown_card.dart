import 'package:flutter/material.dart';
import '../../../../../core/config/stays_fee_config.dart';
import '../../../domain/entities/fee_breakdown.dart';

class FeeBreakdownCard extends StatefulWidget {
  final FeeBreakdown feeBreakdown;
  final bool showFull;
  final bool showHostNote;

  const FeeBreakdownCard({
    super.key,
    required this.feeBreakdown,
    this.showFull = true,
    this.showHostNote = false,
  });

  @override
  State<FeeBreakdownCard> createState() => _FeeBreakdownCardState();
}

class _FeeBreakdownCardState extends State<FeeBreakdownCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.showFull;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000), // 0.06 alpha
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              if (widget.feeBreakdown.hasDiscount)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    'Discount applied 🎉',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isExpanded) ...[
            _FeeRow(
              label: '${widget.feeBreakdown.nightlyRate.toInt()} MAD × ${widget.feeBreakdown.nights} nights',
              amount: '${(widget.feeBreakdown.nightlyRate * widget.feeBreakdown.nights).toInt()} MAD',
            ),
            if (widget.feeBreakdown.weeklyDiscount != null) ...[
              const SizedBox(height: 10),
              _FeeRow(
                label: 'Weekly discount',
                amount: '−${widget.feeBreakdown.weeklyDiscount!.toInt()} MAD',
                amountColor: const Color(0xFF16A34A),
              ),
            ],
            if (widget.feeBreakdown.monthlyDiscount != null) ...[
              const SizedBox(height: 10),
              _FeeRow(
                label: 'Monthly discount',
                amount: '−${widget.feeBreakdown.monthlyDiscount!.toInt()} MAD',
                amountColor: const Color(0xFF16A34A),
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFF3F4F6), height: 1, thickness: 1),
            ),
            _FeeRow(
              label: 'Subtotal',
              amount: widget.feeBreakdown.subtotalDisplay,
              isBold: true,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFF3F4F6), height: 1, thickness: 1),
            ),
            _FeeRow(
              label: 'Guest service fee',
              amount: widget.feeBreakdown.guestFeeDisplay,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 14, top: 2),
              child: Text(
                '${StaysFeeConfig.instance.guestFeePercentLabel} of ${widget.feeBreakdown.subtotalDisplay} subtotal',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Color(0xFFE5E7EB), height: 1, thickness: 1.5),
            ),
          ] else ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = true;
                });
              },
              child: const Row(
                children: [
                  Text(
                    'Show breakdown',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF374151),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Color(0xFF374151),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                widget.feeBreakdown.totalDisplay,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFE8507A),
                ),
              ),
            ],
          ),
          if (widget.showHostNote) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFE5E7EB), height: 1, thickness: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Host receives:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  '${widget.feeBreakdown.hostPayoutDisplay} (after ${StaysFeeConfig.instance.hostFeePercentLabel} fee)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String amount;
  final Color amountColor;
  final bool isBold;

  const _FeeRow({
    required this.label,
    required this.amount,
    this.amountColor = const Color(0xFF374151),
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF374151),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
