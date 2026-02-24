import 'package:flutter/material.dart';

import '../../../../core/services/service_registry.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.onOpenGoogleCalendar,
  });

  final VoidCallback? onOpenGoogleCalendar;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _reminderOffsetMinutes;
  late bool _voiceInputEnabled;

  @override
  void initState() {
    super.initState();
    _reminderOffsetMinutes = ServiceRegistry.notificationService.reminderOffsetMinutes;
    _voiceInputEnabled = ServiceRegistry.voiceInputService.isEnabled;
  }

  Future<void> _changeReminderOffset() async {
    final options = <int>[0, 5, 10, 15, 30, 60];
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                title: Text('Reminder Offset'),
                subtitle: Text('Schedule alert before event start time'),
              ),
              ...options.map(
                (int minutes) => RadioListTile<int>(
                  value: minutes,
                  groupValue: _reminderOffsetMinutes,
                  title: Text(
                    minutes == 0 ? 'At event time' : '$minutes minutes before',
                  ),
                  onChanged: (int? value) {
                    Navigator.of(context).pop(value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null) {
      return;
    }

    ServiceRegistry.notificationService.setReminderOffsetMinutes(selected);
    setState(() {
      _reminderOffsetMinutes = selected;
    });
  }

  Future<void> _setVoiceInputEnabled(bool enabled) async {
    await ServiceRegistry.voiceInputService.setEnabled(enabled);
    if (!mounted) {
      return;
    }

    setState(() {
      _voiceInputEnabled = enabled;
    });
  }

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
              children: <Widget>[
                _SettingTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Reminder Offset',
                  subtitle: _reminderOffsetMinutes == 0
                      ? 'At event time (current)'
                      : '$_reminderOffsetMinutes minutes before event (current)',
                  onTap: _changeReminderOffset,
                ),
                // const Divider(height: 1),
                // _SettingTile(
                //   icon: Icons.mic_none_outlined,
                //   title: 'Voice Input',
                //   subtitle: _voiceInputEnabled
                //       ? 'Speech-to-text enabled'
                //       : 'Speech-to-text disabled',
                //   onTap: () => _setVoiceInputEnabled(!_voiceInputEnabled),
                //   trailing: Switch(
                //     value: _voiceInputEnabled,
                //     onChanged: _setVoiceInputEnabled,
                //   ),
                // ),
                // const Divider(height: 1),
                // _SettingTile(
                //   icon: Icons.event_outlined,
                //   title: 'Google Calendar',
                //   subtitle: 'Open Google tab',
                //   onTap: widget.onOpenGoogleCalendar,
                // ),
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
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
    );
  }
}
