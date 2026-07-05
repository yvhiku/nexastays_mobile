import 'package:flutter/material.dart';

import '../../../../../design_system/components/buttons/primary_button.dart';

class BookingsEmptyState extends StatelessWidget {
  final bool isUpcoming;
  final VoidCallback? onExplore;

  const BookingsEmptyState({
    super.key,
    required this.isUpcoming,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isUpcoming ? '📅' : '🗂️',
            style: const TextStyle(fontSize: 48, height: 1),
          ),
          const SizedBox(height: 16),
          Text(
            isUpcoming ? 'No upcoming bookings' : 'No past bookings',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isUpcoming
                ? 'Find your next stay in Morocco'
                : 'Your completed trips will appear here',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: PrimaryButton(
                label: 'Explore stays →',
                height: 48,
                radius: 50,
                onPressed: onExplore ?? () {},
              ),
            ),
          ],
        ],
      ),
    );
  }
}
