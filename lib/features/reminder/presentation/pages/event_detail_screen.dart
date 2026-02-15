import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/date_time_extensions.dart';
import '../../../calendar/presentation/bloc/calendar_bloc.dart';
import '../../domain/entities/reminder_event.dart';
import '../bloc/reminder_bloc.dart';
import 'add_edit_event_screen.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({
    super.key,
    required this.event,
  });

  final ReminderEvent event;

  Future<void> _editEvent(BuildContext context) async {
    final updatedEvent = await Navigator.of(context).push<ReminderEvent>(
      MaterialPageRoute<ReminderEvent>(
        builder: (_) => AddEditEventScreen(initialEvent: event),
      ),
    );

    if (updatedEvent == null || !context.mounted) {
      return;
    }

    context.read<CalendarBloc>().add(CalendarEventSaved(updatedEvent));
    context.read<ReminderBloc>().add(ReminderRescheduleRequested(updatedEvent));
    Navigator.of(context).pop();
  }

  Future<void> _deleteEvent(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('This event and its reminder will be removed.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    context.read<CalendarBloc>().add(CalendarEventDeleted(event.id));
    context.read<ReminderBloc>().add(ReminderCancelRequested(event.id));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(event.title, style: textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Date: ${event.dateTime.toDateLabel}'),
                      const SizedBox(height: 4),
                      Text('Time: ${event.dateTime.toTimeLabel}'),
                      const SizedBox(height: 4),
                      Text('Location: ${event.location ?? 'Not set'}'),
                      const SizedBox(height: 4),
                      Text('Created: ${event.createdAt.toDateTimeLabel}'),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _editEvent(context),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _deleteEvent(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
