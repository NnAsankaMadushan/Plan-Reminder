import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../calendar/presentation/bloc/calendar_bloc.dart';
import '../../../calendar/presentation/pages/calendar_screen.dart';
import '../../../chat/presentation/pages/home_screen.dart';
import '../../../google_calendar/presentation/pages/google_calendar_screen.dart';
import '../../../reminder/domain/entities/reminder_event.dart';
import '../../../reminder/presentation/bloc/reminder_bloc.dart';
import '../../../reminder/presentation/pages/add_edit_event_screen.dart';
import '../../../reminder/presentation/pages/event_detail_screen.dart';
import '../../../reminder/presentation/pages/notification_screen.dart';
import '../../../settings/presentation/pages/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  Future<void> _addManualEvent() async {
    final reminderEvent = await Navigator.of(context).push<ReminderEvent>(
      MaterialPageRoute<ReminderEvent>(
        builder: (_) => const AddEditEventScreen(),
      ),
    );

    if (reminderEvent == null || !mounted) {
      return;
    }

    context.read<CalendarBloc>().add(CalendarEventSaved(reminderEvent));
    context.read<ReminderBloc>().add(ReminderScheduleRequested(reminderEvent));
  }

  void _openEventDetails(ReminderEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailScreen(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = switch (_selectedIndex) {
      0 => const HomeScreen(key: ValueKey<String>('home_page')),
      1 => CalendarScreen(
          key: const ValueKey<String>('calendar_page'),
          onEventTap: _openEventDetails,
        ),
      2 => NotificationScreen(
          key: const ValueKey<String>('notifications_page'),
          onEventTap: _openEventDetails,
        ),
      3 => const GoogleCalendarScreen(
          key: ValueKey<String>('google_calendar_page'),
        ),
      _ => const SettingsScreen(
          key: ValueKey<String>('settings_page'),
        ),
    };

    final title = switch (_selectedIndex) {
      0 => 'Plan Reminder',
      1 => 'Calendar',
      2 => 'Notifications',
      3 => 'Google Calendar',
      _ => 'Settings',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: page,
      ),
      floatingActionButton: _selectedIndex == 1
          ? TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.9, end: 1),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutBack,
              builder: (_, double value, Widget? child) {
                return Transform.scale(scale: value, child: child);
              },
              child: FloatingActionButton.extended(
                onPressed: _addManualEvent,
                label: const Text('Add Event'),
                icon: const Icon(Icons.add),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Google',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
