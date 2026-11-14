import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline persistence for the last-read Mushaf page and page bookmarks.
class ReadingPrefs {
  static const _lastPageKey = 'quran_last_page';
  static const _bookmarksKey = 'quran_bookmarks';

  Future<int?> loadLastPage() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_lastPageKey);
  }

  Future<void> saveLastPage(int page) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_lastPageKey, page);
  }

  Future<List<int>> loadBookmarks() async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_bookmarksKey) ?? const <String>[];
    final pages = list.map(int.tryParse).whereType<int>().toSet().toList()
      ..sort();
    return pages;
  }

  Future<void> saveBookmarks(List<int> pages) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
        _bookmarksKey, pages.map((e) => e.toString()).toList());
  }
}

final readingPrefsProvider = Provider<ReadingPrefs>((ref) => ReadingPrefs());

class LastReadNotifier extends StateNotifier<int?> {
  LastReadNotifier(this._prefs) : super(null) {
    _load();
  }

  final ReadingPrefs _prefs;

  Future<void> _load() async {
    final page = await _prefs.loadLastPage();
    if (mounted && state == null) state = page;
  }

  void set(int page) {
    state = page;
    _prefs.saveLastPage(page);
  }
}

final lastReadPageProvider =
    StateNotifierProvider<LastReadNotifier, int?>((ref) {
  return LastReadNotifier(ref.watch(readingPrefsProvider));
});

class BookmarksNotifier extends StateNotifier<List<int>> {
  BookmarksNotifier(this._prefs) : super(const <int>[]) {
    _load();
  }

  final ReadingPrefs _prefs;

  Future<void> _load() async {
    final pages = await _prefs.loadBookmarks();
    if (mounted) state = pages;
  }

  /// Returns true if the page is bookmarked after the call.
  bool toggle(int page) {
    final next = List<int>.from(state);
    final added = !next.contains(page);
    if (added) {
      next.add(page);
    } else {
      next.remove(page);
    }
    next.sort();
    state = next;
    _prefs.saveBookmarks(next);
    return added;
  }
}

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, List<int>>((ref) {
  return BookmarksNotifier(ref.watch(readingPrefsProvider));
});
