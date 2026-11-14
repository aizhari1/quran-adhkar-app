import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/quran_repository.dart';
import '../data/surah_metadata.dart';

/// Search by surah name/number and by ayah text (diacritics-insensitive).
class QuranSearchDelegate extends SearchDelegate<void> {
  QuranSearchDelegate({required this.repo, required this.onOpenPage})
      : super(searchFieldLabel: 'ابحث عن سورة أو آية');

  final QuranRepository repo;
  final void Function(int page) onOpenPage;

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  void _open(BuildContext context, int page) {
    close(context, null);
    onOpenPage(page);
  }

  Widget _results(BuildContext context) {
    final q = query.trim();
    if (q.isEmpty) {
      return const Center(
        child: Text('اكتب اسم سورة أو جزءاً من آية',
            style: TextStyle(color: AppColors.textMuted)),
      );
    }
    final nq = normalizeArabic(q);
    final lower = q.toLowerCase();
    final surahs = allSurahs.where((s) {
      return (nq.isNotEmpty && normalizeArabic(s.nameArabic).contains(nq)) ||
          s.nameTransliteration.toLowerCase().contains(lower) ||
          s.nameEnglish.toLowerCase().contains(lower) ||
          '${s.number}' == q;
    }).toList();

    return FutureBuilder<List<AyahData>>(
      future: repo.searchAyahs(q),
      builder: (context, snapshot) {
        final ayahs = snapshot.data ?? const <AyahData>[];
        final loading = snapshot.connectionState != ConnectionState.done;
        if (surahs.isEmpty && ayahs.isEmpty) {
          return Center(
            child: loading
                ? const CircularProgressIndicator()
                : const Text('لا توجد نتائج',
                    style: TextStyle(color: AppColors.textMuted)),
          );
        }
        return ListView(
          children: [
            for (final s in surahs)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.deepEmerald.withOpacity(0.1),
                  child: Text('${s.number}',
                      style: const TextStyle(color: AppColors.deepEmerald)),
                ),
                title: Text(s.nameArabic, textDirection: TextDirection.rtl),
                subtitle: Text('${s.nameTransliteration} • ص ${s.pageStart}'),
                onTap: () => _open(context, s.pageStart),
              ),
            for (final a in ayahs)
              ListTile(
                title: Text(
                  a.textUthmani,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontFamily: 'ScheherazadeNew', fontSize: 18),
                ),
                subtitle: Text(
                    '${surahByNumber(a.surahNumber).nameArabic} • آية ${a.ayahNumber} • ص ${a.pageNumber}'),
                onTap: () => _open(context, a.pageNumber),
              ),
          ],
        );
      },
    );
  }
}
