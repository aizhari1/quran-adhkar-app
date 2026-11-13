import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_adhkar_app/features/quran/data/surah_metadata.dart';
import 'package:quran_adhkar_app/features/tafsir/tafsir_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final book in kTafsirBooks) {
    test('${book.id}: asset parses and covers the Quran', () async {
      final raw = await rootBundle.loadString('assets/tafsir/${book.id}.json');
      final rows = (jsonDecode(raw) as Map<String, dynamic>)['rows'] as List<dynamic>;
      final per = <int, Set<int>>{};
      for (final r in rows) {
        final l = r as List<dynamic>;
        per.putIfAbsent(l[0] as int, () => <int>{}).add(l[1] as int);
        expect(l[2], isA<String>());
      }
      expect(per.length, 114);
      var present = 0;
      for (final s in allSurahs) {
        present += per[s.number]!.length;
        expect(per[s.number]!.every((a) => a >= 1 && a <= s.ayahCount), isTrue);
      }
      // Muyassar and Saadi are complete; Jalalayn has known gaps in the source.
      if (book.id == 'jalalayn') {
        expect(present, greaterThan(5900));
      } else {
        expect(present, 6236);
      }
      // First ayah of each surah is never an empty/"same as previous" entry.
      if (book.id == 'jalalayn') return; // source lacks ayah 1 of a few surahs
      for (final s in allSurahs) {
        final first = rows.firstWhere(
            (r) => (r as List)[0] == s.number && r[1] == 1) as List<dynamic>;
        expect((first[2] as String).isNotEmpty, isTrue, reason: '${book.id} ${s.number}:1');
      }
    });
  }
}
