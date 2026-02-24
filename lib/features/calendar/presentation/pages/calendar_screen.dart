import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/utils/date_time_extensions.dart';
import '../../../google_calendar/domain/entities/google_calendar_event.dart';
import '../../../google_calendar/presentation/bloc/google_calendar_bloc.dart';
import '../../../reminder/domain/entities/reminder_event.dart';
import '../bloc/calendar_bloc.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({
    super.key,
    required this.onEventTap,
  });

  final ValueChanged<ReminderEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarBloc, CalendarState>(
      listenWhen: (CalendarState previous, CalendarState current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (BuildContext context, CalendarState state) {
        if (state.errorMessage == null) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      builder: (BuildContext context, CalendarState state) {
        return BlocBuilder<GoogleCalendarBloc, GoogleCalendarState>(
          builder:
              (BuildContext context, GoogleCalendarState googleCalendarState) {
            final googleEvents = googleCalendarState.isConnected
                ? googleCalendarState.events
                : const <GoogleCalendarEvent>[];
            final selectedItems = _selectedItemsForDay(
              selectedDay: state.selectedDay,
              reminderEvents: state.events,
              googleEvents: googleEvents,
            );

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Column(
                  children: <Widget>[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TableCalendar<Object>(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2100, 12, 31),
                          focusedDay: state.focusedDay,
                          eventLoader: (DateTime day) => <Object>[
                            ..._eventsForDay(day, state.events),
                            ..._googleEventsForDay(day, googleEvents),
                          ],
                          selectedDayPredicate: (DateTime day) =>
                              day.dateOnly == state.selectedDay.dateOnly,
                          onDaySelected:
                              (DateTime selectedDay, DateTime focusedDay) {
                            context.read<CalendarBloc>().add(
                                  CalendarDaySelected(
                                    selectedDay: selectedDay,
                                    focusedDay: focusedDay,
                                  ),
                                );
                          },
                          calendarFormat: CalendarFormat.month,
                          headerStyle: const HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Events on ${state.selectedDay.toDateLabel}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: selectedItems.isEmpty
                            ? const Center(
                                key: ValueKey<String>('empty'),
                                child: Text('No events for this date.'),
                              )
                            : ListView.separated(
                                key: ValueKey<String>(
                                  'events_${state.selectedDay.toIso8601String()}',
                                ),
                                itemCount: selectedItems.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (BuildContext context, int index) {
                                  final item = selectedItems[index];
                                  return Card(
                                    child: ListTile(
                                      onTap: item.reminderEvent == null
                                          ? null
                                          : () => onEventTap(item.reminderEvent!),
                                      leading: Icon(
                                        item.source == _CalendarEventSource.google
                                            ? Icons.event_available_outlined
                                            : Icons.event_note_outlined,
                                      ),
                                      title: Text(item.title),
                                      subtitle: Text(_subtitle(item)),
                                      trailing: item.reminderEvent == null
                                          ? null
                                          : const Icon(Icons.chevron_right),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<ReminderEvent> _eventsForDay(
    DateTime day,
    List<ReminderEvent> allEvents,
  ) {
    return allEvents
        .where((ReminderEvent event) => event.dateTime.dateOnly == day.dateOnly)
        .toList();
  }

  List<GoogleCalendarEvent> _googleEventsForDay(
    DateTime day,
    List<GoogleCalendarEvent> allEvents,
  ) {
    return allEvents
        .where((GoogleCalendarEvent event) => event.start.dateOnly == day.dateOnly)
        .toList();
  }

  List<_CalendarEventItem> _selectedItemsForDay({
    required DateTime selectedDay,
    required List<ReminderEvent> reminderEvents,
    required List<GoogleCalendarEvent> googleEvents,
  }) {
    final items = <_CalendarEventItem>[
      ..._eventsForDay(selectedDay, reminderEvents).map(
        (ReminderEvent event) => _CalendarEventItem.reminder(event),
      ),
      ..._googleEventsForDay(selectedDay, googleEvents).map(
        (GoogleCalendarEvent event) => _CalendarEventItem.google(event),
      ),
    ];

    items.sort(
      (_CalendarEventItem a, _CalendarEventItem b) {
        if (a.isAllDay != b.isAllDay) {
          return a.isAllDay ? -1 : 1;
        }
        return a.start.compareTo(b.start);
      },
    );

    return items;
  }

  String _subtitle(_CalendarEventItem item) {
    final parts = <String>[
      item.isAllDay ? 'All day' : item.timeLabel,
      item.sourceLabel,
    ];

    if (item.location?.trim().isNotEmpty == true) {
      parts.add(item.location!.trim());
    }

    return parts.join(' - ');
  }
}

enum _CalendarEventSource { reminder, google }

class _CalendarEventItem {
  const _CalendarEventItem._({
    required this.title,
    required this.start,
    required this.end,
    required this.location,
    required this.isAllDay,
    required this.source,
    this.reminderEvent,
  });

  factory _CalendarEventItem.reminder(ReminderEvent event) {
    return _CalendarEventItem._(
      title: event.title,
      start: event.dateTime,
      end: null,
      location: event.location,
      isAllDay: false,
      source: _CalendarEventSource.reminder,
      reminderEvent: event,
    );
  }

  factory _CalendarEventItem.google(GoogleCalendarEvent event) {
    return _CalendarEventItem._(
      title: event.title,
      start: event.start,
      end: event.end,
      location: event.location,
      isAllDay: event.isAllDay,
      source: _CalendarEventSource.google,
    );
  }

  final String title;
  final DateTime start;
  final DateTime? end;
  final String? location;
  final bool isAllDay;
  final _CalendarEventSource source;
  final ReminderEvent? reminderEvent;

  String get timeLabel {
    if (isAllDay) {
      return 'All day';
    }

    if (end == null) {
      return start.toTimeLabel;
    }

    return '${start.toTimeLabel} - ${end!.toTimeLabel}';
  }

  String get sourceLabel =>
      source == _CalendarEventSource.google ? 'Google Calendar' : 'Reminder';
}
