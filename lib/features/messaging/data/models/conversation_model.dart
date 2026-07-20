import '../../domain/entities/conversation.dart';
import 'conversation_permissions_model.dart';
import 'message_model.dart';
import 'reservation_snapshot_model.dart';

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.type,
    required super.messagingState,
    required super.visibility,
    required super.conversationVersion,
    required super.lastMessageSequence,
    required super.unreadCount,
    required super.counterpart,
    required super.listing,
    required super.lastMessage,
    required super.reservationSnapshot,
    required super.permissions,
    super.bookingId,
    super.bookingStatus,
    super.messages,
    super.hasMore,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final counterpartJson =
        json['counterpart'] as Map<String, dynamic>? ?? const {};
    final listingJson = json['listing'] as Map<String, dynamic>? ?? const {};
    final lastMessageJson =
        json['lastMessage'] as Map<String, dynamic>? ?? const {};
    final snapshotJson =
        json['reservationSnapshot'] as Map<String, dynamic>? ?? const {};
    final permissionsJson =
        json['permissions'] as Map<String, dynamic>? ?? const {};
    final messagesJson = json['messages'] as List<dynamic>? ?? const [];

    return ConversationModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'BOOKING',
      messagingState: json['messagingState'] as String? ?? 'ACTIVE',
      visibility: json['visibility'] as String? ?? 'ACTIVE',
      conversationVersion:
          (json['conversationVersion'] as num?)?.toInt() ?? 1,
      lastMessageSequence:
          (json['lastMessageSequence'] as num?)?.toInt() ?? 0,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      counterpart: ConversationCounterpart(
        name: counterpartJson['name'] as String? ?? 'Guest',
        avatarUrl: counterpartJson['avatarUrl'] as String?,
        isSuperhost: counterpartJson['isSuperhost'] as bool? ?? false,
      ),
      listing: ConversationListing(
        title: listingJson['title'] as String? ?? 'Stay',
        city: listingJson['city'] as String?,
      ),
      lastMessage: ConversationLastMessage(
        preview: lastMessageJson['preview'] as String?,
        at: MessageModel.parseDate(lastMessageJson['at']),
        deliveryStatus: lastMessageJson['deliveryStatus'] as String?,
      ),
      reservationSnapshot: ReservationSnapshotModel.fromJson(snapshotJson),
      permissions: ConversationPermissionsModel.fromJson(permissionsJson),
      bookingId: json['bookingId'] as String?,
      bookingStatus: json['bookingStatus'] as String?,
      messages: messagesJson
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'messagingState': messagingState,
        'visibility': visibility,
        'conversationVersion': conversationVersion,
        'lastMessageSequence': lastMessageSequence,
        'unreadCount': unreadCount,
        'counterpart': {
          'name': counterpart.name,
          'avatarUrl': counterpart.avatarUrl,
          'isSuperhost': counterpart.isSuperhost,
        },
        'listing': {
          'title': listing.title,
          'city': listing.city,
        },
        'lastMessage': {
          'preview': lastMessage.preview,
          'at': lastMessage.at?.toIso8601String(),
          'deliveryStatus': lastMessage.deliveryStatus,
        },
        'reservationSnapshot':
            (reservationSnapshot as ReservationSnapshotModel).toJson(),
        'permissions':
            (permissions as ConversationPermissionsModel).toJson(),
        'bookingId': bookingId,
        'bookingStatus': bookingStatus,
        'messages': messages.map((m) => (m as MessageModel).toJson()).toList(),
        'hasMore': hasMore,
      };
}
