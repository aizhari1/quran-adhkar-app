import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../main.dart';

/// Requires `dart run build_runner build` so Drift generates companions.
class TasbeehRepository {
  TasbeehRepository(this._db);
  final AppDatabase _db;

  Future<List<dynamic>> getAll() {
    return _db.select(_db.tasbeehCounters).get();
  }

  // Full upsert/reset after codegen – see DEVELOPMENT_STATUS
}

final tasbeehRepositoryProvider = Provider<TasbeehRepository>((ref) {
  return TasbeehRepository(ref.watch(databaseProvider));
});
