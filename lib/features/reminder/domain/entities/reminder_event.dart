import 'package:equatable/equatable.dart';

class ReminderEvent extends Equatable {
  const ReminderEvent({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.createdAt,
    this.location,
    this.sourceText,
  });

  final String id;
  final String title;
  final DateTime dateTime;
  final String? location;
  final DateTime createdAt;
  final String? sourceText;

  ReminderEvent copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    String? location,
    DateTime? createdAt,
    String? sourceText,
  }) {
    return ReminderEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      sourceText: sourceText ?? this.sourceText,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        dateTime,
        location,
        createdAt,
        sourceText,
      ];
}
