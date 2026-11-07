import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../adhkar/presentation/adhkar_screen.dart';
import '../../prayer_times/presentation/prayer_times_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
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
          const _WelcomeCard(),
          const SizedBox(height: 16),
          const _QuickActions(),
          const SizedBox(height: 16),
          const _NextPrayerCard(),
          const SizedBox(height: 16),
          const _ContinueReadingCard(),
          const SizedBox(height: 16),
          const _AdhkarReminderCard(),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.deepEmerald,
        borderRadius: BorderRadius.circular(16),
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
            'Continue your daily journey with the Quran and Adhkar',
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
            label: 'Mushaf',
            color: AppColors.deepEmerald,
            onTap: () => context.go('/quran/mushaf'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.auto_awesome,
            label: 'Adhkar',
            color: AppColors.mutedGold,
            onTap: () => context.go('/adhkar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.fingerprint,
            label: 'Tasbeeh',
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
      color: Colors.white,
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
    String nameEn = '';
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
      nameEn = next.$1;
      nameAr = next.$2;
      timeText = DateFormat.jm().format(next.$3);
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.go('/prayer'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
                      'Next Prayer',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    Text(
                      '$nameAr  $nameEn',
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

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.go('/quran/mushaf?page=42'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Continue Reading',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'سُورَةُ ٱلْبَقَرَةِ • آية 255',
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 18,
                  color: AppColors.deepEmerald,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Page 42 • Juz 3',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
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
    final done =
        morningAdhkar.where((i) => progress.completed.contains(i.id)).length;
    final status = done >= morningAdhkar.length
        ? 'Completed today'
        : '$done / ${morningAdhkar.length} completed';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.go('/adhkar'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
                      'Morning Adhkar',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      'After Fajr • $status',
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
