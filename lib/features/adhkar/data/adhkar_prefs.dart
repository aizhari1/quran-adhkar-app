import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdhkarPrefs {
  static const _countsKey = 'adhkar_counts';
  static const _completedKey = 'adhkar_completed';

  Future<Map<int, int>> loadCounts() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_countsKey);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(int.parse(k), v as int));
    } catch (_) {
      return {};
    }
  }

  Future<Set<int>> loadCompleted() async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_completedKey);
    if (list == null) return {};
    return list.map(int.parse).toSet();
  }

  Future<void> saveCounts(Map<int, int> counts) async {
    final p = await SharedPreferences.getInstance();
    final map = counts.map((k, v) => MapEntry(k.toString(), v));
    await p.setString(_countsKey, jsonEncode(map));
  }

  Future<void> saveCompleted(Set<int> completed) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
        _completedKey, completed.map((e) => e.toString()).toList());
  }
}

final adhkarPrefsProvider = Provider<AdhkarPrefs>((ref) => AdhkarPrefs());
