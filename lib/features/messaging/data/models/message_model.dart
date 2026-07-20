import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.conversationSequence,
    super.senderId,
    required super.type,
    super.body,
    required super.metadata,
    required super.status,
    super.sentAt,
    super.deliveredAt,
    super.readAt,
    required super.isSystem,
    super.clientMessageId,
    required super.createdAt,
    required super.isOwn,
  });

  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      conversationSequence:
          (json['conversationSequence'] as num?)?.toInt() ?? 0,
      senderId: json['senderId'] as String?,
      type: json['type'] as String? ?? 'TEXT',
      body: json['body'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
      status: json['status'] as String? ?? 'PERSISTED',
      sentAt: parseDate(json['sentAt']),
      deliveredAt: parseDate(json['deliveredAt']),
      readAt: parseDate(json['readAt']),
      isSystem: json['isSystem'] as bool? ?? false,
      clientMessageId: json['clientMessageId'] as String?,
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
      isOwn: json['isOwn'] as bool? ?? false,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'conversationSequence': conversationSequence,
        'senderId': senderId,
        'type': type,
        'body': body,
        'metadata': metadata,
        'status': status,
        'sentAt': sentAt?.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'readAt': readAt?.toIso8601String(),
        'isSystem': isSystem,
        'clientMessageId': clientMessageId,
        'createdAt': createdAt.toIso8601String(),
        'isOwn': isOwn,
      };
}
