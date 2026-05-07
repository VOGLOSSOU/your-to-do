import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _notifId = 42;
  static const _channelId = 'daily_tasks';
  static const _hourKey = 'notif_hour';
  static const _minKey = 'notif_min';
  static const _enabledKey = 'notif_enabled';

  Future<void> init() async {
    tz.initializeTimeZones();
    _setLocalTimezone();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
  }

  void _setLocalTimezone() {
    // On Android, DateTime.now().timeZoneName returns the IANA timezone ID
    final tzName = DateTime.now().timeZoneName;
    try {
      tz.setLocalLocation(tz.getLocation(tzName));
      return;
    } catch (_) {}

    // Fallback: read /etc/timezone (works on Android/Linux)
    try {
      final f = File('/etc/timezone');
      if (f.existsSync()) {
        final name = f.readAsStringSync().trim();
        tz.setLocalLocation(tz.getLocation(name));
        return;
      }
    } catch (_) {}

    // Last resort: match by UTC offset
    final offsetMs = DateTime.now().timeZoneOffset.inMilliseconds;
    for (final loc in tz.timeZoneDatabase.locations.values) {
      if (loc.currentTimeZone.offset == offsetMs) {
        tz.setLocalLocation(loc);
        return;
      }
    }
  }

  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, hour);
    await prefs.setInt(_minKey, minute);
    await prefs.setBool(_enabledKey, true);

    await _plugin.cancel(_notifId);
    await _plugin.zonedSchedule(
      _notifId,
      'My Tasks',
      'Time to check your tasks for today',
      _nextInstanceOf(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Daily reminder',
          channelDescription: 'Daily task reminder',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
    await _plugin.cancel(_notifId);
  }

  Future<({bool enabled, int hour, int minute})> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      enabled: prefs.getBool(_enabledKey) ?? false,
      hour: prefs.getInt(_hourKey) ?? 8,
      minute: prefs.getInt(_minKey) ?? 0,
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
