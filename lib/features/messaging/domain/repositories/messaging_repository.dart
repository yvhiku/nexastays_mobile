import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

typedef InboxFilter = String;

abstract class MessagingRepository {
  Future<Either<Failure, List<Conversation>>> getConversations({
    InboxFilter filter,
    String? query,
  });

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, Conversation>> getConversation(
    String conversationId, {
    int? beforeSequence,
  });

  Future<Either<Failure, ({List<Message> messages, bool hasMore})>> getMessages(
    String conversationId, {
    int limit,
    int? beforeSequence,
  });

  Future<Either<Failure, Message>> sendMessage(
    String conversationId,
    String body, {
    String? clientMessageId,
  });

  Future<Either<Failure, void>> markRead(String conversationId);
}
