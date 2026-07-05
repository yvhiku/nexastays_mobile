import 'package:flutter/material.dart';

import '../../../../../app/di/injection.dart';
import '../../../domain/repositories/booking_repository.dart';

/// Post-stay review — calls `POST /stays/bookings/:id/review`.
Future<bool?> showBookingReviewSheet({
  required BuildContext context,
  required String bookingId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _BookingReviewSheet(bookingId: bookingId),
  );
}

class _BookingReviewSheet extends StatefulWidget {
  const _BookingReviewSheet({required this.bookingId});

  final String bookingId;

  @override
  State<_BookingReviewSheet> createState() => _BookingReviewSheetState();
}

class _BookingReviewSheetState extends State<_BookingReviewSheet> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;
  String? _error;

  final _bookingRepository = getIt<BookingRepository>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    final result = await _bookingRepository.submitBookingReview(
      bookingId: widget.bookingId,
      rating: _rating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _submitting = false;
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Write a review',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Share your experience to help other guests.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return IconButton(
                  onPressed: _submitting ? null : () => setState(() => _rating = star),
                  icon: Icon(
                    star <= _rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFE8507A),
                    size: 36,
                  ),
                );
              }),
            ),
            TextField(
              controller: _commentController,
              maxLines: 4,
              enabled: !_submitting,
              decoration: InputDecoration(
                hintText: 'Tell us about your stay (optional)',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8507A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 0,
              ),
              child: Text(
                _submitting ? 'Submitting…' : 'Submit review',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
