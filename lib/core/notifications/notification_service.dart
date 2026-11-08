import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const morningId = 1001;
  static const eveningId = 1002;

  /// IDs [dhikrIdBase, dhikrIdBase + 1000) belong to the periodic reminders.
  static const dhikrIdBase = 2000;
  static const _dhikrWindowHours = 48;
  static const _dhikrMessages = <String>[
    'صلِّ على النبي صلى الله عليه وسلم',
    'اذكر الله',
  ];

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

    const android = AndroidInitializationSettings('ic_notification');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    try {
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
    } catch (e) {
      debugPrint('notification init failed: $e');
      return;
    }

    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('notification permission request failed: $e');
    }

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

  /// Periodic "صلِّ على النبي / اذكر الله" reminders.
  ///
  /// Android has no built-in 15-minute repeat, so the next [_dhikrWindowHours]
  /// hours of reminders are scheduled up front and the window is refreshed every
  /// time the app starts or the settings change. Delivery uses inexact alarms,
  /// so Android may shift a reminder by a few minutes while the phone is idle.
  Future<void> scheduleDhikrReminders({
    required bool enabled,
    int intervalMinutes = 15,
    bool quietHours = true,
  }) async {
    await init();
    await cancelDhikrReminders();
    if (!enabled) return;

    final interval = const [15, 30, 60].contains(intervalMinutes)
        ? intervalMinutes
        : 15;
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      now.hour,
      (now.minute ~/ interval) * interval,
    ).add(Duration(minutes: interval));
    final end = now.add(const Duration(hours: _dhikrWindowHours));

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'dhikr_reminder_channel',
        'تذكير بالذكر',
        channelDescription: 'تذكير دوري: صلِّ على النبي، اذكر الله',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        enableVibration: false,
        timeoutAfter: 600000, // clears itself after 10 minutes
      ),
      iOS: DarwinNotificationDetails(),
    );

    var id = dhikrIdBase;
    try {
      while (t.isBefore(end) && id < dhikrIdBase + 400) {
        // Quiet hours: no reminders from 23:00 until 04:00.
        final quiet = quietHours && (t.hour >= 23 || t.hour < 4);
        if (!quiet) {
          final slot = t.millisecondsSinceEpoch ~/ (interval * 60000);
          await _plugin.zonedSchedule(
            id,
            'القرآن والأذكار',
            _dhikrMessages[slot % _dhikrMessages.length],
            t,
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          id++;
        }
        t = t.add(Duration(minutes: interval));
      }
    } catch (e) {
      debugPrint('scheduleDhikrReminders failed: $e');
    }
  }

  Future<void> cancelDhikrReminders() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      for (final p in pending) {
        if (p.id >= dhikrIdBase && p.id < dhikrIdBase + 1000) {
          await _plugin.cancel(p.id);
        }
      }
    } catch (e) {
      debugPrint('cancelDhikrReminders failed: $e');
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
      'القرآن والأذكار',
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
