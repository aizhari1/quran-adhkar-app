import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight database façade until Drift codegen is run.
class AppDatabase {
  Future<void> close() async {}
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
