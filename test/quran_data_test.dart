import 'package:flutter_test/flutter_test.dart';
import 'package:quran_adhkar_app/features/quran/data/quran_repository.dart';
import 'package:quran_adhkar_app/features/quran/data/surah_metadata.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = LocalQuranRepository();

  test('bundled text has 6236 ayahs with the expected per-surah counts',
      () async {
    var total = 0;
    for (final s in allSurahs) {
      final ayahs = await repo.getAyahsForSurah(s.number);
      expect(ayahs.length, s.ayahCount, reason: 'surah ${s.number}');
      expect(ayahs.first.ayahNumber, 1);
      total += ayahs.length;
    }
    expect(total, 6236);
  });

  test('every surah starts on the page declared in the metadata', () async {
    for (final s in allSurahs) {
      final ayahs = await repo.getAyahsForSurah(s.number);
      expect(ayahs.first.pageNumber, s.pageStart, reason: 'surah ${s.number}');
    }
  });

  test('all 604 pages have text and 30 juz are present', () async {
    final juz = <int>{};
    for (var page = 1; page <= 604; page++) {
      final ayahs = await repo.getAyahsForPage(page);
      expect(ayahs, isNotEmpty, reason: 'page $page');
      juz.addAll(ayahs.map((a) => a.juzNumber));
    }
    expect(juz.length, 30);
  });

  test('normalizeArabic ignores diacritics and letter variants', () {
    expect(normalizeArabic('بِسۡمِ ٱللَّهِ'), 'بسم الله');
  });

  test('search finds the Basmala regardless of tashkeel', () async {
    final results = await repo.searchAyahs('بسم الله الرحمن الرحيم');
    expect(results, isNotEmpty);
    expect(results.first.surahNumber, 1);
    expect(results.first.ayahNumber, 1);
  });

  test('surahForPage maps boundary pages', () {
    expect(surahForPage(1).number, 1);
    expect(surahForPage(2).number, 2);
    expect(surahForPage(604).number, 114);
  });
}
