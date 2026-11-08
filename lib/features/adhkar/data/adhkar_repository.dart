import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One dhikr/du'a. [text] is shown exactly as in the source (never edited).
class AdhkarItem {
  final int id;
  final String text;
  final int count;
  const AdhkarItem({required this.id, required this.text, required this.count});
}

class AdhkarCategory {
  final int id;
  final String title;
  final List<AdhkarItem> items;
  const AdhkarCategory({
    required this.id,
    required this.title,
    required this.items,
  });

  String keyFor(AdhkarItem item) => adhkarKey(id, item.id);
}

String adhkarKey(int categoryId, int itemId) => '$categoryId:$itemId';

/// Chapter ids in the bundled Hisn al-Muslim data.
const int kMorningEveningCategoryId = 1;
const int kSleepCategoryId = 2;
const int kWakingCategoryId = 3;
const int kAfterPrayerCategoryId = 27;

List<AdhkarCategory> _parseCategories(String raw) {
  final map = jsonDecode(raw) as Map<String, dynamic>;
  final cats = map['categories'] as List<dynamic>;
  return cats.map((c) {
    final m = c as Map<String, dynamic>;
    final items = (m['items'] as List<dynamic>).map((i) {
      final im = i as Map<String, dynamic>;
      return AdhkarItem(
        id: im['id'] as int,
        text: im['text'] as String,
        count: im['count'] as int,
      );
    }).toList(growable: false);
    return AdhkarCategory(
      id: m['id'] as int,
      title: m['title'] as String,
      items: items,
    );
  }).toList(growable: false);
}

/// Loads assets/adhkar/hisn-al-muslim.json (132 chapters, 267 adhkar).
final adhkarCategoriesProvider =
    FutureProvider<List<AdhkarCategory>>((ref) async {
  final raw = await rootBundle.loadString('assets/adhkar/hisn-al-muslim.json');
  return _parseCategories(raw);
});
