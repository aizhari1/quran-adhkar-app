import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../main.dart';

/// Requires `dart run build_runner build` for full Drift API.
class KhatmaRepository {
  KhatmaRepository(this._db);
  final AppDatabase _db;

  // create / updateProgress / delete after codegen
}

final khatmaRepositoryProvider = Provider<KhatmaRepository>((ref) {
  return KhatmaRepository(ref.watch(databaseProvider));
});
