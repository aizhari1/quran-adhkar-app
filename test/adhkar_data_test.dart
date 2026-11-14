import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Hisn al-Muslim asset has 132 chapters and 267 adhkar', () async {
    final raw = await rootBundle.loadString('assets/adhkar/hisn-al-muslim.json');
    final cats = (jsonDecode(raw) as Map<String, dynamic>)['categories']
        as List<dynamic>;
    expect(cats.length, 132);
    var total = 0;
    for (final c in cats) {
      final items = (c as Map<String, dynamic>)['items'] as List<dynamic>;
      expect(items, isNotEmpty);
      for (final i in items) {
        final m = i as Map<String, dynamic>;
        expect((m['text'] as String).trim(), isNotEmpty);
        expect(m['count'] as int, greaterThanOrEqualTo(1));
      }
      total += items.length;
    }
    expect(total, 267);
  });
}
