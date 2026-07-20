import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class MessagingRemoteDataSource {
  Future<List<ConversationModel>> getConversations({
    String filter,
    String? query,
  });

  Future<int> getUnreadCount();

  Future<ConversationModel> getConversation(
    String conversationId, {
    int? beforeSequence,
  });

  Future<({List<MessageModel> messages, bool hasMore})> getMessages(
    String conversationId, {
    int limit,
    int? beforeSequence,
  });

  Future<MessageModel> sendMessage(
    String conversationId,
    String body, {
    String? clientMessageId,
  });

  Future<void> markRead(String conversationId);
}

class MessagingRemoteDataSourceImpl implements MessagingRemoteDataSource {
  MessagingRemoteDataSourceImpl(this._client);

  final DioClient _client;

  dynamic _unwrap(dynamic body) {
    if (body is Map) {
      final map = body is Map<String, dynamic>
          ? body
          : body.map((key, value) => MapEntry(key.toString(), value));
      final inner = map['data'];
      if (inner != null) return inner;
      return map;
    }
    return body;
  }

  Never _throwOnError(DioException e) {
    final message =
        e.response?.data?['message'] as String? ?? e.message ?? 'Server error';
    throw ServerException(message);
  }

  @override
  Future<List<ConversationModel>> getConversations({
    String filter = 'all',
    String? query,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.messagingConversations,
        queryParameters: {
          'filter': filter,
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        },
      );
      final data = _unwrap(response.data) as List<dynamic>;
      return data
          .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _client.get(ApiEndpoints.messagingUnreadCount);
      final data = _unwrap(response.data) as Map<String, dynamic>;
      return (data['count'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  @override
  Future<ConversationModel> getConversation(
    String conversationId, {
    int? beforeSequence,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.conversationById(conversationId),
        queryParameters: beforeSequence != null
            ? {'before_sequence': beforeSequence}
            : null,
      );
      final data = _unwrap(response.data) as Map<String, dynamic>;
      return ConversationModel.fromJson(data);
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  @override
  Future<({List<MessageModel> messages, bool hasMore})> getMessages(
    String conversationId, {
    int limit = 30,
    int? beforeSequence,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.conversationMessages(conversationId),
        queryParameters: {
          'limit': limit,
          if (beforeSequence != null) 'before_sequence': beforeSequence,
        },
      );
      final data = _unwrap(response.data) as Map<String, dynamic>;
      final messagesJson = data['messages'] as List<dynamic>? ?? const [];
      return (
        messages: messagesJson
            .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: data['hasMore'] as bool? ?? false,
      );
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  @override
  Future<MessageModel> sendMessage(
    String conversationId,
    String body, {
    String? clientMessageId,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.conversationMessages(conversationId),
        data: {
          'body': body,
          if (clientMessageId != null) 'client_message_id': clientMessageId,
        },
      );
      final data = _unwrap(response.data) as Map<String, dynamic>;
      return MessageModel.fromJson(data);
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  @override
  Future<void> markRead(String conversationId) async {
    try {
      await _client.post(ApiEndpoints.conversationRead(conversationId));
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }
}
