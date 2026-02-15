import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/date_time_extensions.dart';
import '../../../calendar/presentation/bloc/calendar_bloc.dart';
import '../../../parser/domain/entities/parsed_event.dart';
import '../../../reminder/domain/entities/reminder_event.dart';
import '../../../reminder/presentation/bloc/reminder_bloc.dart';
import '../../../reminder/presentation/pages/add_edit_event_screen.dart';
import '../../../reminder/presentation/pages/event_detail_screen.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/parse_preview_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final Uuid _uuid = const Uuid();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }

    context.read<ChatBloc>().add(ChatMessageSubmitted(message));
    _messageController.clear();
    context.read<ChatBloc>().add(const ChatDraftUpdated(''));
  }

  Future<void> _confirmParsedEvent(ParsedEvent parsedEvent) async {
    var dateTime = parsedEvent.dateTime;

    if (!parsedEvent.hasExplicitTime) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(parsedEvent.dateTime),
      );

      if (selectedTime == null || !mounted) {
        return;
      }

      dateTime = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    }

    if (!mounted) {
      return;
    }

    final reminderEvent = ReminderEvent(
      id: _uuid.v4(),
      title: parsedEvent.title,
      dateTime: dateTime,
      location: parsedEvent.location,
      createdAt: DateTime.now(),
      sourceText: parsedEvent.sourceText,
    );

    context.read<CalendarBloc>().add(CalendarEventSaved(reminderEvent));
    context.read<ReminderBloc>().add(ReminderScheduleRequested(reminderEvent));
    context.read<ChatBloc>().add(ChatReminderConfirmed(reminderEvent));
  }

  Future<void> _editParsedEvent(ParsedEvent parsedEvent) async {
    final reminderEvent = await Navigator.of(context).push<ReminderEvent>(
      MaterialPageRoute<ReminderEvent>(
        builder: (_) => AddEditEventScreen(parsedEvent: parsedEvent),
      ),
    );

    if (reminderEvent == null || !mounted) {
      return;
    }

    context.read<CalendarBloc>().add(CalendarEventSaved(reminderEvent));
    context.read<ReminderBloc>().add(ReminderScheduleRequested(reminderEvent));
    context.read<ChatBloc>().add(ChatReminderConfirmed(reminderEvent));
  }

  void _toggleVoice(ChatState state) {
    if (state.status == ChatStatus.listening) {
      context.read<ChatBloc>().add(const ChatVoiceInputStopped());
      return;
    }
    context.read<ChatBloc>().add(const ChatVoiceInputStarted());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatBloc, ChatState>(
          listenWhen: (ChatState previous, ChatState current) =>
              previous.draftText != current.draftText,
          listener: (BuildContext context, ChatState state) {
            if (_messageController.text == state.draftText) {
              return;
            }

            _messageController.value = TextEditingValue(
              text: state.draftText,
              selection: TextSelection.collapsed(
                offset: state.draftText.length,
              ),
            );
          },
        ),
        BlocListener<ReminderBloc, ReminderState>(
          listenWhen: (ReminderState previous, ReminderState current) =>
              previous.status != current.status,
          listener: (BuildContext context, ReminderState state) {
            if (state.status == ReminderStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (BuildContext context, ChatState chatState) {
          return SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                    itemCount: chatState.messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final message = chatState.messages[index];
                      return ChatBubble(
                        key: ValueKey<String>(message.id),
                        message: message,
                      )
                          .animate()
                          .fadeIn(duration: 220.ms)
                          .slideY(begin: 0.12, end: 0);
                    },
                  ),
                ),
                _RecentReminderSection(
                  onTapEvent: (ReminderEvent event) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => EventDetailScreen(event: event),
                      ),
                    );
                  },
                ),
                if (chatState.parsedEvent != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: ParsePreviewCard(
                      parsedEvent: chatState.parsedEvent!,
                      onConfirm: () => _confirmParsedEvent(chatState.parsedEvent!),
                      onEdit: () => _editParsedEvent(chatState.parsedEvent!),
                      onDismiss: () {
                        context.read<ChatBloc>().add(
                              const ChatParsedEventDismissed(),
                            );
                      },
                    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.15, end: 0),
                  ),
                _Composer(
                  controller: _messageController,
                  isListening: chatState.status == ChatStatus.listening,
                  onVoiceTap: () => _toggleVoice(chatState),
                  onSendTap: _sendMessage,
                  onChanged: (String value) {
                    context.read<ChatBloc>().add(ChatDraftUpdated(value));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isListening,
    required this.onVoiceTap,
    required this.onSendTap,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onVoiceTap;
  final VoidCallback onSendTap;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onChanged: onChanged,
              onSubmitted: (_) => onSendTap(),
              decoration: const InputDecoration(
                hintText: 'Meeting with Sarah tomorrow at 10 am',
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: isListening ? 1.1 : 1,
            child: IconButton.filledTonal(
              onPressed: onVoiceTap,
              icon: Icon(isListening ? Icons.stop : Icons.mic_none),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onSendTap,
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}

class _RecentReminderSection extends StatelessWidget {
  const _RecentReminderSection({required this.onTapEvent});

  final ValueChanged<ReminderEvent> onTapEvent;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (BuildContext context, CalendarState state) {
        final now = DateTime.now();
        final events = state.events
            .where((ReminderEvent event) => event.dateTime.isAfter(now))
            .toList()
          ..sort(
            (ReminderEvent a, ReminderEvent b) =>
                a.dateTime.compareTo(b.dateTime),
          );

        final recent = events.take(3).toList();
        if (recent.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Upcoming',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recent
                    .map(
                      (ReminderEvent event) => ActionChip(
                        label: Text(
                          '${event.title} • ${event.dateTime.toTimeLabel}',
                        ),
                        onPressed: () => onTapEvent(event),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
