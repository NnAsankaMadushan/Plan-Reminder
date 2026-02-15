import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/utils/date_time_extensions.dart';
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
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (BuildContext context, CalendarState state) {
        final selectedEvents = state.selectedDayEvents;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TableCalendar<ReminderEvent>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: state.focusedDay,
                      eventLoader: (DateTime day) =>
                          _eventsForDay(day, state.events),
                      selectedDayPredicate: (DateTime day) =>
                          day.dateOnly == state.selectedDay.dateOnly,
                      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
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
                    child: selectedEvents.isEmpty
                        ? const Center(
                            key: ValueKey<String>('empty'),
                            child: Text('No reminders for this date.'),
                          )
                        : ListView.separated(
                            key: ValueKey<String>(
                              'events_${state.selectedDay.toIso8601String()}',
                            ),
                            itemCount: selectedEvents.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (BuildContext context, int index) {
                              final event = selectedEvents[index];
                              return Card(
                                child: ListTile(
                                  onTap: () => onEventTap(event),
                                  leading:
                                      const Icon(Icons.event_note_outlined),
                                  title: Text(event.title),
                                  subtitle: Text(
                                    event.location == null
                                        ? event.dateTime.toTimeLabel
                                        : '${event.dateTime.toTimeLabel} • ${event.location}',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
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
  }

  List<ReminderEvent> _eventsForDay(
    DateTime day,
    List<ReminderEvent> allEvents,
  ) {
    return allEvents
        .where((ReminderEvent event) => event.dateTime.dateOnly == day.dateOnly)
        .toList();
  }
}
