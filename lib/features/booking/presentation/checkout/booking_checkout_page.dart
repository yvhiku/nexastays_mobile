import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../create/widgets/fee_breakdown_card.dart';

enum _CheckoutPaymentMethod { cmiCard, payzone, nexaPay }

class BookingCheckoutPage extends StatefulWidget {
  final Booking booking;

  const BookingCheckoutPage({super.key, required this.booking});

  @override
  State<BookingCheckoutPage> createState() => _BookingCheckoutPageState();
}

class _BookingCheckoutPageState extends State<BookingCheckoutPage> {
  _CheckoutPaymentMethod _selectedMethod = _CheckoutPaymentMethod.cmiCard;
  bool _isPaying = false;

  Booking get booking => widget.booking;

  Future<void> _pay() async {
    if (_selectedMethod != _CheckoutPaymentMethod.cmiCard) return;

    setState(() => _isPaying = true);

    final result =
        await getIt<BookingRepository>().completeBookingPayment(booking.id);

    if (!mounted) return;

    setState(() => _isPaying = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      },
      (updated) {
        if (updated.status == BookingStatus.paymentPending) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Complete your payment in the browser, then return here.',
              ),
              backgroundColor: Color(0xFF2563EB),
            ),
          );
          context.pop(false);
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = booking.feeBreakdown.totalGuestPays.toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBookingSummary(),
                  const SizedBox(height: 24),
                  FeeBreakdownCard(
                    feeBreakdown: booking.feeBreakdown,
                    showFull: true,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pay with',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildPaymentOption(
                    method: _CheckoutPaymentMethod.cmiCard,
                    title: 'Credit / Debit Card (CMI)',
                    subtitle: 'Visa, Mastercard — secure payment via CMI',
                    icon: Icons.credit_card,
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentOption(
                    method: _CheckoutPaymentMethod.payzone,
                    title: 'Credit / Debit Card (Payzone)',
                    subtitle: 'Visa, Mastercard — coming soon',
                    icon: Icons.payment,
                    enabled: false,
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentOption(
                    method: _CheckoutPaymentMethod.nexaPay,
                    title: 'Nexa Pay wallet',
                    subtitle: 'Pay from your Nexa Pay balance — coming soon',
                    icon: Icons.account_balance_wallet_outlined,
                    enabled: false,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPaying ||
                          _selectedMethod != _CheckoutPaymentMethod.cmiCard
                      ? null
                      : _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8507A),
                    disabledBackgroundColor: const Color(0xFFF3F4F6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                  ),
                  child: _isPaying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Pay $total MAD',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDF1F2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: booking.propertyPhotoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: booking.propertyPhotoUrl,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: const Color(0xFFE5E7EB),
                      child: const Icon(Icons.home_outlined,
                          color: Color(0xFF9CA3AF)),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.propertyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.dateRangeDisplay} · ${booking.nightsDisplay}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required _CheckoutPaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    bool enabled = true,
  }) {
    final isSelected = _selectedMethod == method;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GestureDetector(
        onTap: enabled
            ? () => setState(() => _selectedMethod = method)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected && enabled
                ? const Color(0xFFFFF0F5)
                : Colors.white,
            border: Border.all(
              color: isSelected && enabled
                  ? const Color(0xFFE8507A)
                  : const Color(0xFFE5E7EB),
              width: isSelected && enabled ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected && enabled
                      ? const Color(0xFFE8507A).withValues(alpha: 0.1)
                      : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected && enabled
                      ? const Color(0xFFE8507A)
                      : const Color(0xFF374151),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight:
                            isSelected && enabled ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE8507A)
                          : const Color(0xFFD1D5DB),
                      width: isSelected ? 6.5 : 1.5,
                    ),
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
