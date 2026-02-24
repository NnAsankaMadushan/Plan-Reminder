import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_time_extensions.dart';
import '../../../calendar/presentation/bloc/calendar_bloc.dart';
import '../../domain/entities/reminder_event.dart';
import '../bloc/reminder_bloc.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({
    super.key,
    required this.onEventTap,
  });

  final ValueChanged<ReminderEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (BuildContext context, CalendarState state) {
        final now = DateTime.now();
        final upcoming = <ReminderEvent>[];
        final history = <ReminderEvent>[];

        for (final event in state.events) {
          final reminderTime = event.dateTime.subtract(
            const Duration(minutes: AppConstants.reminderOffsetMinutes),
          );

          if (reminderTime.isAfter(now)) {
            upcoming.add(event);
          } else {
            history.add(event);
          }
        }

        upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        history.sort((a, b) => b.dateTime.compareTo(a.dateTime));

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            children: <Widget>[
              _SectionHeader(
                title: 'Upcoming Notifications',
                count: upcoming.length,
              ),
              const SizedBox(height: 8),
              if (upcoming.isEmpty)
                const _EmptySection(
                  message: 'No upcoming reminders to notify yet.',
                )
              else
                ...upcoming.map(
                  (event) => _NotificationCard(
                    event: event,
                    isHistory: false,
                    onTap: () => onEventTap(event),
                  ),
                ),
              const SizedBox(height: 14),
              _SectionHeader(
                title: 'Notification History',
                count: history.length,
              ),
              const SizedBox(height: 8),
              if (history.isEmpty)
                const _EmptySection(
                  message: 'History will appear after reminder time passes.',
                )
              else
                ...history.map(
                  (event) => _NotificationCard(
                    event: event,
                    isHistory: true,
                    onTap: () => onEventTap(event),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text('$count'),
        ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(message),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.event,
    required this.isHistory,
    required this.onTap,
  });

  final ReminderEvent event;
  final bool isHistory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reminderTime = event.dateTime.subtract(
      const Duration(minutes: AppConstants.reminderOffsetMinutes),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: isHistory ? 0.08 : 0.16),
          child: Icon(
            isHistory ? Icons.notifications_none : Icons.notifications_active,
            size: 18,
          ),
        ),
        title: Text(event.title),
        subtitle: Text(
          'Notify at ${reminderTime.toDateTimeLabel}\n'
          'Event at ${event.dateTime.toDateTimeLabel}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'cancel') {
              context
                  .read<ReminderBloc>()
                  .add(ReminderCancelRequested(event.id));
              return;
            }
            if (value == 'reschedule') {
              context
                  .read<ReminderBloc>()
                  .add(ReminderRescheduleRequested(event));
            }
          },
          itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'reschedule',
              child: Text('Reschedule'),
            ),
            PopupMenuItem<String>(
              value: 'cancel',
              child: Text('Cancel Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
