import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/booking_lifecycle.dart';

class BookingTabsBar extends StatelessWidget {
  const BookingTabsBar({
    super.key,
    required this.activeTab,
    required this.counts,
    required this.onTabSelected,
  });

  final BookingsTab activeTab;
  final Map<BookingsTab, int> counts;
  final ValueChanged<BookingsTab> onTabSelected;

  static const _tabs = [
    BookingsTab.upcoming,
    BookingsTab.current,
    BookingsTab.pending,
    BookingsTab.completed,
    BookingsTab.cancelled,
    BookingsTab.all,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isActive = tab == activeTab;
          final count = counts[tab] ?? 0;

          return GestureDetector(
            onTap: () => onTabSelected(tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFE8507A).withValues(alpha: 0.35)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: isActive
                    ? const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tabLabel(tab),
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? const Color(0xFFE8507A)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFE8507A)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            isActive ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
