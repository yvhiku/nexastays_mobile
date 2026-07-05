import 'package:flutter/material.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime? selectedCheckIn;
  final DateTime? selectedCheckOut;
  final List<DateTime> blockedDates;
  final void Function(DateTime checkIn, DateTime checkOut) onDatesSelected;

  const DatePickerWidget({
    required this.selectedCheckIn,
    required this.selectedCheckOut,
    required this.blockedDates,
    required this.onDatesSelected,
    super.key,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _formatDate(DateTime d) => '${_days[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';

  @override
  Widget build(BuildContext context) {
    final int? nights = (selectedCheckIn != null && selectedCheckOut != null)
        ? selectedCheckOut!.difference(selectedCheckIn!).inDays
        : null;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DateBox(
                label: 'CHECK-IN',
                date: selectedCheckIn,
                onTap: () => _pickDateRange(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DateBox(
                label: 'CHECK-OUT',
                date: selectedCheckOut,
                onTap: () => _pickDateRange(context),
              ),
            ),
          ],
        ),

        // Nights indicator
        if (nights != null && nights > 0) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8507A),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '$nights ${nights == 1 ? 'night' : 'nights'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFE5E7EB),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    // Start of day to avoid time-of-day selection issues
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = today.add(const Duration(days: 365));

    final result = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: maxDate,
      initialDateRange: selectedCheckIn != null && selectedCheckOut != null
          ? DateTimeRange(start: selectedCheckIn!, end: selectedCheckOut!)
          : null,
      selectableDayPredicate: (DateTime day, DateTime? start, DateTime? end) {
        // Only allow days that are not in the blocked list
        return !blockedDates.any((blocked) =>
            blocked.year == day.year &&
            blocked.month == day.month &&
            blocked.day == day.day);
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE8507A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A2E),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE8507A),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      onDatesSelected(result.start, result.end);
    }
  }

  Widget _DateBox({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final hasDate = date != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasDate ? const Color(0xFFFFF0F5) : Colors.white,
          border: Border.all(
            color: hasDate ? const Color(0xFFE8507A) : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: hasDate ? const Color(0xFFE8507A) : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 6),
            if (hasDate) ...[
              Text(
                _formatDate(date),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date.year.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
            ] else ...[
              const Text(
                'Add date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
