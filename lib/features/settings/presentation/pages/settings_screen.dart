import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('General', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'Configure app behavior and integrations from one place.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: const <Widget>[
                _SettingTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Reminder Offset',
                  subtitle: '5 minutes before event (current)',
                ),
                Divider(height: 1),
                _SettingTile(
                  icon: Icons.mic_none_outlined,
                  title: 'Voice Input',
                  subtitle: 'Speech-to-text enabled',
                ),
                Divider(height: 1),
                _SettingTile(
                  icon: Icons.event_outlined,
                  title: 'Google Calendar',
                  subtitle: 'Manage connection in Google tab',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    'About',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text('Plan Reminder App'),
                  SizedBox(height: 4),
                  Text('Offline NLP + Local Notifications'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
