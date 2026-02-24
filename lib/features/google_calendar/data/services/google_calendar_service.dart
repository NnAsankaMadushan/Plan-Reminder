import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar_api;
import 'package:flutter/services.dart';

import '../../domain/entities/google_calendar_event.dart';

class GoogleCalendarService {
  GoogleCalendarService()
      : _googleSignIn = GoogleSignIn(
          scopes: <String>[
            calendar_api.CalendarApi.calendarReadonlyScope,
            calendar_api.CalendarApi.calendarEventsReadonlyScope,
          ],
        );

  final GoogleSignIn _googleSignIn;

  Future<bool> isSignedIn() {
    return _googleSignIn.isSignedIn();
  }

  Future<String?> currentUserEmail() async {
    final account = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    return account?.email;
  }

  Future<String> connect() async {
    try {
      final account = _googleSignIn.currentUser ??
          await _googleSignIn.signInSilently() ??
          await _googleSignIn.signIn();

      if (account == null) {
        throw const GoogleCalendarException('Google sign-in was canceled.');
      }

      return account.email;
    } on PlatformException catch (error) {
      throw GoogleCalendarException(_friendlyGoogleSignInError(error));
    }
  }

  Future<void> disconnect() async {
    await _googleSignIn.signOut();
  }

  Future<List<GoogleCalendarEvent>> getUpcomingEvents({
    int maxResults = 20,
  }) async {
    final signedIn = await isSignedIn();
    if (!signedIn) {
      throw const GoogleCalendarException('Please connect Google Calendar first.');
    }

    final authClient = await _googleSignIn.authenticatedClient();
    if (authClient == null) {
      throw const GoogleCalendarException('Failed to authenticate with Google.');
    }

    final api = calendar_api.CalendarApi(authClient);
    final response = await api.events.list(
      'primary',
      singleEvents: true,
      orderBy: 'startTime',
      timeMin: DateTime.now().toUtc(),
      maxResults: maxResults,
    );

    final items = response.items ?? const <calendar_api.Event>[];

    final events = <GoogleCalendarEvent>[];
    for (final item in items) {
      final startDateTime = item.start?.dateTime ?? item.start?.date;
      if (startDateTime == null) {
        continue;
      }

      final endDateTime = item.end?.dateTime ?? item.end?.date;
      events.add(
        GoogleCalendarEvent(
          id: item.id ?? startDateTime.toIso8601String(),
          title: item.summary?.trim().isNotEmpty == true
              ? item.summary!.trim()
              : '(No title)',
          start: startDateTime.toLocal(),
          end: endDateTime?.toLocal(),
          location: item.location,
          description: item.description,
          isAllDay: item.start?.date != null && item.start?.dateTime == null,
        ),
      );
    }

    return events;
  }

  String _friendlyGoogleSignInError(PlatformException error) {
    if (error.code == 'sign_in_failed') {
      return 'Google sign-in failed. Verify Android package name, SHA-1, and '
          'OAuth client configuration in Google Cloud/Firebase.';
    }
    return 'Google sign-in failed: ${error.message ?? error.code}';
  }
}

class GoogleCalendarException implements Exception {
  const GoogleCalendarException(this.message);

  final String message;

  @override
  String toString() => message;
}
