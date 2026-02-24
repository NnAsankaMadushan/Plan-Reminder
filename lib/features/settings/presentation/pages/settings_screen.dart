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
      showDragHandle: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Reminder Offset', style: theme.textTheme.titleMedium),
                subtitle: const Text('Schedule alert before event start time'),
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
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        children: <Widget>[
          _HeaderCard(
            reminderOffsetMinutes: _reminderOffsetMinutes,
            voiceInputEnabled: _voiceInputEnabled,
          ),
          const SizedBox(height: 12),
          Text('General', style: theme.textTheme.titleMedium),
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
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.mic_none_outlined,
                  title: 'Voice Input',
                  subtitle: _voiceInputEnabled
                      ? 'Speech-to-text enabled'
                      : 'Speech-to-text disabled',
                  onTap: () => _setVoiceInputEnabled(!_voiceInputEnabled),
                  trailing: Switch(
                    value: _voiceInputEnabled,
                    onChanged: _setVoiceInputEnabled,
                  ),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.event_outlined,
                  title: 'Google Calendar',
                  subtitle: 'Open the integration tab',
                  onTap: widget.onOpenGoogleCalendar,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('About', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Plan Reminder App', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Offline NLP + local notifications with optional Google Calendar sync.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
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
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
        child: Icon(icon, size: 18, color: theme.colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.reminderOffsetMinutes,
    required this.voiceInputEnabled,
  });

  final int reminderOffsetMinutes;
  final bool voiceInputEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: <Color>[
            theme.colorScheme.primary.withValues(alpha: 0.12),
            theme.colorScheme.tertiary.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('App Preferences', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Current reminder offset: '
            '${reminderOffsetMinutes == 0 ? 'At event time' : '$reminderOffsetMinutes minutes before'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: theme.colorScheme.surface.withValues(alpha: 0.85),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Text(
              voiceInputEnabled ? 'Voice input enabled' : 'Voice input disabled',
              style: theme.textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
