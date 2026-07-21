import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/components/feedback/error_state.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../domain/entities/message.dart';
import '../widgets/booking_summary_bar.dart';
import '../widgets/message_composer.dart';
import '../widgets/text_bubble.dart';
import '../widgets/timeline_card.dart';
import 'conversation_cubit.dart';
import 'conversation_state.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({
    required this.conversationId,
    this.conversationVersion,
    this.lastMessageId,
    super.key,
  });

  final String conversationId;
  final int? conversationVersion;
  final String? lastMessageId;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late final ConversationCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ConversationCubit>();
    _cubit.loadConversation(
      widget.conversationId,
      conversationVersion: widget.conversationVersion,
      lastMessageId: widget.lastMessageId,
    );
    _cubit.startPolling();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    _cubit.onUserActivity();
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 48) {
      _cubit.loadOlderMessages();
    }
  }

  @override
  void dispose() {
    _cubit.stopPolling();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _syncDraft(String draft) {
    if (_textController.text != draft) {
      _textController.text = draft;
      _textController.selection = TextSelection.collapsed(offset: draft.length);
    }
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
        title: BlocBuilder<ConversationCubit, ConversationState>(
          builder: (context, state) {
            if (state is ConversationLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.conversation.counterpart.name,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: DSColors.ink,
                    ),
                  ),
                  Text(
                    state.conversation.listing.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: DSColors.ink4,
                    ),
                  ),
                ],
              );
            }
            return Text(
              'Conversation',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            );
          },
        ),
      ),
      body: BlocConsumer<ConversationCubit, ConversationState>(
        listener: (context, state) {
          if (state is ConversationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is ConversationLoaded) {
            _syncDraft(state.draft);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        },
        builder: (context, state) {
          if (state is ConversationLoading || state is ConversationInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ConversationError) {
            return ErrorState(
              title: 'Could not load conversation',
              message: state.message,
              onRetry: () => context.read<ConversationCubit>().loadConversation(
                    widget.conversationId,
                    conversationVersion: widget.conversationVersion,
                    lastMessageId: widget.lastMessageId,
                  ),
            );
          }
          if (state is ConversationLoaded) {
            final archived = state.conversation.messagingState == 'ARCHIVED';
            return Column(
              children: [
                BookingSummaryBar(
                  snapshot: state.conversation.reservationSnapshot,
                  bookingId: state.conversation.bookingId,
                  counterpartName: state.conversation.counterpart.name,
                  messagingState: state.conversation.messagingState,
                  bookingStatus: state.conversation.bookingStatus,
                  postStayEndsAt: state.conversation.postStayEndsAt,
                  canReview: state.conversation.permissions.canReview,
                ),
                if (archived)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: DSColors.line),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Stay completed · This conversation has been archived.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                color: DSColors.ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Need help with this reservation?',
                              style: GoogleFonts.dmSans(color: DSColors.ink3),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FilledButton(
                                  onPressed: () => context.push('/contact'),
                                  child: const Text('Contact Support'),
                                ),
                                if (state.conversation.bookingId != null) ...[
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () => context.push(
                                      '/booking/${state.conversation.bookingId}',
                                    ),
                                    child: const Text('View reservation'),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return _MessageItem(message: message);
                    },
                  ),
                ),
                MessageComposer(
                  controller: _textController,
                  canSend: state.conversation.permissions.canSend,
                  isSending: state.isSending,
                  onChanged: (text) =>
                      context.read<ConversationCubit>().updateDraft(text),
                  onSend: () => context.read<ConversationCubit>().sendMessage(),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MessageItem extends StatelessWidget {
  const _MessageItem({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    if (message.isTimelineCard) {
      return TimelineCard(message: message);
    }
    return TextBubble(message: message);
  }
}
