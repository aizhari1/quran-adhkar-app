import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TafsirBook {
  final String id;
  final String name;
  final String description;
  const TafsirBook(this.id, this.name, this.description);
}

/// Tafsir books bundled offline in assets/tafsir/<id>.json.
const List<TafsirBook> kTafsirBooks = [
  TafsirBook('muyassar', 'التفسير الميسّر', 'موجز وواضح، مناسب للقراءة السريعة'),
  TafsirBook('jalalayn', 'تفسير الجلالين', 'مختصر للإمامين المحلّي والسيوطي'),
  TafsirBook('saadi', 'تفسير السعدي', 'تيسير الكريم الرحمن، أوسع وأعمق'),
];

const String kDefaultTafsirId = 'muyassar';

TafsirBook tafsirBookById(String id) =>
    kTafsirBooks.firstWhere((b) => b.id == id, orElse: () => kTafsirBooks.first);

class TafsirIndex {
  TafsirIndex(this._byKey);
  final Map<int, String> _byKey;

  /// - null: this edition has no entry for the ayah
  /// - '' (empty): the commentary is shared with the previous ayah
  /// - otherwise: the tafsir text, exactly as in the source
  String? textFor(int surah, int ayah) => _byKey[surah * 1000 + ayah];

  int get length => _byKey.length;
}

TafsirIndex _parseTafsir(String raw) {
  final map = jsonDecode(raw) as Map<String, dynamic>;
  final rows = map['rows'] as List<dynamic>;
  final byKey = <int, String>{};
  for (final r in rows) {
    final l = r as List<dynamic>;
    byKey[(l[0] as int) * 1000 + (l[1] as int)] = l[2] as String;
  }
  return TafsirIndex(byKey);
}

final tafsirIndexProvider =
    FutureProvider.family<TafsirIndex, String>((ref, bookId) async {
  final raw = await rootBundle.loadString('assets/tafsir/$bookId.json');
  return compute(_parseTafsir, raw);
});

class TafsirBookNotifier extends StateNotifier<String> {
  TafsirBookNotifier() : super(kDefaultTafsirId) {
    _load();
  }

  static const _key = 'tafsir_book';

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final id = p.getString(_key);
      if (id != null && kTafsirBooks.any((b) => b.id == id) && mounted) {
        state = id;
      }
    } catch (_) {}
  }

  Future<void> select(String id) async {
    if (!kTafsirBooks.any((b) => b.id == id)) return;
    state = id;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_key, id);
    } catch (_) {}
  }
}

final tafsirBookProvider =
    StateNotifierProvider<TafsirBookNotifier, String>((ref) {
  return TafsirBookNotifier();
});
