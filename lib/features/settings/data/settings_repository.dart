import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../presentation/settings_screen.dart';
import 'settings_prefs.dart';

class SettingsRepository {
  SettingsRepository(this._db, this._prefs);
  final AppDatabase _db;
  final SettingsPrefs _prefs;

  Future<AppSettingsState> load() => _prefs.load();
  Future<void> save(AppSettingsState s) => _prefs.save(s);
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    ref.watch(databaseProvider),
    ref.watch(settingsPrefsProvider),
  );
});
