import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/draft/draft_store.dart';
import '../../data/push_sync.dart';
import '../../data/realtime/messaging_realtime_adapter.dart';
import '../../domain/repositories/messaging_repository.dart';
import 'conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  ConversationCubit({
    required MessagingRepository repository,
    required MessagingDraftStore draftStore,
    required MessagingRealtimeAdapter realtimeAdapter,
  })  : _repository = repository,
        _draftStore = draftStore,
        _realtimeAdapter = realtimeAdapter,
        super(const ConversationInitial());

  final MessagingRepository _repository;
  final MessagingDraftStore _draftStore;
  final MessagingRealtimeAdapter _realtimeAdapter;

  String _clientMessageId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';

  String? _conversationId;
  int? _expectedVersion;
  String? _lastMessageId;

  Future<void> loadConversation(
    String conversationId, {
    int? conversationVersion,
    String? lastMessageId,
  }) async {
    _conversationId = conversationId;
    _expectedVersion = conversationVersion;
    _lastMessageId = lastMessageId;

    emit(const ConversationLoading());

    final draft = await _draftStore.loadDraft(conversationId);

    final result = await _repository.getConversation(conversationId);
    await result.fold(
      (failure) async => emit(ConversationError(message: failure.message)),
      (conversation) async {
        await _repository.markRead(conversationId);
        emit(ConversationLoaded(
          conversation: conversation,
          messages: conversation.messages,
          hasMore: conversation.hasMore,
          draft: draft,
        ));
      },
    );
  }

  Future<void> refresh() async {
    final current = state;
    if (current is! ConversationLoaded || _conversationId == null) return;

    if (_expectedVersion != null &&
        !MessagingPushSync.shouldFetch(
          localVersion: current.conversation.conversationVersion,
          pushVersion: _expectedVersion,
        )) {
      return;
    }

    final result = await _repository.getConversation(_conversationId!);
    result.fold(
      (_) {},
      (conversation) {
        final versionChanged = _expectedVersion != null &&
            conversation.conversationVersion != _expectedVersion;
        final hasNewMessages = conversation.messages.isNotEmpty &&
            conversation.messages.last.id != _lastMessageId;

        if (versionChanged || hasNewMessages || conversation.messages.length != current.messages.length) {
          _expectedVersion = conversation.conversationVersion;
          if (conversation.messages.isNotEmpty) {
            _lastMessageId = conversation.messages.last.id;
          }
          emit(current.copyWith(
            conversation: conversation,
            messages: conversation.messages,
            hasMore: conversation.hasMore,
          ));
        }
      },
    );
  }

  Future<void> loadOlderMessages() async {
    final current = state;
    if (current is! ConversationLoaded ||
        !current.hasMore ||
        current.messages.isEmpty ||
        _conversationId == null) {
      return;
    }

    final beforeSequence = current.messages.first.conversationSequence;
    final result = await _repository.getMessages(
      _conversationId!,
      beforeSequence: beforeSequence,
    );

    result.fold(
      (_) {},
      (page) {
        emit(current.copyWith(
          messages: [...page.messages, ...current.messages],
          hasMore: page.hasMore,
        ));
      },
    );
  }

  Future<void> updateDraft(String text) async {
    final current = state;
    if (current is! ConversationLoaded || _conversationId == null) return;
    emit(current.copyWith(draft: text));
    await _draftStore.saveDraft(_conversationId!, text);
    _realtimeAdapter.bumpActivity();
  }

  Future<void> sendMessage() async {
    final current = state;
    if (current is! ConversationLoaded ||
        _conversationId == null ||
        current.draft.trim().isEmpty ||
        !current.conversation.permissions.canSend) {
      return;
    }

    final body = current.draft.trim();
    final clientMessageId = _clientMessageId();
    emit(current.copyWith(isSending: true));

    final result = await _repository.sendMessage(
      _conversationId!,
      body,
      clientMessageId: clientMessageId,
    );

    await result.fold(
      (failure) async {
        emit(ConversationError(message: failure.message));
      },
      (message) async {
        await _draftStore.clearDraft(_conversationId!);
        final updatedMessages = [...current.messages, message];
        _lastMessageId = message.id;
        emit(ConversationLoaded(
          conversation: current.conversation,
          messages: updatedMessages,
          hasMore: current.hasMore,
          draft: '',
        ));
        _realtimeAdapter.bumpActivity();
      },
    );
  }

  void startPolling() {
    _realtimeAdapter.start(MessagingRealtimeMode.conversation, refresh);
  }

  void stopPolling() {
    _realtimeAdapter.stop();
  }

  void onUserActivity() {
    _realtimeAdapter.bumpActivity();
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}
