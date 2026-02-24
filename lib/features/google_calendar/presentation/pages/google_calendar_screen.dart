import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/date_time_extensions.dart';
import '../../domain/entities/google_calendar_event.dart';
import '../bloc/google_calendar_bloc.dart';

class GoogleCalendarScreen extends StatefulWidget {
  const GoogleCalendarScreen({super.key});

  @override
  State<GoogleCalendarScreen> createState() => _GoogleCalendarScreenState();
}

class _GoogleCalendarScreenState extends State<GoogleCalendarScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GoogleCalendarBloc>().add(const GoogleCalendarStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GoogleCalendarBloc, GoogleCalendarState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (BuildContext context, GoogleCalendarState state) {
        final groupedEvents = _groupEventsByDate(state.events);
        final sortedDates = groupedEvents.keys.toList()
          ..sort((DateTime a, DateTime b) => a.compareTo(b));

        if (state.status == GoogleCalendarStatus.loading &&
            state.events.isEmpty &&
            !state.isConnected) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!state.isConnected) {
          return _DisconnectedView(
            onConnect: () {
              context
                  .read<GoogleCalendarBloc>()
                  .add(const GoogleCalendarConnectRequested());
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context
                .read<GoogleCalendarBloc>()
                .add(const GoogleCalendarRefreshRequested());
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            children: <Widget>[
              _ConnectedHeader(
                email: state.email ?? 'Connected',
                isLoading: state.status == GoogleCalendarStatus.loading,
                onRefresh: () {
                  context
                      .read<GoogleCalendarBloc>()
                      .add(const GoogleCalendarRefreshRequested());
                },
                onDisconnect: () {
                  context
                      .read<GoogleCalendarBloc>()
                      .add(const GoogleCalendarDisconnectRequested());
                },
              ),
              const SizedBox(height: 10),
              Text(
                'Upcoming Events',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (state.events.isEmpty)
                const _EmptyEventsCard()
              else
                ...<Widget>[
                  for (final date in sortedDates) ...<Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 8, 2, 6),
                      child: Text(
                        date.toDateLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    ...groupedEvents[date]!.map(
                      (GoogleCalendarEvent event) => _GoogleCalendarEventCard(
                        event: event,
                      ),
                    ),
                  ],
                ],
            ],
          ),
        );
      },
    );
  }

  Map<DateTime, List<GoogleCalendarEvent>> _groupEventsByDate(
    List<GoogleCalendarEvent> events,
  ) {
    final grouped = <DateTime, List<GoogleCalendarEvent>>{};

    for (final event in events) {
      final date = event.start.dateOnly;
      grouped.putIfAbsent(date, () => <GoogleCalendarEvent>[]).add(event);
    }

    for (final dateEvents in grouped.values) {
      dateEvents.sort(
        (GoogleCalendarEvent a, GoogleCalendarEvent b) =>
            a.start.compareTo(b.start),
      );
    }

    return grouped;
  }
}

class _GoogleCalendarEventCard extends StatelessWidget {
  const _GoogleCalendarEventCard({required this.event});

  final GoogleCalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          event.isAllDay
              ? Icons.calendar_today_outlined
              : Icons.event_available_outlined,
        ),
        title: Text(event.title),
        subtitle: Text(_timeLabel(event)),
        trailing: event.location?.trim().isNotEmpty == true
            ? SizedBox(
                width: 120,
                child: Text(
                  event.location!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              )
            : null,
      ),
    );
  }

  String _timeLabel(GoogleCalendarEvent event) {
    if (event.isAllDay) {
      return 'All day';
    }

    if (event.end == null) {
      return event.start.toTimeLabel;
    }

    return '${event.start.toTimeLabel} - ${event.end!.toTimeLabel}';
  }
}

class _DisconnectedView extends StatelessWidget {
  const _DisconnectedView({required this.onConnect});

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Google Calendar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect only if you want to see your Google Calendar upcoming events in this app.',
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your local reminder parser remains fully offline.',
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: onConnect,
                    icon: const Icon(Icons.link),
                    label: const Text('Connect Google Calendar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectedHeader extends StatelessWidget {
  const _ConnectedHeader({
    required this.email,
    required this.isLoading,
    required this.onRefresh,
    required this.onDisconnect,
  });

  final String email;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Connected as', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(email, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: isLoading ? null : onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: isLoading ? null : onDisconnect,
                  icon: const Icon(Icons.link_off),
                  label: const Text('Disconnect'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyEventsCard extends StatelessWidget {
  const _EmptyEventsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text('No upcoming Google Calendar events found.'),
    );
  }
}
