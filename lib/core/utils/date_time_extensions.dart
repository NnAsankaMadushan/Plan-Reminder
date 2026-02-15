import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String get toDateLabel => DateFormat('EEE, MMM d, y').format(this);

  String get toTimeLabel => DateFormat('h:mm a').format(this);

  String get toDateTimeLabel => '$toDateLabel at $toTimeLabel';

  DateTime get dateOnly => DateTime(year, month, day);
}
