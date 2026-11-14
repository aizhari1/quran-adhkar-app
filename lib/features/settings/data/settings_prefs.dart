import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../prayer_times/data/adhan_voices.dart';
import '../presentation/settings_screen.dart';

/// Immediate offline persistence via SharedPreferences.
/// Drift SettingsRepository is used after build_runner generates code.
class SettingsPrefs {
  static const _prefix = 'settings_';

  Future<AppSettingsState> load() async {
    final p = await SharedPreferences.getInstance();
    return AppSettingsState(
      languageCode: p.getString('${_prefix}lang') ?? 'ar',
      themeMode: _parseTheme(p.getString('${_prefix}theme') ?? 'system'),
      quranFontSize: p.getDouble('${_prefix}font') ?? 24,
      calculationMethod: p.getString('${_prefix}calc') ?? 'egyptian',
      asrMethod: p.getString('${_prefix}asr') ?? 'shafi',
      notificationsEnabled: p.getBool('${_prefix}notif') ?? true,
      morningAdhkarEnabled: p.getBool('${_prefix}morning') ?? true,
      eveningAdhkarEnabled: p.getBool('${_prefix}evening') ?? true,
      widgetAutoProgress: p.getBool('${_prefix}widget') ?? true,
      dhikrReminderEnabled: p.getBool('${_prefix}dhikr') ?? true,
      dhikrIntervalMinutes: p.getInt('${_prefix}dhikr_interval') ?? 15,
      dhikrQuietHours: p.getBool('${_prefix}dhikr_quiet') ?? true,
      reminderVoice: p.getBool('${_prefix}reminder_voice') ?? true,
      adhanEnabled: p.getBool('${_prefix}adhan') ?? true,
      adhanVoiceId: p.getString('${_prefix}adhan_voice') ?? kDefaultAdhanVoiceId,
      adhanFajrVoiceId: p.getString('${_prefix}adhan_fajr_voice') ?? kDefaultFajrVoiceId,
    );
  }

  Future<void> save(AppSettingsState s) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('${_prefix}lang', s.languageCode);
    await p.setString('${_prefix}theme', _themeStr(s.themeMode));
    await p.setDouble('${_prefix}font', s.quranFontSize);
    await p.setString('${_prefix}calc', s.calculationMethod);
    await p.setString('${_prefix}asr', s.asrMethod);
    await p.setBool('${_prefix}notif', s.notificationsEnabled);
    await p.setBool('${_prefix}morning', s.morningAdhkarEnabled);
    await p.setBool('${_prefix}evening', s.eveningAdhkarEnabled);
    await p.setBool('${_prefix}widget', s.widgetAutoProgress);
    await p.setBool('${_prefix}dhikr', s.dhikrReminderEnabled);
    await p.setInt('${_prefix}dhikr_interval', s.dhikrIntervalMinutes);
    await p.setBool('${_prefix}dhikr_quiet', s.dhikrQuietHours);
    await p.setBool('${_prefix}reminder_voice', s.reminderVoice);
    await p.setBool('${_prefix}adhan', s.adhanEnabled);
    await p.setString('${_prefix}adhan_voice', s.adhanVoiceId);
    await p.setString('${_prefix}adhan_fajr_voice', s.adhanFajrVoiceId);
  }

  ThemeMode _parseTheme(String v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeStr(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final settingsPrefsProvider = Provider<SettingsPrefs>((ref) => SettingsPrefs());
