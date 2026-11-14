import 'package:adhan/adhan.dart' as adhan;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../features/prayer_times/data/adhan_voices.dart';

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

  /// IDs [adhanIdBase, adhanIdBase + 1000) belong to the adhan notifications.
  static const adhanIdBase = 3000;
  String? _adhanSignature;
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
      // Couldn't read the zone name: pick a zone with the device's UTC offset
      // so prayer times aren't scheduled in UTC.
      tz.setLocalLocation(_locationFromOffset());
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


  tz.Location _locationFromOffset() {
    final offset = DateTime.now().timeZoneOffset;
    for (final loc in tz.timeZoneDatabase.locations.values) {
      if (tz.TZDateTime.now(loc).timeZoneOffset == offset) return loc;
    }
    return tz.UTC;
  }

  /// With voice on, each reminder plays a recorded voice saying the dhikr
  /// (message 0 = صلِّ على النبي, message 1 = اذكر الله). A channel's sound is
  /// fixed once created, so each voice has its own channel.
  NotificationDetails _reminderDetails(
    int message,
    bool voice,
    NotificationDetails silent,
  ) {
    if (!voice) return silent;
    final salawat = message == 0;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        salawat ? 'salawat_voice_channel' : 'tasbeeh_voice_channel',
        salawat ? 'تذكير بالصوت: الصلاة على النبي' : 'تذكير بالصوت: اذكر الله',
        channelDescription: 'تذكير دوري بصوت الذكر',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(
          salawat ? 'salawat_voice' : 'tasbeeh_voice',
        ),
        enableVibration: false,
        timeoutAfter: 600000,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  NotificationDetails _adhanDetails(AdhanVoice voice) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'adhan_${voice.id}',
        'الأذان - ${voice.nameAr}',
        channelDescription: 'أذان عند دخول وقت الصلاة',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(voice.rawName),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  // ---------------------------------------------------------------------
  // Diagnostics & tests (so the user can verify on the device in seconds)
  // ---------------------------------------------------------------------

  static const _testAdhanId = 990;
  static const _testReminderId = 991;

  /// Fires an adhan notification right now (plays the chosen voice).
  Future<bool> showTestAdhan(AdhanVoice voice) async {
    try {
      await init();
      await _plugin.show(
        _testAdhanId,
        'تجربة الأذان',
        'صوت الأذان: ${voice.nameAr}',
        _adhanDetails(voice),
      );
      return true;
    } catch (e) {
      debugPrint('showTestAdhan failed: $e');
      return false;
    }
  }

  /// Fires a reminder notification right now with its voice.
  Future<bool> showTestReminder({required bool salawat}) async {
    try {
      await init();
      await _plugin.show(
        _testReminderId,
        'القرآن والأذكار',
        _dhikrMessages[salawat ? 0 : 1],
        _reminderDetails(salawat ? 0 : 1, true, const NotificationDetails()),
      );
      return true;
    } catch (e) {
      debugPrint('showTestReminder failed: $e');
      return false;
    }
  }

  Future<NotificationStatus> status() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    var allowed = true;
    bool? exact;
    try {
      allowed = await android?.areNotificationsEnabled() ?? true;
    } catch (_) {}
    try {
      exact = await android?.canScheduleExactNotifications();
    } catch (_) {}
    var adhanCount = 0;
    var reminderCount = 0;
    var dailyCount = 0;
    try {
      for (final p in await _plugin.pendingNotificationRequests()) {
        if (p.id >= adhanIdBase && p.id < adhanIdBase + 1000) {
          adhanCount++;
        } else if (p.id >= dhikrIdBase && p.id < dhikrIdBase + 1000) {
          reminderCount++;
        } else if (p.id == morningId || p.id == eveningId) {
          dailyCount++;
        }
      }
    } catch (_) {}
    return NotificationStatus(
      notificationsAllowed: allowed,
      exactAlarmsAllowed: exact,
      adhanScheduled: adhanCount,
      reminderScheduled: reminderCount,
      dailyAdhkarScheduled: dailyCount,
    );
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
    bool voice = true,
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

    const silentDetails = NotificationDetails(
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

    NotificationDetails detailsFor(int message) =>
        _reminderDetails(message, voice, silentDetails);

    var id = dhikrIdBase;
    try {
      while (t.isBefore(end) && id < dhikrIdBase + 400) {
        // Quiet hours: no reminders from 23:00 until 04:00.
        final quiet = quietHours && (t.hour >= 23 || t.hour < 4);
        if (!quiet) {
          final slot = t.millisecondsSinceEpoch ~/ (interval * 60000);
          final message = slot % _dhikrMessages.length;
          await _plugin.zonedSchedule(
            id,
            'القرآن والأذكار',
            _dhikrMessages[message],
            t,
            detailsFor(message),
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

  /// Lets the app ask Android 12+ for permission to fire alarms exactly on
  /// time (adhan must not be late). Opens the system "Alarms & reminders" page.
  Future<void> requestExactAlarmPermission() async {
    try {
      await init();
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('exact alarm permission request failed: $e');
    }
  }

  /// Schedules the adhan for the next 3 days. Each voice has its own channel
  /// (a channel's sound can't change once created) and plays through the alarm
  /// stream so the full adhan is heard. Safe to call repeatedly.
  Future<void> scheduleAdhans({
    required bool enabled,
    required adhan.Coordinates coordinates,
    required adhan.CalculationMethod method,
    required adhan.Madhab madhab,
    required String city,
    required AdhanVoice voice,
    required AdhanVoice fajrVoice,
  }) async {
    final now = DateTime.now();
    final signature = '$enabled|${coordinates.latitude}|${coordinates.longitude}'
        '|${method.name}|${madhab.name}|${voice.id}|${fajrVoice.id}|$city'
        '|${now.year}-${now.month}-${now.day}';
    if (signature == _adhanSignature) return;
    _adhanSignature = signature;
    try {
      await init();
      await cancelAdhans();
      if (!enabled) return;

      final params = method.getParameters();
      params.madhab = madhab;
      var id = adhanIdBase;
      for (var d = 0; d < 3; d++) {
        final day = now.add(Duration(days: d));
        final pt = adhan.PrayerTimes(
          coordinates,
          adhan.DateComponents.from(day),
          params,
        );
        final prayers = <(String, DateTime, bool)>[
          ('الفجر', pt.fajr, true),
          ('الظهر', pt.dhuhr, false),
          ('العصر', pt.asr, false),
          ('المغرب', pt.maghrib, false),
          ('العشاء', pt.isha, false),
        ];
        for (final p in prayers) {
          final when = p.$2.toLocal();
          if (!when.isAfter(now)) continue;
          await _scheduleAdhan(id++, p.$1, when, p.$3 ? fajrVoice : voice, city);
        }
      }
    } catch (e) {
      debugPrint('scheduleAdhans failed: $e');
      _adhanSignature = null;
    }
  }

  Future<void> _scheduleAdhan(
    int id,
    String prayerName,
    DateTime when,
    AdhanVoice voice,
    String city,
  ) async {
    final details = _adhanDetails(voice);
    final at = tz.TZDateTime.from(when, tz.local);

    Future<void> schedule(AndroidScheduleMode mode) {
      return _plugin.zonedSchedule(
        id,
        'حان الآن موعد صلاة $prayerName',
        'حيّ على الصلاة • $city',
        at,
        details,
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    try {
      await schedule(AndroidScheduleMode.exactAllowWhileIdle);
    } catch (_) {
      // Exact alarms not permitted: fall back to inexact (may be a bit late).
      await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  Future<void> cancelAdhans() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      for (final p in pending) {
        if (p.id >= adhanIdBase && p.id < adhanIdBase + 1000) {
          await _plugin.cancel(p.id);
        }
      }
    } catch (e) {
      debugPrint('cancelAdhans failed: $e');
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


class NotificationStatus {
  final bool notificationsAllowed;

  /// null when it can't be determined (e.g. not Android).
  final bool? exactAlarmsAllowed;
  final int adhanScheduled;
  final int reminderScheduled;
  final int dailyAdhkarScheduled;

  const NotificationStatus({
    required this.notificationsAllowed,
    required this.exactAlarmsAllowed,
    required this.adhanScheduled,
    required this.reminderScheduled,
    required this.dailyAdhkarScheduled,
  });
}
