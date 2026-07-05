import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/booking.dart';

class CheckinContactCard extends StatelessWidget {
  final Booking booking;
  final bool isRevealed;

  const CheckinContactCard({
    super.key,
    required this.booking,
    required this.isRevealed,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  String _roleLabel(String role) {
    switch (role.toUpperCase()) {
      case 'CO_HOST':
        return 'Co-host';
      case 'AGENT':
        return 'Agent';
      case 'OWNER':
        return 'Host';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isRevealed) {
      return _buildRevealedState();
    }
    return _buildMaskedState();
  }

  Widget _buildMaskedState() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.lock, color: Color(0xFFD97706), size: 20),
              SizedBox(width: 8),
              Text(
                'Contact details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFFDE68A), height: 1, thickness: 1),
          ),
          _buildBlurredRow('📞', 160),
          const SizedBox(height: 12),
          _buildBlurredRow('👤', 120),
          const SizedBox(height: 12),
          _buildBlurredRow('📍', 180),
          const SizedBox(height: 10),
          const Text(
            'Check-in contact, exact address, and access instructions are shared after payment is confirmed.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredRow(String icon, double width) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Container(
          height: 14,
          width: width,
          decoration: BoxDecoration(
            color: const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildRevealedState() {
    final roleLabel = _roleLabel(booking.checkInContactRole);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF16A34A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  booking.hasContactDetails
                      ? 'Check-in details'
                      : 'Payment confirmed',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFBBF7D0), height: 1, thickness: 1),
          ),
          if (!booking.hasContactDetails)
            const Text(
              'Your host has not added check-in details yet. You can message them through Nexa Stays if you need help before arrival.',
              style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
            )
          else ...[
            if (booking.checkInContact.isNotEmpty)
              _buildRevealedRow(
                '👤',
                'Check-in contact',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.checkInContact,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    if (roleLabel.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        roleLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            if (booking.checkInContactPhone.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildRevealedRow(
                '📞',
                'Phone',
                GestureDetector(
                  onTap: () => _makePhoneCall(booking.checkInContactPhone),
                  child: Text(
                    booking.checkInContactPhone,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFFE8507A),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFE8507A),
                    ),
                  ),
                ),
              ),
            ],
            if (booking.exactAddress.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildRevealedRow(
                '📍',
                'Stay address',
                Text(
                  booking.exactAddress,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
            if (booking.checkInInstructions.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildRevealedRow(
                '🔑',
                'Access instructions',
                Text(
                  booking.checkInInstructions,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
          if (booking.checkInContactPhone.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => _makePhoneCall(booking.checkInContactPhone),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE8507A), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('📞 ', style: TextStyle(fontSize: 14)),
                    Text(
                      'Call check-in contact',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE8507A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRevealedRow(String icon, String label, Widget content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 4),
              content,
            ],
          ),
        ),
      ],
    );
  }
}
