import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'surah_metadata.dart';

abstract class QuranRepository {
  Future<List<SurahMeta>> getAllSurahs();
  Future<SurahMeta?> getSurah(int number);
  Future<List<AyahData>> getAyahsForSurah(int surahNumber);
  Future<List<AyahData>> getAyahsForPage(int pageNumber);
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
    required this.hizbNumber,
    this.isSajdah = false,
  });
}

class LocalQuranRepository implements QuranRepository {
  @override
  Future<List<SurahMeta>> getAllSurahs() async => allSurahs;

  @override
  Future<SurahMeta?> getSurah(int number) async {
    try {
      return allSurahs.firstWhere((s) => s.number == number);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<AyahData>> getAyahsForSurah(int surahNumber) async => [];

  @override
  Future<List<AyahData>> getAyahsForPage(int pageNumber) async => [];

  @override
  Future<void> importFromAssetIfNeeded() async {}

  @override
  Future<bool> isDataImported() async => false;
}

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return LocalQuranRepository();
});
