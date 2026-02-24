import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/date_time_extensions.dart';
import '../../../parser/domain/entities/parsed_event.dart';
import '../../domain/entities/reminder_event.dart';

class AddEditEventScreen extends StatefulWidget {
  const AddEditEventScreen({
    super.key,
    this.initialEvent,
    this.parsedEvent,
  });

  final ReminderEvent? initialEvent;
  final ParsedEvent? parsedEvent;

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final Uuid _uuid = const Uuid();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  bool get _isEditMode => widget.initialEvent != null;

  @override
  void initState() {
    super.initState();

    final baseDateTime = widget.initialEvent?.dateTime ??
        widget.parsedEvent?.dateTime ??
        DateTime.now().add(const Duration(hours: 1));

    _selectedDate = baseDateTime.dateOnly;
    _selectedTime = TimeOfDay.fromDateTime(baseDateTime);

    _titleController.text =
        widget.initialEvent?.title ?? widget.parsedEvent?.title ?? '';
    _locationController.text =
        widget.initialEvent?.location ?? widget.parsedEvent?.location ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate.dateOnly;
    });
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _selectedTime = pickedTime;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final location = _locationController.text.trim();
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final event = ReminderEvent(
      id: widget.initialEvent?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      dateTime: dateTime,
      location: location.isEmpty ? null : location,
      createdAt: widget.initialEvent?.createdAt ?? DateTime.now(),
      sourceText: widget.initialEvent?.sourceText ?? widget.parsedEvent?.sourceText,
    );

    Navigator.of(context).pop(event);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Event' : 'Add Event'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _DateTimeHeader(
                  dateLabel: _selectedDate.toDateLabel,
                  timeLabel: _selectedTime.format(context),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Details', style: textTheme.titleMedium),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            hintText: 'Meeting with Sarah',
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title is required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location (optional)',
                            hintText: 'Office, Zoom, Cafe',
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _SelectionTile(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: _selectedDate.toDateLabel,
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SelectionTile(
                        icon: Icons.access_time_outlined,
                        label: 'Time',
                        value: _selectedTime.format(context),
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                if (widget.parsedEvent != null && !widget.parsedEvent!.hasExplicitTime)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Time was not detected from message. Please confirm before saving.',
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(_isEditMode ? 'Save Changes' : 'Create Event'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTimeHeader extends StatelessWidget {
  const _DateTimeHeader({
    required this.dateLabel,
    required this.timeLabel,
  });

  final String dateLabel;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
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
          Text('Schedule', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '$dateLabel at $timeLabel',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: theme.colorScheme.surface.withValues(alpha: 0.94),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: theme.textTheme.labelLarge),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
