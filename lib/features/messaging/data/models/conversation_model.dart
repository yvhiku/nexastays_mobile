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
    super.postStayEndsAt,
    super.messages,
    super.hasMore,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('conversation')) {
      return ConversationModel._fromV3(json);
    }
    return ConversationModel._fromLegacy(json);
  }

  factory ConversationModel._fromV3(Map<String, dynamic> json) {
    final conv = json['conversation'] as Map<String, dynamic>? ?? const {};
    final pres = json['presentation'] as Map<String, dynamic>? ?? const {};
    final sync = json['sync'] as Map<String, dynamic>? ?? const {};
    final last = json['lastMessage'] as Map<String, dynamic>? ?? const {};
    final perms = json['permissions'] as Map<String, dynamic>? ?? const {};
    final counterpart =
        pres['counterpart'] as Map<String, dynamic>? ?? const {};
    final listing = pres['listing'] as Map<String, dynamic>? ?? const {};
    final reservation =
        pres['reservation'] as Map<String, dynamic>? ?? const {};
    final timeline = json['timeline'] as List<dynamic>? ??
        json['messages'] as List<dynamic>? ??
        const [];

    return ConversationModel(
      id: conv['id'] as String? ?? '',
      type: conv['type'] as String? ?? 'BOOKING',
      messagingState: conv['messagingState'] as String? ?? 'ACTIVE',
      visibility: conv['visibility'] as String? ?? 'ACTIVE',
      conversationVersion:
          (sync['conversationVersion'] as num?)?.toInt() ??
              (conv['conversationVersion'] as num?)?.toInt() ??
              1,
      lastMessageSequence:
          int.tryParse('${sync['lastMessageId'] ?? ''}') ??
              (sync['conversationVersion'] as num?)?.toInt() ??
              0,
      unreadCount: (sync['unreadCount'] as num?)?.toInt() ?? 0,
      counterpart: ConversationCounterpart(
        name: counterpart['displayName'] as String? ??
            pres['title'] as String? ??
            'Guest',
        avatarUrl: (pres['avatar'] as Map<String, dynamic>?)?['url']
            as String?,
        isSuperhost: counterpart['verified'] as bool? ?? false,
      ),
      listing: ConversationListing(
        title: listing['title'] as String? ??
            reservation['listingTitle'] as String? ??
            'Stay',
        city: listing['city'] as String?,
      ),
      lastMessage: ConversationLastMessage(
        preview: last['preview'] as String?,
        at: MessageModel.parseDate(last['at']),
      ),
      reservationSnapshot: ReservationSnapshotModel.fromJson({
        'listingTitle': reservation['listingTitle'] ?? listing['title'],
        'listingId': reservation['listingId'],
        'checkinDate': reservation['checkinDate'],
        'checkoutDate': reservation['checkoutDate'],
        'guestCount': reservation['guestCount'],
        'bookingReference': reservation['bookingReference'],
        'bookingId': reservation['bookingId'] ?? conv['bookingId'],
        'city': reservation['city'] ?? listing['city'],
        'coverMediaId': reservation['coverMedia']?['url'],
        'primaryPhotoUrl': reservation['coverMedia']?['url'],
      }),
      permissions: ConversationPermissionsModel.fromJson(perms),
      bookingId: conv['bookingId'] as String? ?? reservation['bookingId'] as String?,
      bookingStatus: json['bookingStatus'] as String?,
      postStayEndsAt: MessageModel.parseDate(conv['postStayEndsAt']),
      messages: timeline
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  factory ConversationModel._fromLegacy(Map<String, dynamic> json) {
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
      postStayEndsAt: MessageModel.parseDate(json['postStayEndsAt']),
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
        'postStayEndsAt': postStayEndsAt?.toIso8601String(),
        'messages': messages.map((m) => (m as MessageModel).toJson()).toList(),
        'hasMore': hasMore,
      };
}
