import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../prayer_times/data/adhan_voices.dart';
import 'settings_screen.dart';

/// Lets the user verify, on the device, that notifications and their sounds
/// (adhan, "صلِّ على النبي", "اذكر الله") really work.
class NotificationCheckSection extends ConsumerStatefulWidget {
  const NotificationCheckSection({super.key});

  @override
  ConsumerState<NotificationCheckSection> createState() =>
      _NotificationCheckSectionState();
}

class _NotificationCheckSectionState
    extends ConsumerState<NotificationCheckSection> with WidgetsBindingObserver {
  late Future<NotificationStatus> _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _status = NotificationService().status();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the system settings: re-check.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() => _status = NotificationService().status());
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _test(Future<bool> Function() action, String okMessage) async {
    final ok = await action();
    if (!mounted) return;
    _toast(ok
        ? okMessage
        : 'تعذر إرسال الإشعار. تأكد من السماح بالإشعارات للتطبيق.');
    _refresh();
  }

  Widget _row(BuildContext context, String label, bool? ok, {String? trailing}) {
    final cs = Theme.of(context).colorScheme;
    final icon = ok == null
        ? Icons.help_outline
        : (ok ? Icons.check_circle : Icons.cancel);
    final color = ok == null
        ? cs.onSurfaceVariant
        : (ok ? AppColors.success : AppColors.error);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          if (trailing != null)
            Text(trailing,
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: cs.onSurface)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = ref.watch(appSettingsProvider);
    final voice = adhanVoiceById(s.adhanVoiceId);
    final fajr = adhanVoiceById(s.adhanFajrVoiceId);
    final service = NotificationService();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined,
                  color: AppColors.deepEmerald),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'فحص الإشعارات والأصوات',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'تحديث',
                icon: const Icon(Icons.refresh),
                onPressed: _refresh,
              ),
            ],
          ),
          const SizedBox(height: 4),
          FutureBuilder<NotificationStatus>(
            future: _status,
            builder: (context, snap) {
              final st = snap.data;
              if (st == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _row(context, 'الإشعارات مسموحة للتطبيق', st.notificationsAllowed),
                  if (!st.notificationsAllowed)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: openAppSettings,
                        child: const Text('فتح إعدادات التطبيق'),
                      ),
                    ),
                  _row(context, 'المنبّهات الدقيقة (الأذان في موعده بالثانية)',
                      st.exactAlarmsAllowed),
                  if (st.exactAlarmsAllowed == false)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: service.requestExactAlarmPermission,
                        child: const Text('السماح بالمنبّهات الدقيقة'),
                      ),
                    ),
                  _row(context, 'أذان مجدول', st.adhanScheduled > 0,
                      trailing: '${st.adhanScheduled}'),
                  _row(context, 'تذكيرات صلِّ على النبي / اذكر الله مجدولة',
                      st.reminderScheduled > 0,
                      trailing: '${st.reminderScheduled}'),
                  _row(context, 'أذكار الصباح والمساء', st.dailyAdhkarScheduled > 0,
                      trailing: '${st.dailyAdhkarScheduled}'),
                ],
              );
            },
          ),
          const Divider(height: 24),
          Text(
            'اضغط لتجربة الصوت الآن (تأكد أن الموبايل ليس على الصامت):',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _test(
                  () => service.showTestAdhan(voice),
                  'تم إرسال الأذان. اسحب الإشعار لإيقاف الصوت.',
                ),
                icon: const Icon(Icons.mosque_outlined, size: 18),
                label: const Text('جرّب الأذان'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _test(
                  () => service.showTestAdhan(fajr),
                  'تم إرسال أذان الفجر. اسحب الإشعار لإيقاف الصوت.',
                ),
                icon: const Icon(Icons.wb_twilight, size: 18),
                label: const Text('جرّب أذان الفجر'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _test(
                  () => service.showTestReminder(salawat: true),
                  'تم إرسال تذكير «صلِّ على النبي».',
                ),
                icon: const Icon(Icons.volume_up_outlined, size: 18),
                label: const Text('جرّب «صلِّ على النبي»'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _test(
                  () => service.showTestReminder(salawat: false),
                  'تم إرسال تذكير «اذكر الله».',
                ),
                icon: const Icon(Icons.volume_up_outlined, size: 18),
                label: const Text('جرّب «اذكر الله»'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'لو ما سمعتش الصوت: افتح إعدادات الإشعارات للتطبيق وتأكد من قنوات «الأذان» و«تذكير بالصوت». '
            'وعلى أجهزة Xiaomi وOppo وSamsung وHuawei فعّل «التشغيل التلقائي» واستثنِ التطبيق من توفير البطارية.',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: openAppSettings,
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text('فتح إعدادات التطبيق'),
            ),
          ),
        ],
      ),
    );
  }
}
