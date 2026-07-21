import 'package:equatable/equatable.dart';

import 'conversation_permissions.dart';
import 'message.dart';
import 'reservation_snapshot.dart';

class ConversationCounterpart extends Equatable {
  const ConversationCounterpart({
    required this.name,
    this.avatarUrl,
    required this.isSuperhost,
  });

  final String name;
  final String? avatarUrl;
  final bool isSuperhost;

  @override
  List<Object?> get props => [name, avatarUrl, isSuperhost];
}

class ConversationListing extends Equatable {
  const ConversationListing({
    required this.title,
    this.city,
  });

  final String title;
  final String? city;

  @override
  List<Object?> get props => [title, city];
}

class ConversationLastMessage extends Equatable {
  const ConversationLastMessage({
    this.preview,
    this.at,
    this.deliveryStatus,
  });

  final String? preview;
  final DateTime? at;
  final String? deliveryStatus;

  @override
  List<Object?> get props => [preview, at, deliveryStatus];
}

class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.type,
    required this.messagingState,
    required this.visibility,
    required this.conversationVersion,
    required this.lastMessageSequence,
    required this.unreadCount,
    required this.counterpart,
    required this.listing,
    required this.lastMessage,
    required this.reservationSnapshot,
    required this.permissions,
    this.bookingId,
    this.bookingStatus,
    this.postStayEndsAt,
    this.messages = const [],
    this.hasMore = false,
  });

  final String id;
  final String type;
  final String messagingState;
  final String visibility;
  final int conversationVersion;
  final int lastMessageSequence;
  final int unreadCount;
  final ConversationCounterpart counterpart;
  final ConversationListing listing;
  final ConversationLastMessage lastMessage;
  final ReservationSnapshot reservationSnapshot;
  final ConversationPermissions permissions;
  final String? bookingId;
  final String? bookingStatus;
  final DateTime? postStayEndsAt;
  final List<Message> messages;
  final bool hasMore;

  @override
  List<Object?> get props => [
        id,
        type,
        messagingState,
        visibility,
        conversationVersion,
        lastMessageSequence,
        unreadCount,
        counterpart,
        listing,
        lastMessage,
        reservationSnapshot,
        permissions,
        bookingId,
        bookingStatus,
        postStayEndsAt,
        messages,
        hasMore,
      ];
}
