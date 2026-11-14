import 'dart:convert';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'surah_metadata.dart';

/// Removes tashkeel / Quranic annotation marks and unifies letter variants so
/// Arabic search works regardless of diacritics or spelling variants.
String normalizeArabic(String input) {
  final stripped = input.replaceAll(
    RegExp('[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u08D3-\u08FF\u0640]'),
    '',
  );
  final buffer = StringBuffer();
  for (final rune in stripped.runes) {
    switch (rune) {
      case 0x0671: // ٱ
      case 0x0623: // أ
      case 0x0625: // إ
      case 0x0622: // آ
        buffer.write('\u0627');
        break;
      case 0x0649: // ى
      case 0x06CC: // ی
        buffer.write('\u064A');
        break;
      case 0x0629: // ة
        buffer.write('\u0647');
        break;
      case 0x06A9: // ک
        buffer.write('\u0643');
        break;
      default:
        buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

String toArabicDigits(int number) {
  const digits = '٠١٢٣٤٥٦٧٨٩';
  return number
      .toString()
      .split('')
      .map((c) => digits[int.parse(c)])
      .join();
}

abstract class QuranRepository {
  Future<List<SurahMeta>> getAllSurahs();
  Future<SurahMeta?> getSurah(int number);
  Future<List<AyahData>> getAyahsForSurah(int surahNumber);
  Future<List<AyahData>> getAyahsForPage(int pageNumber);
  Future<List<AyahData>> searchAyahs(String query, {int limit = 50});

  /// The Basmala text as it appears in the data (surah 1, ayah 1).
  Future<String> getBasmala();
  Future<void> importFromAssetIfNeeded();
  Future<bool> isDataImported();
}

class AyahData {
  final int surahNumber;
  final int ayahNumber;
  final String textUthmani;
  final int pageNumber;
  final int juzNumber;
  final int hizbNumber;
  final bool isSajdah;

  const AyahData({
    required this.surahNumber,
    required this.ayahNumber,
    required this.textUthmani,
    required this.pageNumber,
    required this.juzNumber,
    this.hizbNumber = 0,
    this.isSajdah = false,
  });
}

List<AyahData> _parseAyahs(String raw) {
  final map = jsonDecode(raw) as Map<String, dynamic>;
  final rows = map['ayahs'] as List<dynamic>;
  return rows.map((r) {
    final l = r as List<dynamic>;
    return AyahData(
      surahNumber: l[0] as int,
      ayahNumber: l[1] as int,
      pageNumber: l[2] as int,
      juzNumber: l[3] as int,
      isSajdah: (l[4] as int) == 1,
      textUthmani: l[5] as String,
    );
  }).toList(growable: false);
}

class _QuranIndex {
  _QuranIndex(this.all)
      : normalized = all.map((a) => normalizeArabic(a.textUthmani)).toList(),
        byPage = _group(all, (a) => a.pageNumber),
        bySurah = _group(all, (a) => a.surahNumber);

  final List<AyahData> all;
  final List<String> normalized;
  final Map<int, List<AyahData>> byPage;
  final Map<int, List<AyahData>> bySurah;

  static Map<int, List<AyahData>> _group(
      List<AyahData> all, int Function(AyahData) key) {
    final map = <int, List<AyahData>>{};
    for (final a in all) {
      map.putIfAbsent(key(a), () => <AyahData>[]).add(a);
    }
    return map;
  }
}

/// Reads the bundled Uthmani Hafs text (assets/quran/quran-uthmani.json).
/// See docs/CONTENT_SOURCES.md for provenance. Text is never modified.
class LocalQuranRepository implements QuranRepository {
  LocalQuranRepository({
    this.assetPath = 'assets/quran/quran-uthmani.json',
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  final String assetPath;
  final AssetBundle _bundle;
  Future<_QuranIndex>? _index;

  Future<_QuranIndex> _load() {
    return _index ??= _build().catchError((Object e) {
      _index = null; // allow retry after a failed load
      throw e;
    });
  }

  Future<_QuranIndex> _build() async {
    final raw = await _bundle.loadString(assetPath);
    return _QuranIndex(_parseAyahs(raw));
  }

  @override
  Future<List<SurahMeta>> getAllSurahs() async => allSurahs;

  @override
  Future<SurahMeta?> getSurah(int number) async {
    if (number < 1 || number > allSurahs.length) return null;
    return allSurahs[number - 1];
  }

  @override
  Future<List<AyahData>> getAyahsForSurah(int surahNumber) async {
    final index = await _load();
    return index.bySurah[surahNumber] ?? const <AyahData>[];
  }

  @override
  Future<List<AyahData>> getAyahsForPage(int pageNumber) async {
    final index = await _load();
    return index.byPage[pageNumber] ?? const <AyahData>[];
  }

  @override
  Future<List<AyahData>> searchAyahs(String query, {int limit = 50}) async {
    final q = normalizeArabic(query.trim());
    if (q.length < 2) return const <AyahData>[];
    final index = await _load();
    final results = <AyahData>[];
    for (var i = 0; i < index.all.length; i++) {
      if (index.normalized[i].contains(q)) {
        results.add(index.all[i]);
        if (results.length >= limit) break;
      }
    }
    return results;
  }

  @override
  Future<String> getBasmala() async {
    final index = await _load();
    return index.all.first.textUthmani;
  }

  @override
  Future<void> importFromAssetIfNeeded() async {
    await _load();
  }

  @override
  Future<bool> isDataImported() async {
    try {
      await _load();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return LocalQuranRepository();
});
