import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists Adhkar progress for the current day only.
/// Progress saved on a previous day is discarded so each day starts fresh.
class AdhkarPrefs {
  static const _countsKey = 'adhkar_counts';
  static const _completedKey = 'adhkar_completed';
  static const _dateKey = 'adhkar_date';

  String _today() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '${n.year}-$m-$d';
  }

  Future<bool> _isStale(SharedPreferences p) async {
    if (p.getString(_dateKey) == _today()) return false;
    await p.remove(_countsKey);
    await p.remove(_completedKey);
    await p.setString(_dateKey, _today());
    return true;
  }

  Future<Map<String, int>> loadCounts() async {
    final p = await SharedPreferences.getInstance();
    if (await _isStale(p)) return {};
    final raw = p.getString(_countsKey);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }

  Future<Set<String>> loadCompleted() async {
    final p = await SharedPreferences.getInstance();
    if (await _isStale(p)) return {};
    final list = p.getStringList(_completedKey);
    if (list == null) return {};
    return list.toSet();
  }

  Future<void> saveCounts(Map<String, int> counts) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_dateKey, _today());
    final map = Map<String, int>.from(counts);
    await p.setString(_countsKey, jsonEncode(map));
  }

  Future<void> saveCompleted(Set<String> completed) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_dateKey, _today());
    await p.setStringList(_completedKey, completed.toList());
  }
}

final adhkarPrefsProvider = Provider<AdhkarPrefs>((ref) => AdhkarPrefs());
