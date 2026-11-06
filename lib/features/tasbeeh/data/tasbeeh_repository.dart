import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';

class TasbeehRepository {
  TasbeehRepository(this._db);
  final AppDatabase _db;
}

final tasbeehRepositoryProvider = Provider<TasbeehRepository>((ref) {
  return TasbeehRepository(ref.watch(databaseProvider));
});
