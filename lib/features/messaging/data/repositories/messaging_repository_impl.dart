import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../datasources/messaging_remote_datasource.dart';
import '../models/conversation_model.dart';

class MessagingRepositoryImpl implements MessagingRepository {
  MessagingRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorage,
  });

  final MessagingRemoteDataSource remoteDataSource;
  final LocalStorage localStorage;

  static const _conversationsKey = 'cached_conversations';

  Future<void> _cacheConversations(List<ConversationModel> models) async {
    final jsonList = models.map((m) => m.toJson()).toList();
    await localStorage.setString(_conversationsKey, jsonEncode(jsonList));
  }

  Future<List<ConversationModel>?> _readCachedConversations() async {
    final raw = await localStorage.getString(_conversationsKey);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Either<Failure, List<Conversation>>> getConversations({
    InboxFilter filter = 'all',
    String? query,
  }) async {
    try {
      final models = await remoteDataSource.getConversations(
        filter: filter,
        query: query,
      );
      await _cacheConversations(models);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      final cached = await _readCachedConversations();
      if (cached != null) return Right(cached);
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Conversation>> getConversation(
    String conversationId, {
    int? beforeSequence,
  }) async {
    try {
      final model = await remoteDataSource.getConversation(
        conversationId,
        beforeSequence: beforeSequence,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ({List<Message> messages, bool hasMore})>>
      getMessages(
    String conversationId, {
    int limit = 30,
    int? beforeSequence,
  }) async {
    try {
      final page = await remoteDataSource.getMessages(
        conversationId,
        limit: limit,
        beforeSequence: beforeSequence,
      );
      return Right((messages: page.messages, hasMore: page.hasMore));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage(
    String conversationId,
    String body, {
    String? clientMessageId,
  }) async {
    try {
      final model = await remoteDataSource.sendMessage(
        conversationId,
        body,
        clientMessageId: clientMessageId,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markRead(String conversationId) async {
    try {
      await remoteDataSource.markRead(conversationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }
}
