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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Event' : 'Add Event'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Details', style: textTheme.titleLarge),
                const SizedBox(height: 12),
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
                const SizedBox(height: 20),
                Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text('Date'),
                        subtitle: Text(_selectedDate.toDateLabel),
                        trailing: TextButton(
                          onPressed: _pickDate,
                          child: const Text('Change'),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.access_time_outlined),
                        title: const Text('Time'),
                        subtitle: Text(_selectedTime.format(context)),
                        trailing: TextButton(
                          onPressed: _pickTime,
                          child: const Text('Change'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.parsedEvent != null && !widget.parsedEvent!.hasExplicitTime)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Time was not detected from message. Please confirm before saving.',
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
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
