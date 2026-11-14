import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pushes data to the Android home-screen widgets.
///
/// Prayer times are calculated here (adhan) for the next 7 days and stored in
/// SharedPreferences; the native widget reads them (key
/// "flutter.widget_prayer_json"), so it keeps working without the app open.
class HomeWidgetSync {
  static const _channel = MethodChannel('quran_adhkar/widgets');
  static const prayerKey = 'widget_prayer_json';

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<void> pushPrayerTimes({
    required Coordinates coordinates,
    required CalculationMethod method,
    required Madhab madhab,
    required String city,
  }) async {
    try {
      final params = method.getParameters();
      params.madhab = madhab;
      final days = <String, List<int>>{};
      final now = DateTime.now();
      for (var i = 0; i < 7; i++) {
        final d = now.add(Duration(days: i));
        final t = PrayerTimes(coordinates, DateComponents.from(d), params);
        days[_dateKey(d)] = [t.fajr, t.dhuhr, t.asr, t.maghrib, t.isha]
            .map((x) => x.toLocal().millisecondsSinceEpoch)
            .toList();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        prayerKey,
        jsonEncode({'city': city, 'days': days}),
      );
      await refresh();
    } catch (e) {
      debugPrint('widget prayer sync failed: $e');
    }
  }

  /// Asks the launcher to add a widget to the home screen. [kind] is
  /// "verse", "dhikr" or "prayer". Returns false when the launcher doesn't
  /// support pinning (the user then has to add it manually).
  static Future<bool> requestPin(String kind) async {
    try {
      return await _channel.invokeMethod<bool>('pin', kind) ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      debugPrint('widget pin failed: $e');
      return false;
    }
  }

  /// Asks the native side to redraw all widgets (no-op off Android / in tests).
  static Future<void> refresh() async {
    try {
      await _channel.invokeMethod<void>('refresh');
    } on MissingPluginException {
      // not running on Android
    } catch (e) {
      debugPrint('widget refresh failed: $e');
    }
  }
}
