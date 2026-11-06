import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerseWidgetData {
  final int surahNumber;
  final int ayahNumber;
  final String surahNameArabic;
  final String textArabic;
  final String? translation;
  final int pageNumber;

  const VerseWidgetData({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahNameArabic,
    required this.textArabic,
    this.translation,
    this.pageNumber = 1,
  });
}

class VerseWidgetService {
  static const fallback = VerseWidgetData(
    surahNumber: 1,
    ayahNumber: 1,
    surahNameArabic: 'الفاتحة',
    textArabic: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
    translation:
        'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
    pageNumber: 1,
  );

  Future<void> init() async {}

  Future<void> updateVerse(VerseWidgetData data) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('widget_surah', data.surahNumber);
    await p.setInt('widget_ayah', data.ayahNumber);
    await p.setString('widget_surah_name', data.surahNameArabic);
    await p.setString('widget_text', data.textArabic);
    await p.setString('widget_translation', data.translation ?? '');
    await p.setInt('widget_page', data.pageNumber);
    debugPrint('Widget data saved locally');
  }

  Future<void> showFallback() => updateVerse(fallback);

  Future<VerseWidgetData?> advanceToNext() async {
    await showFallback();
    return fallback;
  }
}

final verseWidgetServiceProvider = Provider<VerseWidgetService>((ref) {
  return VerseWidgetService();
});
