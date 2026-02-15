import 'package:flutter/material.dart';

import '../../../../core/utils/date_time_extensions.dart';
import '../../../parser/domain/entities/parsed_event.dart';

class ParsePreviewCard extends StatelessWidget {
  const ParsePreviewCard({
    super.key,
    required this.parsedEvent,
    required this.onConfirm,
    required this.onEdit,
    required this.onDismiss,
  });

  final ParsedEvent parsedEvent;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warningColor = theme.colorScheme.secondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Parsed Reminder', style: theme.textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDismiss,
                  tooltip: 'Dismiss',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Title: ${parsedEvent.title}'),
            const SizedBox(height: 4),
            Text('Date: ${parsedEvent.dateTime.toDateLabel}'),
            const SizedBox(height: 4),
            Text('Time: ${parsedEvent.dateTime.toTimeLabel}'),
            const SizedBox(height: 4),
            Text('Location: ${parsedEvent.location ?? 'Not set'}'),
            if (!parsedEvent.hasExplicitTime)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Time was not explicit. Please confirm or edit before save.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: warningColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
