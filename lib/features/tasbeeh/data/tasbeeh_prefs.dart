import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbeehSnapshot {
  final String name;
  final String nameArabic;
  final int count;
  final int target;

  const TasbeehSnapshot({
    required this.name,
    required this.nameArabic,
    required this.count,
    required this.target,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'nameArabic': nameArabic,
        'count': count,
        'target': target,
      };

  factory TasbeehSnapshot.fromJson(Map<String, dynamic> j) => TasbeehSnapshot(
        name: j['name'] as String? ?? 'سبحان الله',
        nameArabic: j['nameArabic'] as String? ?? 'سُبْحَانَ ٱللَّهِ',
        count: j['count'] as int? ?? 0,
        target: j['target'] as int? ?? 33,
      );
}

class TasbeehPrefs {
  static const _key = 'tasbeeh_current';

  Future<TasbeehSnapshot?> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null) return null;
    try {
      return TasbeehSnapshot.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(TasbeehSnapshot s) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(s.toJson()));
  }
}

final tasbeehPrefsProvider = Provider<TasbeehPrefs>((ref) => TasbeehPrefs());
