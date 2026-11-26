import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../astro/interpret.dart';
import '../data/sample.dart';

/// Cihazda planlanan bildirimler: önümüzdeki 7 gün için her sabah 09:00
/// kişisel günlük skor + gökyüzü olaylarından bir gün önce 19:00 uyarısı.
class Notifications {
  static final _p = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      await _p.initialize(
          settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ));
      _ready = true;
    } catch (e) {
      debugPrint('NOTIFICATIONS INIT ERROR: $e');
    }
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails('daily', 'Günlük harita',
        channelDescription: 'Günlük skor ve gökyüzü uyarıları',
        importance: Importance.defaultImportance),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> reschedule() async {
    if (!_ready) return;
    try {
      await _p.cancelAll();
      if (!app.notificationsOn) return;
      await _p
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _p
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      final now = tz.TZDateTime.now(tz.local);
      for (var k = 0; k < 7; k++) {
        final day = DateTime.now().add(Duration(days: k));
        final at = tz.TZDateTime(tz.local, day.year, day.month, day.day, 9);
        if (at.isBefore(now)) continue;
        final d = daily(app.chart, day);
        await _p.zonedSchedule(
          id: 100 + k,
          scheduledDate: at,
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: 'Bugünün kodu: %${d.scores[0]} ${scoreLabel(d.scores[0])}',
          body: d.todo,
        );
      }
      for (final (i, e) in skyEvents(app.chart, DateTime.now()).indexed) {
        final before = e.date.subtract(const Duration(days: 1));
        final at = tz.TZDateTime(tz.local, before.year, before.month, before.day, 19);
        if (at.isBefore(now)) continue;
        await _p.zonedSchedule(
          id: 200 + i,
          scheduledDate: at,
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: 'Yarın: ${e.title}',
          body: e.body,
        );
      }
    } catch (e) {
      debugPrint('NOTIFICATIONS SCHEDULE ERROR: $e');
    }
  }
}
