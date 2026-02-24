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
- Optional Google Calendar upcoming-events view (connect only if user wants)

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
- `google_sign_in`
- `googleapis` (Calendar API)


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

## Optional: Google Calendar Connect Setup

Google Calendar integration is optional and only used when the user taps **Connect Google Calendar**.

1. Enable **Google Calendar API** in your Google Cloud project.
2. Create OAuth client credentials:
   - Android client (package name + SHA-1)
   - iOS client (bundle identifier)
3. Ensure your app package/bundle IDs match the OAuth setup.
4. Build and run, then open the **Google** tab and connect.

If OAuth is not configured, the core reminder app still works fully offline.

## Test

Run parser tests:

```bash
flutter test
```
