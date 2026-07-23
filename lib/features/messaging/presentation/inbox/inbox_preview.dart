String resolveRoleAwareInboxPreview(
  String? preview,
  String viewerRole,
) {
  final trimmed = preview?.trim() ?? '';
  if (trimmed.isEmpty) return 'No messages yet';
  if (viewerRole != 'host') return trimmed;

  switch (trimmed) {
    case 'Review your stay':
      return 'Review request sent';
    case 'Thanks for reviewing!':
    case 'Thanks for reviewing':
      return 'Guest reviewed successfully';
    default:
      return trimmed;
  }
}
