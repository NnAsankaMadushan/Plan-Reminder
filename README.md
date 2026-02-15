# Plan Reminder App

Offline mobile reminder application built with Flutter, BLoC, and Clean Architecture.  
The app parses natural language from typed/voice input, creates calendar events, and schedules local reminders 5 minutes before each event.

## Features

- Offline NLP parser (no cloud AI APIs)
- Voice-to-text input with `speech_to_text`
- Chat-style reminder creation flow
- Calendar month view with event markers
- Manual add/edit/delete event flow
- Local notifications with timezone scheduling
- Persistent local storage with Hive

## Tech Stack

- `flutter_bloc`
- `equatable`
- `intl`
- `uuid`
- `table_calendar`
- `flutter_local_notifications`
- `timezone` + `flutter_timezone`
- `speech_to_text`
- `hive` + `hive_flutter`
- `flutter_animate`

## Project Structure

```text
lib/
 ├── core/
 │    ├── constants/
 │    ├── services/
 │    ├── theme/
 │    └── utils/
 ├── features/
 │    ├── app/
 │    ├── calendar/
 │    ├── chat/
 │    ├── parser/
 │    └── reminder/
 ├── app.dart
 └── main.dart
```

## NLP Parser Rules

`LocalEventParserService` supports:

- Date keywords: `today`, `tomorrow`, `day after tomorrow`
- Relative weekdays: `next monday`, `friday`, `saturday`
- Specific dates: `10th June`, `June 10`, `10/06/2026`
- Time patterns: `10 am`, `10:30 am`, `5 pm`, `17:30`, `noon`, `midnight`, `tonight`
- Title extraction by removing detected date/time/location tokens
- Missing date defaults to current date
- Missing time flagged for user confirmation in UI

## Run Locally

1. Install Flutter (latest stable) and verify with `flutter --version`.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run app:
   ```bash
   flutter run
   ```

## Permissions

### Android

- `RECORD_AUDIO`
- `POST_NOTIFICATIONS`
- `SCHEDULE_EXACT_ALARM`
- `RECEIVE_BOOT_COMPLETED`

### iOS

- `NSMicrophoneUsageDescription`
- `NSSpeechRecognitionUsageDescription`

## Test

Run parser tests:

```bash
flutter test
```
