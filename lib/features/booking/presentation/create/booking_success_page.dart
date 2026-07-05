import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../navigation/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/booking.dart';

class BookingSuccessPage extends StatefulWidget {
  final Booking booking;

  const BookingSuccessPage({required this.booking, super.key});

  @override
  State<BookingSuccessPage> createState() => _BookingSuccessPageState();
}

class _BookingSuccessPageState extends State<BookingSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkController;
  late final Animation<double> _checkScale;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    _checkController.forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}, ${d.year}';

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // ── Green success header ──
            _buildSuccessHeader(booking),

            // ── White body ──
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -28),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  child: Container(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CheckInDetailsCard(booking: booking),
                          const SizedBox(height: 20),
                          _StaySummaryRow(booking: booking),
                          const SizedBox(height: 20),
                          _SecurityReminder(),
                          const SizedBox(height: 28),
                          _buildButtons(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Success header ─────────────────────────────────────────────────────

  Widget _buildSuccessHeader(Booking booking) {
    final shortId = booking.id.length > 8
        ? booking.id.substring(0, 8).toUpperCase()
        : booking.id.toUpperCase();

    return Container(
      height: 260,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF16A34A), Color(0xFF4ADE80)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated checkmark
            ScaleTransition(
              scale: _checkScale,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.check, color: Colors.white, size: 36),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Booking confirmed!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              'You\'re all set. Check-in details below.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 8),

            // Booking ID badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                'Booking #$shortId',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom buttons ─────────────────────────────────────────────────────

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // View My Bookings — primary
        SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8507A), Color(0xFFD4145A)],
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE8507A).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  context.go(AppRoutes.myBookings);
                },
                child: const Center(
                  child: Text(
                    'View My Bookings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Back to Home — outlined
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              context.go(AppRoutes.home);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SUB-WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

// ── Check-In Details Card (REVEALED) ─────────────────────────────────────

class _CheckInDetailsCard extends StatelessWidget {
  final Booking booking;

  const _CheckInDetailsCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF16A34A),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 10),
              const Text(
                'Check-in details confirmed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Color(0xFFBBF7D0), height: 1),
          ),

          // Exact address
          Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              const Text(
                'Exact address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              booking.exactAddress,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Check-in contact
          Row(
            children: [
              const Text('📞', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              const Text(
                'Check-in contact',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Column(
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
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () {
                    final uri = Uri(
                      scheme: 'tel',
                      path: booking.checkInContactPhone,
                    );
                    launchUrl(uri);
                  },
                  child: Text(
                    booking.checkInContactPhone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFE8507A),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFE8507A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Check-in instructions
          if (booking.checkInInstructions.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: Color(0xFFBBF7D0), height: 1),
            ),
            Row(
              children: [
                const Text('📋', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                const Text(
                  'Instructions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                booking.checkInInstructions,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stay Summary Row ─────────────────────────────────────────────────────

class _StaySummaryRow extends StatelessWidget {
  final Booking booking;

  const _StaySummaryRow({required this.booking});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _short(DateTime d) => '${_months[d.month - 1]} ${d.day}';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SummaryPill(text: '📅  ${_short(booking.checkIn)}'),
          const SizedBox(width: 8),
          _SummaryPill(text: '📅  ${_short(booking.checkOut)}'),
          const SizedBox(width: 8),
          _SummaryPill(
            text:
                '👥  ${booking.guests} ${booking.guests == 1 ? 'guest' : 'guests'}',
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String text;

  const _SummaryPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}

// ── Security Reminder ────────────────────────────────────────────────────

class _SecurityReminder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: const Border(
          left: BorderSide(color: Color(0xFFF59E0B), width: 3),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔒  Security reminder',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFFD97706),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Never make payments outside the Nexa platform. All payments are processed securely by Nexa Stays.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF92400E),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
