import 'package:equatable/equatable.dart';

import '../../domain/entities/conversation.dart';

sealed class InboxState extends Equatable {
  const InboxState();

  @override
  List<Object?> get props => [];
}

class InboxInitial extends InboxState {
  const InboxInitial();
}

class InboxLoading extends InboxState {
  const InboxLoading();
}

class InboxLoaded extends InboxState {
  const InboxLoaded({
    required this.conversations,
    required this.unreadCount,
    this.filter = 'active',
    this.query = '',
  });

  final List<Conversation> conversations;
  final int unreadCount;
  final String filter;
  final String query;

  InboxLoaded copyWith({
    List<Conversation>? conversations,
    int? unreadCount,
    String? filter,
    String? query,
  }) {
    return InboxLoaded(
      conversations: conversations ?? this.conversations,
      unreadCount: unreadCount ?? this.unreadCount,
      filter: filter ?? this.filter,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [conversations, unreadCount, filter, query];
}

class InboxEmpty extends InboxState {
  const InboxEmpty({
    this.unreadCount = 0,
    this.filter = 'active',
    this.query = '',
  });

  final int unreadCount;
  final String filter;
  final String query;

  @override
  List<Object?> get props => [unreadCount, filter, query];
}

class InboxError extends InboxState {
  const InboxError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Lightweight state for header badge only.
class InboxUnreadLoaded extends InboxState {
  const InboxUnreadLoaded({required this.unreadCount});

  final int unreadCount;

  @override
  List<Object?> get props => [unreadCount];
}
