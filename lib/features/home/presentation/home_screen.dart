import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/arabic_format.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/notifications/notification_service.dart';
import '../../widgets/widget_pin_section.dart';
import '../../../core/theme/app_colors.dart';
import '../../adhkar/data/adhkar_repository.dart';
import '../../adhkar/presentation/adhkar_screen.dart';
import '../../prayer_times/presentation/prayer_times_screen.dart';
import '../../quran/data/quran_repository.dart';
import '../../quran/data/reading_prefs.dart';
import '../../quran/data/surah_metadata.dart';
import '../../settings/presentation/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السلام عليكم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _PermissionBanner(),
          const _WelcomeCard(),
          const SizedBox(height: 16),
          const _QuickActions(),
          const SizedBox(height: 16),
          const _NextPrayerCard(),
          const SizedBox(height: 16),
          const _ContinueReadingCard(),
          const SizedBox(height: 16),
          const _AdhkarReminderCard(),
          const SizedBox(height: 16),
          const WidgetPinSection(),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.deepEmerald, Color(0xFF3C97A0)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepEmerald.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
            style: TextStyle(
              fontFamily: 'ScheherazadeNew',
              fontSize: 22,
              color: AppColors.warmIvory,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'واصل رحلتك اليومية مع القرآن والأذكار',
            style: TextStyle(
              color: AppColors.warmIvory.withOpacity(0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.menu_book,
            label: 'المصحف',
            color: AppColors.deepEmerald,
            onTap: () => context.go('/quran/mushaf'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.auto_awesome,
            label: 'الأذكار',
            color: AppColors.mutedGold,
            onTap: () => context.go('/adhkar/category/1'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.fingerprint,
            label: 'التسبيح',
            color: AppColors.mutedGreen,
            onTap: () => context.go('/tasbeeh'),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextPrayerCard extends ConsumerWidget {
  const _NextPrayerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerTimesProvider);
    final notifier = ref.read(prayerTimesProvider.notifier);
    final times = state.times;
    final now = DateTime.now();

    String nameAr = '--';
    String timeText = '--:--';
    if (times != null) {
      final entries = <(String, String, DateTime)>[
        ('Fajr', 'الفجر', times.fajr.toLocal()),
        ('Dhuhr', 'الظهر', times.dhuhr.toLocal()),
        ('Asr', 'العصر', times.asr.toLocal()),
        ('Maghrib', 'المغرب', times.maghrib.toLocal()),
        ('Isha', 'العشاء', times.isha.toLocal()),
      ];
      var next = entries.where((e) => e.$3.isAfter(now)).firstOrNull;
      next ??= ('Fajr', 'الفجر', notifier.nextDayFajr());
      nameAr = next.$2;
      timeText = formatTimeAr(next.$3);
    }

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => context.go('/prayer'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.mutedGold.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.mutedGold,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الصلاة القادمة',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    Text(
                      nameAr,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Text(
                timeText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepEmerald,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueReadingCard extends ConsumerWidget {
  const _ContinueReadingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastPage = ref.watch(lastReadPageProvider);
    final page = lastPage ?? 1;
    final surah = surahForPage(page);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => context.go('/quran/mushaf?page=$page'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lastPage == null ? 'ابدأ القراءة' : 'أكمل القراءة',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'سُورَةُ ${surah.nameArabic}',
                style: const TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 18,
                  color: AppColors.deepEmerald,
                ),
              ),
              const SizedBox(height: 4),
              FutureBuilder<List<AyahData>>(
                future: ref.read(quranRepositoryProvider).getAyahsForPage(page),
                builder: (context, snapshot) {
                  final juz = (snapshot.data?.isNotEmpty ?? false)
                      ? ' • الجزء ${toArabicDigits(snapshot.data!.first.juzNumber)}'
                      : '';
                  return Text(
                    'صفحة ${toArabicDigits(page)}$juz',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdhkarReminderCard extends ConsumerWidget {
  const _AdhkarReminderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(adhkarProvider);
    final categories = ref.watch(adhkarCategoriesProvider).valueOrNull;
    String status = 'اضغط للبدء';
    if (categories != null) {
      final morning =
          categories.where((c) => c.id == kMorningEveningCategoryId).toList();
      if (morning.isNotEmpty) {
        final total = morning.first.items.length;
        final done = completedIn(morning.first, progress);
        status = done >= total
            ? 'تم اليوم'
            : '${toArabicDigits(done)} / ${toArabicDigits(total)} مكتمل';
      }
    }
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => context.go('/adhkar/category/1'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.mutedGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.wb_sunny_outlined, color: AppColors.mutedGold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'أذكار الصباح والمساء',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      status,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}


/// Shown only when something prevents the adhan/reminders from working:
/// notifications blocked, or exact alarms not allowed (adhan could be late).
class _PermissionBanner extends ConsumerStatefulWidget {
  const _PermissionBanner();

  @override
  ConsumerState<_PermissionBanner> createState() => _PermissionBannerState();
}

class _PermissionBannerState extends ConsumerState<_PermissionBanner>
    with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() => _status = NotificationService().status());
    }
  }

  @override
  Widget build(BuildContext context) {
    final adhanOn = ref.watch(appSettingsProvider.select((s) => s.adhanEnabled));
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<NotificationStatus>(
      future: _status,
      builder: (context, snap) {
        final st = snap.data;
        if (st == null) return const SizedBox.shrink();

        String? message;
        String? action;
        VoidCallback? onAction;
        if (!st.notificationsAllowed) {
          message = 'الإشعارات متوقفة، فلن يعمل الأذان ولا التذكير.';
          action = 'السماح بالإشعارات';
          onAction = openAppSettings;
        } else if (adhanOn && st.exactAlarmsAllowed == false) {
          message = 'للأذان في موعده بالثانية، اسمح بالمنبّهات الدقيقة.';
          action = 'السماح';
          onAction = NotificationService().requestExactAlarmPermission;
        }
        if (message == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.tertiaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: cs.onTertiaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: cs.onTertiaryContainer, fontSize: 14),
                ),
              ),
              TextButton(onPressed: onAction, child: Text(action!)),
            ],
          ),
        );
      },
    );
  }
}
