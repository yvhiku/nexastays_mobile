import 'package:equatable/equatable.dart';

class Message extends Equatable {
  const Message({
    required this.id,
    required this.conversationId,
    required this.conversationSequence,
    this.senderId,
    required this.type,
    this.body,
    required this.metadata,
    required this.status,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
    required this.isSystem,
    this.clientMessageId,
    required this.createdAt,
    required this.isOwn,
  });

  final String id;
  final String conversationId;
  final int conversationSequence;
  final String? senderId;
  final String type;
  final String? body;
  final Map<String, dynamic> metadata;
  final String status;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final bool isSystem;
  final String? clientMessageId;
  final DateTime createdAt;
  final bool isOwn;

  bool get isText => type == 'TEXT';
  bool get isTimelineCard =>
      type == 'SYSTEM_EVENT' ||
      type == 'BOOKING_CARD' ||
      type == 'PROPERTY_CARD' ||
      isSystem;

  @override
  List<Object?> get props => [
        id,
        conversationId,
        conversationSequence,
        senderId,
        type,
        body,
        metadata,
        status,
        sentAt,
        deliveredAt,
        readAt,
        isSystem,
        clientMessageId,
        createdAt,
        isOwn,
      ];
}
