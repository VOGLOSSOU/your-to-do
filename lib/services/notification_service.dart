import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _notifId = 42;
  static const _testNotifId = 99;
  static const _channelId = 'daily_tasks';
  static const _hourKey = 'notif_hour';
  static const _minKey = 'notif_min';
  static const _enabledKey = 'notif_enabled';

  static const _channel = AndroidNotificationDetails(
    _channelId,
    'Daily reminder',
    channelDescription: 'Daily task reminder',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  Future<void> init() async {
    tz.initializeTimeZones();
    // Always use UTC and convert local time manually — avoids any timezone detection issues
    tz.setLocalLocation(tz.UTC);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
  }

  Future<bool> requestPermission() async {
    final result = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return result ?? false;
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
      const NotificationDetails(android: _channel),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> sendTestNotification() async {
    await _plugin.show(
      _testNotifId,
      'My Tasks',
      'Notifications are working!',
      const NotificationDetails(android: _channel),
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

  // Converts local desired time to UTC for scheduling
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final nowLocal = DateTime.now();
    var targetLocal = DateTime(nowLocal.year, nowLocal.month, nowLocal.day, hour, minute);
    if (targetLocal.isBefore(nowLocal)) {
      targetLocal = targetLocal.add(const Duration(days: 1));
    }
    final targetUtc = targetLocal.toUtc();
    return tz.TZDateTime(tz.UTC, targetUtc.year, targetUtc.month, targetUtc.day,
        targetUtc.hour, targetUtc.minute);
  }
}
