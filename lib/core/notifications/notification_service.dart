import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const morningId = 1001;
  static const eveningId = 1002;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@android:drawable/ic_dialog_info');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> scheduleDailyAdhkar({
    required bool morningEnabled,
    required bool eveningEnabled,
    int morningHour = 6,
    int morningMinute = 30,
    int eveningHour = 17,
    int eveningMinute = 30,
  }) async {
    await init();
    await cancelAdhkar();

    if (morningEnabled) {
      await _scheduleDaily(
        id: morningId,
        title: 'أذكار الصباح',
        body: 'حان وقت أذكار الصباح. اذكر الله في بداية يومك.',
        hour: morningHour,
        minute: morningMinute,
      );
    }
    if (eveningEnabled) {
      await _scheduleDaily(
        id: eveningId,
        title: 'أذكار المساء',
        body: 'حان وقت أذكار المساء. اذكر الله قبل نهاية يومك.',
        hour: eveningHour,
        minute: eveningMinute,
      );
    }
  }

  Future<void> cancelAdhkar() async {
    await _plugin.cancel(morningId);
    await _plugin.cancel(eveningId);
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'adhkar_channel',
            'أذكار',
            channelDescription: 'تذكير بأذكار الصباح والمساء',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('scheduleDaily failed: $e');
    }
  }

  Future<void> showTestNotification() async {
    await init();
    await _plugin.show(
      9999,
      'Quran & Adhkar',
      'الإشعارات تعمل بشكل صحيح',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'adhkar_channel',
          'أذكار',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
