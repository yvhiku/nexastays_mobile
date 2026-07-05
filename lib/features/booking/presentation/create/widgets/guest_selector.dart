import 'package:flutter/material.dart';

class GuestSelector extends StatelessWidget {
  final int count;
  final int maxGuests;
  final ValueChanged<int> onChanged;

  const GuestSelector({
    super.key,
    required this.count,
    required this.maxGuests,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👥 Guests',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Max $maxGuests guests allowed',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: count > 1 ? () => onChanged(count - 1) : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 20,
                        color: count == 1
                            ? const Color(0xFFD1D5DB)
                            : const Color(0xFFE8507A),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: count < maxGuests ? () => onChanged(count + 1) : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: count < maxGuests
                            ? const Color(0xFFE8507A)
                            : const Color(0xFFE5E7EB),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: count < maxGuests
                            ? Colors.white
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (count == maxGuests) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                border: Border.all(color: const Color(0xFFFDE68A)),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Text(
                'Max guests reached',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFD97706),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
