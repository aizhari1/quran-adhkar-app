import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared data for the home-screen Quran verse widget.
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
  static const appGroupId = 'group.com.quranadhkar.app';
  static const androidWidgetName = 'QuranVerseWidgetProvider';
  static const iOSWidgetName = 'QuranVerseWidget';

  /// Public Basmala only as placeholder until Tanzil import.
  static const fallback = VerseWidgetData(
    surahNumber: 1,
    ayahNumber: 1,
    surahNameArabic: 'الفاتحة',
    textArabic: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
    translation:
        'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
    pageNumber: 1,
  );

  Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
    } catch (e) {
      debugPrint('HomeWidget setAppGroupId: $e');
    }
  }

  Future<void> updateVerse(VerseWidgetData data) async {
    await HomeWidget.saveWidgetData<int>('surahNumber', data.surahNumber);
    await HomeWidget.saveWidgetData<int>('ayahNumber', data.ayahNumber);
    await HomeWidget.saveWidgetData<String>(
        'surahNameArabic', data.surahNameArabic);
    await HomeWidget.saveWidgetData<String>('textArabic', data.textArabic);
    await HomeWidget.saveWidgetData<String>(
        'translation', data.translation ?? '');
    await HomeWidget.saveWidgetData<int>('pageNumber', data.pageNumber);

    final p = await SharedPreferences.getInstance();
    await p.setInt('widget_surah', data.surahNumber);
    await p.setInt('widget_ayah', data.ayahNumber);
    await p.setString('widget_surah_name', data.surahNameArabic);
    await p.setString('widget_text', data.textArabic);
    await p.setString('widget_translation', data.translation ?? '');
    await p.setInt('widget_page', data.pageNumber);

    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: iOSWidgetName,
      androidName: androidWidgetName,
    );
  }

  Future<void> showFallback() => updateVerse(fallback);

  Future<VerseWidgetData?> advanceToNext() async {
    final p = await SharedPreferences.getInstance();
    final n = (p.getInt('widget_tap_count') ?? 0) + 1;
    await p.setInt('widget_tap_count', n);
    await showFallback();
    return fallback;
  }
}

final verseWidgetServiceProvider = Provider<VerseWidgetService>((ref) {
  return VerseWidgetService();
});
