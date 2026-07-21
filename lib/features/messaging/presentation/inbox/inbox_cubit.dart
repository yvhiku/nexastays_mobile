import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/realtime/messaging_realtime_adapter.dart';
import '../../domain/repositories/messaging_repository.dart';
import 'inbox_state.dart';

class InboxCubit extends Cubit<InboxState> {
  InboxCubit({
    required MessagingRepository repository,
    required MessagingRealtimeAdapter realtimeAdapter,
  })  : _repository = repository,
        _realtimeAdapter = realtimeAdapter,
        super(const InboxInitial());

  final MessagingRepository _repository;
  final MessagingRealtimeAdapter _realtimeAdapter;

  Future<void> loadUnreadCount() async {
    final result = await _repository.getUnreadCount();
    result.fold(
      (_) {},
      (count) => emit(InboxUnreadLoaded(unreadCount: count)),
    );
  }

  Future<void> loadConversations({String filter = 'active', String? query}) async {
    emit(const InboxLoading());
    final unreadResult = await _repository.getUnreadCount();
    final unreadCount = unreadResult.fold((_) => 0, (c) => c);

    final result = await _repository.getConversations(
      filter: filter,
      query: query,
    );

    result.fold(
      (failure) => emit(InboxError(message: failure.message)),
      (conversations) {
        if (conversations.isEmpty) {
          emit(InboxEmpty(
            unreadCount: unreadCount,
            filter: filter,
            query: query ?? '',
          ));
        } else {
          emit(InboxLoaded(
            conversations: conversations,
            unreadCount: unreadCount,
            filter: filter,
            query: query ?? '',
          ));
        }
      },
    );
  }

  Future<void> setFilter(String filter) async {
    final current = state;
    final query = current is InboxLoaded
        ? current.query
        : current is InboxEmpty
            ? current.query
            : '';
    await loadConversations(filter: filter, query: query);
  }

  Future<void> refresh() async {
    final current = state;
    if (current is InboxLoaded) {
      await loadConversations(filter: current.filter, query: current.query);
    } else if (current is InboxEmpty) {
      await loadConversations(filter: current.filter, query: current.query);
    } else {
      await loadUnreadCount();
    }
  }

  void startPolling() {
    _realtimeAdapter.start(MessagingRealtimeMode.inbox, refresh);
  }

  void stopPolling() {
    _realtimeAdapter.stop();
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}
