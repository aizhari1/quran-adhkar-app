import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Surah metadata (will be loaded from Drift after Quran data import).
class SurahMeta {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final int ayahCount;
  final String revelationType;
  final int pageStart;

  const SurahMeta({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.ayahCount,
    required this.revelationType,
    required this.pageStart,
  });
}

/// Minimal verified list of first 10 surahs for UI scaffolding.
/// Full 114 will come from Tanzil / verified dataset import.
const sampleSurahs = [
  SurahMeta(number: 1, nameArabic: 'الفاتحة', nameEnglish: 'Al-Fatihah', ayahCount: 7, revelationType: 'Meccan', pageStart: 1),
  SurahMeta(number: 2, nameArabic: 'البقرة', nameEnglish: 'Al-Baqarah', ayahCount: 286, revelationType: 'Medinan', pageStart: 2),
  SurahMeta(number: 3, nameArabic: 'آل عمران', nameEnglish: 'Ali \'Imran', ayahCount: 200, revelationType: 'Medinan', pageStart: 50),
  SurahMeta(number: 4, nameArabic: 'النساء', nameEnglish: 'An-Nisa', ayahCount: 176, revelationType: 'Medinan', pageStart: 77),
  SurahMeta(number: 5, nameArabic: 'المائدة', nameEnglish: 'Al-Ma\'idah', ayahCount: 120, revelationType: 'Medinan', pageStart: 106),
  SurahMeta(number: 6, nameArabic: 'الأنعام', nameEnglish: 'Al-An\'am', ayahCount: 165, revelationType: 'Meccan', pageStart: 128),
  SurahMeta(number: 7, nameArabic: 'الأعراف', nameEnglish: 'Al-A\'raf', ayahCount: 206, revelationType: 'Meccan', pageStart: 151),
  SurahMeta(number: 8, nameArabic: 'الأنفال', nameEnglish: 'Al-Anfal', ayahCount: 75, revelationType: 'Medinan', pageStart: 177),
  SurahMeta(number: 9, nameArabic: 'التوبة', nameEnglish: 'At-Tawbah', ayahCount: 129, revelationType: 'Medinan', pageStart: 187),
  SurahMeta(number: 10, nameArabic: 'يونس', nameEnglish: 'Yunus', ayahCount: 109, revelationType: 'Meccan', pageStart: 208),
];

class QuranLibraryScreen extends ConsumerWidget {
  const QuranLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _NavChip(
                  label: 'المصحف',
                  icon: Icons.menu_book,
                  onTap: () => context.go('/quran/mushaf'),
                ),
                _NavChip(
                  label: 'الختمة',
                  icon: Icons.flag_outlined,
                  onTap: () => context.go('/quran/khatma'),
                ),
                _NavChip(
                  label: 'القراء',
                  icon: Icons.headphones,
                  onTap: () => context.go('/quran/reciters'),
                ),
                _NavChip(
                  label: 'الإشارات',
                  icon: Icons.bookmark_outline,
                  onTap: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sampleSurahs.length,
              itemBuilder: (context, index) {
                final surah = sampleSurahs[index];
                return _SurahTile(
                  surah: surah,
                  onTap: () => context.go('/quran/mushaf?page=${surah.pageStart}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 18, color: AppColors.deepEmerald),
        label: Text(label),
        onPressed: onTap,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.borderLight),
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  const _SurahTile({required this.surah, required this.onTap});
  final SurahMeta surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.deepEmerald.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '${surah.number}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.deepEmerald,
            ),
          ),
        ),
        title: Text(
          surah.nameArabic,
          style: const TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textDirection: TextDirection.rtl,
        ),
        subtitle: Text(
          '${surah.nameEnglish} • ${surah.ayahCount} Ayahs • ${surah.revelationType}',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: Text(
          'p.${surah.pageStart}',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
