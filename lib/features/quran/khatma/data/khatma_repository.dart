import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';

class KhatmaRepository {
  KhatmaRepository(this._db);
  final AppDatabase _db;
}

final khatmaRepositoryProvider = Provider<KhatmaRepository>((ref) {
  return KhatmaRepository(ref.watch(databaseProvider));
});
