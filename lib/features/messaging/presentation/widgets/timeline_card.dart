import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/tokens/colors.dart';
import '../../../booking/presentation/list/widgets/booking_review_sheet.dart';
import '../../domain/entities/message.dart';

class TimelineCard extends StatelessWidget {
  const TimelineCard({
    required this.message,
    this.viewerRole = 'guest',
    super.key,
  });

  final Message message;
  final String viewerRole;

  @override
  Widget build(BuildContext context) {
    final metadata = message.metadata;
    final reviewed = metadata['reviewed'] == true;
    final isGuest = viewerRole != 'host';
    final roleView = _readRoleView(metadata, isGuest ? 'guestView' : 'hostView');
    final bookingId = metadata['bookingId'] as String?;
    final listingId = metadata['listingId'] as String?;

    var title = roleView?['title'] as String? ??
        metadata['title'] as String? ??
        _defaultTitle(message.type);
    var body = message.body ?? roleView?['body'] as String? ?? metadata['body'] as String?;
    final iconName = metadata['icon'] as String?;
    var actions = reviewed
        ? const <dynamic>[]
        : (roleView?['actions'] as List<dynamic>? ??
            metadata['actions'] as List<dynamic>? ??
            const []);

    if (roleView == null) {
      if (isGuest) {
        if (reviewed) {
          title = 'Thanks for reviewing!';
          body = 'Your feedback helps future travelers.';
          actions = const [];
        }
      } else if (reviewed) {
        title = 'Guest reviewed successfully';
        body = 'Your guest shared feedback about their stay.';
        actions = listingId != null
            ? [
                {
                  'id': 'view_review',
                  'label': 'View review',
                  'type': 'deep_link',
                  'url': '/listings/$listingId#reviews',
                },
              ]
            : const [];
      } else {
        title = 'Review request sent';
        body = 'Your guest can leave a review for this stay.';
        actions = const [];
      }
    } else if (!isGuest && reviewed && actions.isEmpty && listingId != null) {
      actions = [
        {
          'id': 'view_review',
          'label': 'View review',
          'type': 'deep_link',
          'url': '/listings/$listingId#reviews',
        },
      ];
    } else if (!isGuest && !reviewed) {
      actions = const [];
    } else if (isGuest && reviewed) {
      actions = const [];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isGuest && message.type == 'REVIEW_CARD'
                  ? Colors.white
                  : DSColors.background2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: message.type == 'REVIEW_CARD'
                    ? DSColors.primary.withValues(alpha: 0.15)
                    : DSColors.line,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (message.type == 'REVIEW_CARD')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (_) => const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: DSColors.primary,
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          _iconFor(iconName, message.type),
                          size: 20,
                          color: DSColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: DSColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (message.type == 'REVIEW_CARD') ...[
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: DSColors.ink,
                      ),
                    ),
                  ],
                  if (body != null && body.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: DSColors.ink3,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (reviewed && isGuest && message.type == 'REVIEW_CARD')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '✓',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          color: DSColors.primary,
                        ),
                      ),
                    ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: actions.map((action) {
                        final map = action as Map<String, dynamic>;
                        final label = map['label'] as String? ?? 'Open';
                        return FilledButton(
                          onPressed: () => _handleAction(context, map, bookingId),
                          style: FilledButton.styleFrom(
                            backgroundColor: DSColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(label),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic>? _readRoleView(
    Map<String, dynamic> metadata,
    String key,
  ) {
    final raw = metadata[key];
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  void _handleAction(
    BuildContext context,
    Map<String, dynamic> action,
    String? bookingId,
  ) {
    final url = action['url'] as String?;
    if (url != null && url.contains('/review')) {
      final id = _bookingIdFromUrl(url) ?? bookingId;
      if (id != null) {
        showBookingReviewSheet(context: context, bookingId: id);
        return;
      }
    }
    if (url != null && url.contains('/listings/')) {
      final listingMatch = RegExp(r'/listings/([^/?#]+)').firstMatch(url);
      if (listingMatch != null) {
        context.push('/listing/${listingMatch.group(1)}');
        return;
      }
    }
    if (url != null && url.contains('/bookings/')) {
      final id = _bookingIdFromUrl(url);
      if (id != null) {
        context.push('/booking/$id');
        return;
      }
    }
    if (url != null && url.contains('/contact')) {
      context.push('/contact');
    }
  }

  String? _bookingIdFromUrl(String url) {
    final match = RegExp(
      r'/bookings/([0-9a-fA-F-]{36})',
    ).firstMatch(url);
    return match?.group(1);
  }

  String _defaultTitle(String type) => switch (type) {
        'BOOKING_CARD' => 'Booking details',
        'PROPERTY_CARD' => 'Property',
        'REVIEW_CARD' => 'Review your stay',
        'SYSTEM_EVENT' => 'Update',
        'SYSTEM_NOTICE' => 'Notice',
        _ => 'Message',
      };

  IconData _iconFor(String? iconName, String type) {
    if (iconName != null) {
      return switch (iconName) {
        'calendar' => Icons.calendar_today_outlined,
        'home' => Icons.home_outlined,
        'check' => Icons.check_circle_outline,
        _ => Icons.info_outline,
      };
    }
    return switch (type) {
      'BOOKING_CARD' => Icons.receipt_long_outlined,
      'PROPERTY_CARD' => Icons.home_outlined,
      'REVIEW_CARD' => Icons.star_outline,
      _ => Icons.info_outline,
    };
  }
}
