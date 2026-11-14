import 'package:flutter_test/flutter_test.dart';
import 'package:quran_adhkar_app/features/audio/audio_sources.dart';

void main() {
  test('global ayah numbers match the CDN numbering', () {
    expect(globalAyahNumber(1, 1), 1);
    expect(globalAyahNumber(2, 1), 8);
    // The CDN documentation's example: ayah 262 = Ayat al-Kursi (2:255).
    expect(globalAyahNumber(2, 255), 262);
    expect(globalAyahNumber(114, 6), 6236);
  });

  test('ayah audio URL follows the documented CDN format', () {
    expect(
      ayahAudioUrl(128, 'ar.alafasy', 2, 255),
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/262.mp3',
    );
  });

  test('reciter ids are unique', () {
    final ids = kReciters.map((r) => r.id).toSet();
    expect(ids.length, kReciters.length);
    expect(ids.contains(kDefaultReciterId), isTrue);
  });
}
