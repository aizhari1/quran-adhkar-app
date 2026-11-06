import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KhatmaPrefs {
  static const _key = 'khatma_plans';

  Future<List<Map<String, dynamic>>> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Map<String, dynamic>> plans) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(plans));
  }
}

final khatmaPrefsProvider = Provider<KhatmaPrefs>((ref) => KhatmaPrefs());
