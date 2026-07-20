/// Version-aware sync after push — skip fetch when local state is current.
class MessagingPushSync {
  static bool shouldFetch({
    int? localVersion,
    int? pushVersion,
  }) {
    if (pushVersion == null) return true;
    if (localVersion == null) return true;
    return localVersion < pushVersion;
  }
}
