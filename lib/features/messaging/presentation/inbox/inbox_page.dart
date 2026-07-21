import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/components/feedback/empty_state.dart';
import '../../../../design_system/components/feedback/error_state.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../navigation/app_routes.dart';
import '../../domain/entities/conversation.dart';
import 'inbox_cubit.dart';
import 'inbox_state.dart';

const _filters = [
  ('active', 'Active stays'),
  ('unread', 'Unread'),
  ('support', 'Support'),
  ('archived', 'Archived'),
  ('all', 'All'),
];

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<InboxCubit>();
    cubit.loadConversations();
    cubit.startPolling();
  }

  @override
  void dispose() {
    context.read<InboxCubit>().stopPolling();
    super.dispose();
  }

  String _currentFilter(InboxState state) {
    if (state is InboxLoaded) return state.filter;
    if (state is InboxEmpty) return state.filter;
    return 'active';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Messages',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: DSColors.ink,
          ),
        ),
      ),
      body: BlocConsumer<InboxCubit, InboxState>(
        listener: (context, state) {
          if (state is InboxError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is InboxLoading || state is InboxInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is InboxError) {
            return ErrorState(
              title: 'Could not load messages',
              message: state.message,
              onRetry: () => context.read<InboxCubit>().loadConversations(),
            );
          }

          final currentFilter = _currentFilter(state);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final (value, label) = _filters[index];
                    final selected = currentFilter == value;
                    return FilterChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) =>
                          context.read<InboxCubit>().setFilter(value),
                      selectedColor: DSColors.primary,
                      labelStyle: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : DSColors.ink3,
                      ),
                      backgroundColor: DSColors.background2,
                      side: BorderSide.none,
                      showCheckmark: false,
                    );
                  },
                ),
              ),
              Expanded(
                child: switch (state) {
                  InboxEmpty() => const EmptyState(
                      title: 'No messages yet',
                      subtitle:
                          'When you book a stay, your host can message you here.',
                    ),
                  InboxLoaded(:final conversations) => RefreshIndicator(
                      onRefresh: () => context.read<InboxCubit>().refresh(),
                      color: DSColors.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: conversations.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          indent: 76,
                          color: DSColors.line,
                        ),
                        itemBuilder: (context, index) {
                          final conversation = conversations[index];
                          return _ConversationTile(conversation: conversation);
                        },
                      ),
                    ),
                  _ => const SizedBox.shrink(),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final preview = conversation.lastMessage.preview ?? 'No messages yet';
    final time = conversation.lastMessage.at;
    final timeLabel = time != null ? _formatTime(time) : '';
    final unread = conversation.unreadCount;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: DSColors.primarySoft,
        backgroundImage: conversation.counterpart.avatarUrl != null
            ? NetworkImage(conversation.counterpart.avatarUrl!)
            : null,
        child: conversation.counterpart.avatarUrl == null
            ? Text(
                conversation.counterpart.name.isNotEmpty
                    ? conversation.counterpart.name[0].toUpperCase()
                    : '?',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  color: DSColors.primary,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.counterpart.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
                fontSize: 15,
                color: DSColors.ink,
              ),
            ),
          ),
          if (timeLabel.isNotEmpty)
            Text(
              timeLabel,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: unread > 0 ? DSColors.primary : DSColors.ink4,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            conversation.listing.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(fontSize: 12, color: DSColors.ink4),
          ),
          const SizedBox(height: 2),
          Text(
            preview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: unread > 0 ? DSColors.ink2 : DSColors.ink3,
              fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
      trailing: unread > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DSColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unread > 99 ? '99+' : '$unread',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      onTap: () => context.push(AppRoutes.conversationOf(conversation.id)),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return DateFormat('h:mm a').format(time);
    }
    if (now.difference(time).inDays < 7) {
      return DateFormat('EEE').format(time);
    }
    return DateFormat('MMM d').format(time);
  }
}
