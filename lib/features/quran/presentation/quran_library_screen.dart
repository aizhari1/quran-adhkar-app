import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../data/surah_metadata.dart';
import '../data/quran_repository.dart';
import '../data/reading_prefs.dart';
import 'quran_search_delegate.dart';

class QuranLibraryScreen extends ConsumerWidget {
  const QuranLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(quranRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'بحث',
            onPressed: () => showSearch<void>(
              context: context,
              delegate: QuranSearchDelegate(
                repo: repo,
                onOpenPage: (page) => context.go('/quran/mushaf?page=$page'),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<SurahMeta>>(
        future: repo.getAllSurahs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final surahs = snapshot.data!;
          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _NavChip(label: 'المصحف', icon: Icons.menu_book, onTap: () => context.go('/quran/mushaf')),
                    _NavChip(label: 'الختمة', icon: Icons.flag_outlined, onTap: () => context.go('/quran/khatma')),
                    _NavChip(label: 'القراء', icon: Icons.headphones, onTap: () => context.go('/quran/reciters')),
                    _NavChip(label: 'الإشارات', icon: Icons.bookmark_outline, onTap: () => _showBookmarks(context, ref)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text('${surahs.length} Surahs', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: surahs.length,
                  itemBuilder: (context, index) {
                    final surah = surahs[index];
                    return _SurahTile(
                      surah: surah,
                      onTap: () => context.go('/quran/mushaf?page=${surah.pageStart}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

void _showBookmarks(BuildContext context, WidgetRef ref) {
  final pages = ref.read(bookmarksProvider);
  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: pages.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Text('لا توجد إشارات مرجعية بعد.\nاضغط على أيقونة الإشارة أثناء القراءة.',
                  textAlign: TextAlign.center),
            )
          : ListView(
              shrinkWrap: true,
              children: [
                for (final page in pages)
                  ListTile(
                    leading: const Icon(Icons.bookmark, color: AppColors.mutedGold),
                    title: Text(surahForPage(page).nameArabic,
                        textDirection: TextDirection.rtl),
                    subtitle: Text('صفحة $page'),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/quran/mushaf?page=$page');
                    },
                  ),
              ],
            ),
    ),
  );
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
          child: Text('${surah.number}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.deepEmerald)),
        ),
        title: Text(
          surah.nameArabic,
          style: const TextStyle(fontFamily: 'NotoNaskhArabic', fontSize: 18, fontWeight: FontWeight.w600),
          textDirection: TextDirection.rtl,
        ),
        subtitle: Text(
          '${surah.nameTransliteration} • ${surah.ayahCount} Ayahs • ${surah.revelationType}',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: Text('p.${surah.pageStart}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ),
    );
  }
}
