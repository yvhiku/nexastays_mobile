import '../../../../core/storage/local_storage.dart';

/// Per-conversation composer drafts persisted via [LocalStorage].
class MessagingDraftStore {
  MessagingDraftStore(this._storage);

  final LocalStorage _storage;
  static const _prefix = 'conversation_draft_';

  String _key(String conversationId) => '$_prefix$conversationId';

  Future<String> loadDraft(String conversationId) async {
    return await _storage.getString(_key(conversationId)) ?? '';
  }

  Future<void> saveDraft(String conversationId, String text) async {
    if (text.trim().isEmpty) {
      await _storage.remove(_key(conversationId));
    } else {
      await _storage.setString(_key(conversationId), text);
    }
  }

  Future<void> clearDraft(String conversationId) async {
    await _storage.remove(_key(conversationId));
  }
}
