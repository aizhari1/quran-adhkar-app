import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_adhkar_app/features/prayer_times/data/adhan_voices.dart';

void main() {
  final all = [...kAdhanVoices, ...kFajrAdhanVoices];

  test('voice ids and raw names are unique and valid Android resource names', () {
    expect(all.map((v) => v.id).toSet().length, all.length);
    expect(all.map((v) => v.rawName).toSet().length, all.length);
    for (final v in all) {
      expect(RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(v.rawName), isTrue,
          reason: v.rawName);
    }
  });

  test('every bundled voice has its audio file in res/raw', () {
    for (final v in all) {
      final f = File('android/app/src/main/res/raw/${v.rawName}.mp3');
      expect(f.existsSync(), isTrue, reason: '${v.rawName}.mp3 missing');
      expect(f.lengthSync(), greaterThan(100000), reason: v.rawName);
    }
    for (final name in ['salawat_voice', 'tasbeeh_voice']) {
      expect(File('android/app/src/main/res/raw/$name.mp3').existsSync(), isTrue);
    }
  });

  test('defaults exist and fajr voices are flagged', () {
    expect(adhanVoiceById(kDefaultAdhanVoiceId).id, kDefaultAdhanVoiceId);
    expect(adhanVoiceById(kDefaultFajrVoiceId).isFajr, isTrue);
    expect(adhanVoiceById('unknown').id, kAdhanVoices.first.id);
  });
}
