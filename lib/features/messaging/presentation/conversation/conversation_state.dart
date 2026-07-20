import 'package:equatable/equatable.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

sealed class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {
  const ConversationInitial();
}

class ConversationLoading extends ConversationState {
  const ConversationLoading();
}

class ConversationLoaded extends ConversationState {
  const ConversationLoaded({
    required this.conversation,
    required this.messages,
    required this.hasMore,
    this.isSending = false,
    this.draft = '',
  });

  final Conversation conversation;
  final List<Message> messages;
  final bool hasMore;
  final bool isSending;
  final String draft;

  ConversationLoaded copyWith({
    Conversation? conversation,
    List<Message>? messages,
    bool? hasMore,
    bool? isSending,
    String? draft,
  }) {
    return ConversationLoaded(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      isSending: isSending ?? this.isSending,
      draft: draft ?? this.draft,
    );
  }

  @override
  List<Object?> get props =>
      [conversation, messages, hasMore, isSending, draft];
}

class ConversationError extends ConversationState {
  const ConversationError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
