import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/notifications/notification_service.dart';
import '../../prayer_times/data/adhan_voices.dart';
import '../data/settings_prefs.dart';
import '../../widgets/widget_pin_section.dart';
import 'adhan_voice_sheet.dart';

class AppSettingsState {
  final String languageCode;
  final ThemeMode themeMode;
  final double quranFontSize;
  final String calculationMethod;
  final String asrMethod;
  final bool notificationsEnabled;
  final bool morningAdhkarEnabled;
  final bool eveningAdhkarEnabled;
  final bool widgetAutoProgress;
  final bool dhikrReminderEnabled;
  final int dhikrIntervalMinutes;
  final bool dhikrQuietHours;
  final bool reminderVoice;
  final bool adhanEnabled;
  final String adhanVoiceId;
  final String adhanFajrVoiceId;

  const AppSettingsState({
    this.languageCode = 'ar',
    this.themeMode = ThemeMode.system,
    this.quranFontSize = 24,
    this.calculationMethod = 'egyptian',
    this.asrMethod = 'shafi',
    this.notificationsEnabled = true,
    this.morningAdhkarEnabled = true,
    this.eveningAdhkarEnabled = true,
    this.widgetAutoProgress = true,
    this.dhikrReminderEnabled = true,
    this.dhikrIntervalMinutes = 15,
    this.dhikrQuietHours = true,
    this.reminderVoice = true,
    this.adhanEnabled = true,
    this.adhanVoiceId = kDefaultAdhanVoiceId,
    this.adhanFajrVoiceId = kDefaultFajrVoiceId,
  });

  AppSettingsState copyWith({
    String? languageCode,
    ThemeMode? themeMode,
    double? quranFontSize,
    String? calculationMethod,
    String? asrMethod,
    bool? notificationsEnabled,
    bool? morningAdhkarEnabled,
    bool? eveningAdhkarEnabled,
    bool? widgetAutoProgress,
    bool? dhikrReminderEnabled,
    int? dhikrIntervalMinutes,
    bool? dhikrQuietHours,
    bool? reminderVoice,
    bool? adhanEnabled,
    String? adhanVoiceId,
    String? adhanFajrVoiceId,
  }) {
    return AppSettingsState(
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      quranFontSize: quranFontSize ?? this.quranFontSize,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      asrMethod: asrMethod ?? this.asrMethod,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      morningAdhkarEnabled: morningAdhkarEnabled ?? this.morningAdhkarEnabled,
      eveningAdhkarEnabled: eveningAdhkarEnabled ?? this.eveningAdhkarEnabled,
      widgetAutoProgress: widgetAutoProgress ?? this.widgetAutoProgress,
      dhikrReminderEnabled: dhikrReminderEnabled ?? this.dhikrReminderEnabled,
      dhikrIntervalMinutes: dhikrIntervalMinutes ?? this.dhikrIntervalMinutes,
      dhikrQuietHours: dhikrQuietHours ?? this.dhikrQuietHours,
      reminderVoice: reminderVoice ?? this.reminderVoice,
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      adhanVoiceId: adhanVoiceId ?? this.adhanVoiceId,
      adhanFajrVoiceId: adhanFajrVoiceId ?? this.adhanFajrVoiceId,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  AppSettingsNotifier(this._prefs, this._notifications)
      : super(const AppSettingsState()) {
    _load();
  }

  final SettingsPrefs _prefs;
  final NotificationService _notifications;

  Future<void> _load() async {
    state = await _prefs.load();
    await _syncNotifications();
  }

  Future<void> _persist() => _prefs.save(state);

  Future<void> _syncNotifications() async {
    try {
      if (!state.notificationsEnabled) {
        await _notifications.cancelAdhkar();
        await _notifications.cancelDhikrReminders();
        return;
      }
      await _notifications.scheduleDailyAdhkar(
        morningEnabled: state.morningAdhkarEnabled,
        eveningEnabled: state.eveningAdhkarEnabled,
      );
      await _notifications.scheduleDhikrReminders(
        enabled: state.dhikrReminderEnabled,
        intervalMinutes: state.dhikrIntervalMinutes,
        quietHours: state.dhikrQuietHours,
        voice: state.reminderVoice,
      );
    } catch (e) {
      debugPrint('notification sync failed: $e');
    }
  }

  void setLanguage(String code) {
    state = state.copyWith(languageCode: code);
    _persist();
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _persist();
  }

  void setFontSize(double size) {
    state = state.copyWith(quranFontSize: size.clamp(16, 40));
    _persist();
  }

  void setCalculationMethod(String method) {
    state = state.copyWith(calculationMethod: method);
    _persist();
  }

  void setAsrMethod(String method) {
    state = state.copyWith(asrMethod: method);
    _persist();
  }

  void setNotifications(bool v) {
    state = state.copyWith(notificationsEnabled: v);
    _persist();
    _syncNotifications();
  }

  void setMorningAdhkar(bool v) {
    state = state.copyWith(morningAdhkarEnabled: v);
    _persist();
    _syncNotifications();
  }

  void setEveningAdhkar(bool v) {
    state = state.copyWith(eveningAdhkarEnabled: v);
    _persist();
    _syncNotifications();
  }

  void setDhikrReminder(bool v) {
    state = state.copyWith(dhikrReminderEnabled: v);
    _persist();
    _syncNotifications();
  }

  void setDhikrInterval(int minutes) {
    state = state.copyWith(dhikrIntervalMinutes: minutes);
    _persist();
    _syncNotifications();
  }

  void setReminderVoice(bool v) {
    state = state.copyWith(reminderVoice: v);
    _persist();
    _syncNotifications();
  }

  void setAdhanEnabled(bool v) {
    state = state.copyWith(adhanEnabled: v);
    _persist();
    if (v) _notifications.requestExactAlarmPermission();
  }

  void setAdhanVoice(String id) {
    state = state.copyWith(adhanVoiceId: id);
    _persist();
  }

  void setAdhanFajrVoice(String id) {
    state = state.copyWith(adhanFajrVoiceId: id);
    _persist();
  }

  void setDhikrQuietHours(bool v) {
    state = state.copyWith(dhikrQuietHours: v);
    _persist();
    _syncNotifications();
  }

  void setWidgetAutoProgress(bool v) {
    state = state.copyWith(widgetAutoProgress: v);
    _persist();
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
  return AppSettingsNotifier(
    ref.watch(settingsPrefsProvider),
    ref.watch(notificationServiceProvider),
  );
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appSettingsProvider);
    final n = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        children: [
          _SectionHeader('المظهر واللغة'),
          _SettingsTile(
            title: 'اللغة',
            subtitle: _langLabel(s.languageCode),
            onTap: () => _pickLanguage(context, n, s.languageCode),
          ),
          _SettingsTile(
            title: 'المظهر',
            subtitle: _themeLabel(s.themeMode),
            onTap: () => _pickTheme(context, n, s.themeMode),
          ),
          ListTile(
            title: const Text('حجم خط المصحف'),
            subtitle: Slider(
              value: s.quranFontSize,
              min: 16,
              max: 40,
              divisions: 12,
              label: s.quranFontSize.round().toString(),
              activeColor: AppColors.deepEmerald,
              onChanged: n.setFontSize,
            ),
          ),
          const Divider(),
          _SectionHeader('مواقيت الصلاة'),
          _SettingsTile(
            title: 'طريقة الحساب',
            subtitle: _methodLabel(s.calculationMethod),
            onTap: () => _pickMethod(context, n, s.calculationMethod),
          ),
          _SettingsTile(
            title: 'مذهب العصر',
            subtitle: s.asrMethod == 'hanafi' ? 'حنفي' : 'شافعي / مالكي / حنبلي',
            onTap: () => _pickAsr(context, n, s.asrMethod),
          ),
          const Divider(),
          _SectionHeader('الإشعارات والأذكار'),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: WidgetPinSection(),
          ),
          SwitchListTile(
            title: const Text('تفعيل الإشعارات'),
            value: s.notificationsEnabled,
            activeColor: AppColors.deepEmerald,
            onChanged: n.setNotifications,
          ),
          SwitchListTile(
            title: const Text('تذكير أذكار الصباح'),
            value: s.morningAdhkarEnabled,
            activeColor: AppColors.deepEmerald,
            onChanged: s.notificationsEnabled ? n.setMorningAdhkar : null,
          ),
          SwitchListTile(
            title: const Text('تذكير أذكار المساء'),
            value: s.eveningAdhkarEnabled,
            activeColor: AppColors.deepEmerald,
            onChanged: s.notificationsEnabled ? n.setEveningAdhkar : null,
          ),
          SwitchListTile(
            title: const Text('تذكير «صلِّ على النبي» و«اذكر الله»'),
            subtitle: Text(
              'إشعار تلقائي ${_dhikrIntervalLabel(s.dhikrIntervalMinutes)}',
            ),
            value: s.dhikrReminderEnabled,
            activeColor: AppColors.deepEmerald,
            onChanged: s.notificationsEnabled ? n.setDhikrReminder : null,
          ),
          _SettingsTile(
            title: 'تكرار التذكير',
            subtitle: _dhikrIntervalLabel(s.dhikrIntervalMinutes),
            onTap: () => _showPicker(
              context,
              'تكرار التذكير',
              const {
                '15': 'كل ١٥ دقيقة',
                '30': 'كل ٣٠ دقيقة',
                '60': 'كل ساعة',
              },
              '${s.dhikrIntervalMinutes}',
              (v) => n.setDhikrInterval(int.tryParse(v) ?? 15),
            ),
          ),
          SwitchListTile(
            title: const Text('إيقاف التذكير ليلاً'),
            subtitle: const Text('من ١١ مساءً حتى ٤ فجراً'),
            value: s.dhikrQuietHours,
            activeColor: AppColors.deepEmerald,
            onChanged: (s.notificationsEnabled && s.dhikrReminderEnabled)
                ? n.setDhikrQuietHours
                : null,
          ),
          SwitchListTile(
            title: const Text('صوت «صلِّ على النبي» في التذكير'),
            subtitle: const Text('يُسمع صوت الذكر مع كل تذكير'),
            value: s.reminderVoice,
            activeColor: AppColors.deepEmerald,
            onChanged: (s.notificationsEnabled && s.dhikrReminderEnabled)
                ? n.setReminderVoice
                : null,
          ),
          SwitchListTile(
            title: const Text('الأذان عند وقت الصلاة'),
            subtitle: const Text('أذان بصوت محفوظ داخل التطبيق، بدون إنترنت'),
            value: s.adhanEnabled,
            activeColor: AppColors.deepEmerald,
            onChanged: s.notificationsEnabled ? n.setAdhanEnabled : null,
          ),
          _SettingsTile(
            title: 'صوت الأذان',
            subtitle: adhanVoiceById(s.adhanVoiceId).nameAr,
            onTap: () => showAdhanVoiceSheet(
              context,
              voices: kAdhanVoices,
              selectedId: s.adhanVoiceId,
              onSelected: n.setAdhanVoice,
            ),
          ),
          _SettingsTile(
            title: 'صوت أذان الفجر',
            subtitle: adhanVoiceById(s.adhanFajrVoiceId).nameAr,
            onTap: () => showAdhanVoiceSheet(
              context,
              voices: kFajrAdhanVoices,
              selectedId: s.adhanFajrVoiceId,
              onSelected: n.setAdhanFajrVoice,
            ),
          ),
          SwitchListTile(
            title: const Text('تقدم تلقائي في الـ Widget'),
            subtitle: const Text('بعد الضغط على «قرأت الآية»'),
            value: s.widgetAutoProgress,
            activeColor: AppColors.deepEmerald,
            onChanged: n.setWidgetAutoProgress,
          ),
          const Divider(),
          _SectionHeader('حول'),
          const ListTile(
            title: Text('سياسة الخصوصية'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            title: Text('حول التطبيق'),
            subtitle: Text('القرآن والأذكار • الإصدار 1.0.0'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: const Text('اختبار الإشعار'),
            subtitle: const Text('إرسال إشعار تجريبي الآن'),
            trailing: const Icon(Icons.notifications_active_outlined),
            onTap: () async {
              await ref.read(notificationServiceProvider).showTestNotification();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إرسال إشعار تجريبي')),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'الإعدادات تُحفظ محلياً وتبقى بعد إغلاق التطبيق.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _langLabel(String code) {
    const map = {
      'ar': 'العربية',
      'en': 'English',
      'fr': 'Français',
      'tr': 'Türkçe',
      'id': 'Indonesia',
      'ur': 'اردو',
      'bn': 'বাংলা',
      'ms': 'Melayu',
    };
    return map[code] ?? code;
  }

  String _themeLabel(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'حسب النظام';
    }
  }

  String _methodLabel(String m) {
    const map = {
      'egyptian': 'الهيئة المصرية',
      'muslim_world_league': 'رابطة العالم الإسلامي',
      'karachi': 'جامعة العلوم كراتشي',
      'umm_al_qura': 'أم القرى',
      'north_america': 'إسنا',
    };
    return map[m] ?? m;
  }

  void _pickLanguage(
      BuildContext context, AppSettingsNotifier n, String current) {
    final options = {
      'ar': 'العربية',
      'en': 'English',
      'fr': 'Français',
      'tr': 'Türkçe',
      'id': 'Indonesia',
      'ur': 'اردو',
      'bn': 'বাংলা',
      'ms': 'Melayu',
    };
    _showPicker(context, 'اللغة', options, current, n.setLanguage);
  }

  void _pickTheme(
      BuildContext context, AppSettingsNotifier n, ThemeMode current) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('فاتح'),
              trailing: current == ThemeMode.light
                  ? const Icon(Icons.check, color: AppColors.deepEmerald)
                  : null,
              onTap: () {
                n.setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('داكن'),
              trailing: current == ThemeMode.dark
                  ? const Icon(Icons.check, color: AppColors.deepEmerald)
                  : null,
              onTap: () {
                n.setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('حسب النظام'),
              trailing: current == ThemeMode.system
                  ? const Icon(Icons.check, color: AppColors.deepEmerald)
                  : null,
              onTap: () {
                n.setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickMethod(
      BuildContext context, AppSettingsNotifier n, String current) {
    final options = {
      'egyptian': 'الهيئة المصرية',
      'muslim_world_league': 'رابطة العالم الإسلامي',
      'karachi': 'جامعة العلوم كراتشي',
      'umm_al_qura': 'أم القرى',
      'north_america': 'إسنا',
    };
    _showPicker(context, 'طريقة الحساب', options, current, n.setCalculationMethod);
  }

  String _dhikrIntervalLabel(int minutes) {
    switch (minutes) {
      case 30:
        return 'كل ٣٠ دقيقة';
      case 60:
        return 'كل ساعة';
      default:
        return 'كل ١٥ دقيقة';
    }
  }

  void _pickAsr(BuildContext context, AppSettingsNotifier n, String current) {
    _showPicker(
      context,
      'مذهب العصر',
      {
        'shafi': 'شافعي / مالكي / حنبلي',
        'hanafi': 'حنفي',
      },
      current,
      n.setAsrMethod,
    );
  }

  void _showPicker(
    BuildContext context,
    String title,
    Map<String, String> options,
    String current,
    void Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            ...options.entries.map(
              (e) => ListTile(
                title: Text(e.value),
                trailing: e.key == current
                    ? const Icon(Icons.check, color: AppColors.deepEmerald)
                    : null,
                onTap: () {
                  onSelect(e.key);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.mutedGreen,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
