import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/booking_lifecycle.dart';
import '../../../../../design_system/components/buttons/primary_button.dart';

class BookingsEmptyState extends StatelessWidget {
  final BookingsTab? tab;
  final bool filtered;
  final VoidCallback? onExplore;
  final VoidCallback? onClearFilters;

  const BookingsEmptyState({
    super.key,
    this.tab,
    this.filtered = false,
    this.onExplore,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (filtered) {
      return _wrap(
        icon: '🔍',
        title: 'No bookings match your filters',
        subtitle: 'Try adjusting filters or search terms.',
        action: onClearFilters != null
            ? OutlinedButton(
                onPressed: onClearFilters,
                child: const Text('Clear filters'),
              )
            : null,
      );
    }

    if (tab == null) {
      return _wrap(
        icon: '📅',
        title: 'No bookings yet',
        subtitle: 'Browse stays and make your first reservation.',
        action: onExplore != null
            ? SizedBox(
                width: 220,
                child: PrimaryButton(
                  label: 'Browse stays',
                  height: 48,
                  radius: 50,
                  onPressed: onExplore!,
                ),
              )
            : null,
      );
    }

    return _wrap(
      icon: _tabIcon(tab!),
      title: _tabTitle(tab!),
      subtitle: tabSectionDescription(tab!),
      action: tab == BookingsTab.upcoming && onExplore != null
          ? SizedBox(
              width: 220,
              child: PrimaryButton(
                label: 'Browse stays',
                height: 48,
                radius: 50,
                onPressed: onExplore!,
              ),
            )
          : null,
    );
  }

  Widget _wrap({
    required String icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 48, height: 1)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  String _tabIcon(BookingsTab tab) {
    switch (tab) {
      case BookingsTab.upcoming:
        return '📅';
      case BookingsTab.current:
        return '🏠';
      case BookingsTab.pending:
        return '💳';
      case BookingsTab.completed:
        return '✅';
      case BookingsTab.cancelled:
        return '❌';
      case BookingsTab.all:
        return '📋';
    }
  }

  String _tabTitle(BookingsTab tab) {
    switch (tab) {
      case BookingsTab.upcoming:
        return 'No upcoming bookings';
      case BookingsTab.current:
        return 'No current stay';
      case BookingsTab.pending:
        return 'No pending payments';
      case BookingsTab.completed:
        return 'No completed bookings';
      case BookingsTab.cancelled:
        return 'No cancelled bookings';
      case BookingsTab.all:
        return 'No bookings';
    }
  }
}
