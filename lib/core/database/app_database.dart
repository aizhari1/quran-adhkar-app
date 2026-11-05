import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ──────────────────────────────────────────────
// Quran Tables
// ──────────────────────────────────────────────

class Surahs extends Table {
  IntColumn get number => integer()(); // 1-114
  TextColumn get nameArabic => text()();
  TextColumn get nameEnglish => text()();
  TextColumn get nameTransliteration => text().nullable()();
  IntColumn get revelationType => integer()(); // 0=Meccan, 1=Medinan
  IntColumn get ayahCount => integer()();
  IntColumn get pageStart => integer()();
  IntColumn get rukuCount => integer().nullable()();

  @override
  Set<Column> get primaryKey => {number};
}

class Ayahs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahNumber => integer().references(Surahs, #number)();
  IntColumn get ayahNumber => integer()();
  TextColumn get textUthmani => text()();
  TextColumn get textImlaei => text().nullable()();
  IntColumn get pageNumber => integer()();
  IntColumn get juzNumber => integer()();
  IntColumn get hizbNumber => integer()();
  IntColumn get rukuNumber => integer().nullable()();
  BoolColumn get isSajdah => boolean().withDefault(const Constant(false))();
  IntColumn get sajdahType => integer().nullable()(); // 1=recommended, 2=obligatory
  IntColumn get riwayahId => integer().withDefault(const Constant(1))(); // default Hafs
}

class Juzs extends Table {
  IntColumn get number => integer()(); // 1-30
  IntColumn get startSurah => integer()();
  IntColumn get startAyah => integer()();
  IntColumn get endSurah => integer()();
  IntColumn get endAyah => integer()();

  @override
  Set<Column> get primaryKey => {number};
}

class Hizbs extends Table {
  IntColumn get number => integer()(); // 1-60
  IntColumn get startSurah => integer()();
  IntColumn get startAyah => integer()();
  IntColumn get endSurah => integer()();
  IntColumn get endAyah => integer()();

  @override
  Set<Column> get primaryKey => {number};
}

class QuranPages extends Table {
  IntColumn get pageNumber => integer()(); // 1-604 (standard Madani)
  IntColumn get startSurah => integer()();
  IntColumn get startAyah => integer()();
  IntColumn get endSurah => integer()();
  IntColumn get endAyah => integer()();

  @override
  Set<Column> get primaryKey => {pageNumber};
}

class Riwayat extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // Hafs, Warsh, Qalun...
  TextColumn get nameArabic => text()();
  TextColumn get narrator => text().nullable()();
  TextColumn get sourceNote => text().nullable()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
}

class Translations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get languageCode => text()(); // en, fr, tr, id, ur, bn, ms
  TextColumn get translatorName => text()();
  TextColumn get name => text()();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
}

class TranslationTexts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get translationId => integer().references(Translations, #id)();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  TextColumn get text => text()();
}

class Tafsirs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get author => text()();
  TextColumn get languageCode => text()();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
}

class TafsirTexts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tafsirId => integer().references(Tafsirs, #id)();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  TextColumn get text => text()();
}

// ──────────────────────────────────────────────
// Adhkar Tables
// ──────────────────────────────────────────────

class AdhkarCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nameKey => text()(); // morning, evening, after_prayer...
  TextColumn get nameArabic => text()();
  TextColumn get nameEnglish => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class AdhkarItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(AdhkarCategories, #id)();
  TextColumn get textArabic => text()();
  IntColumn get repetitionCount => integer().withDefault(const Constant(1))();
  TextColumn get source => text().nullable()(); // Bukhari, Muslim, etc.
  TextColumn get virtue => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class AdhkarTranslations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get adhkarItemId => integer().references(AdhkarItems, #id)();
  TextColumn get languageCode => text()();
  TextColumn get text => text()();
}

class AdhkarProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get adhkarItemId => integer().references(AdhkarItems, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get completedCount => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

class AdhkarFavorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get adhkarItemId => integer().references(AdhkarItems, #id)();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
}

// ──────────────────────────────────────────────
// User Progress / Khatma / Bookmarks
// ──────────────────────────────────────────────

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  IntColumn get pageNumber => integer().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ReadingPositions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mode => text()(); // mushaf, continuous, widget
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  IntColumn get pageNumber => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Khatmas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get totalDays => integer()(); // 7, 15, 30, 60, custom
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get targetEndDate => dateTime()();
  IntColumn get currentPage => integer().withDefault(const Constant(1))();
  IntColumn get completedPages => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class KhatmaDailyLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get khatmaId => integer().references(Khatmas, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get pagesRead => integer().withDefault(const Constant(0))();
  IntColumn get startPage => integer().nullable()();
  IntColumn get endPage => integer().nullable()();
}

class TasbeehCounters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // SubhanAllah, custom...
  TextColumn get nameArabic => text().nullable()();
  IntColumn get count => integer().withDefault(const Constant(0))();
  IntColumn get target => integer().withDefault(const Constant(33))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
}

class TasbeehHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get counterId => integer().references(TasbeehCounters, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get totalCount => integer()();
}

class UserSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get languageCode => text().withDefault(const Constant('ar'))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))(); // light, dark, system
  RealColumn get quranFontSize => real().withDefault(const Constant(24.0))();
  TextColumn get quranFontFamily => text().withDefault(const Constant('ScheherazadeNew'))();
  BoolColumn get nightReadingMode => boolean().withDefault(const Constant(false))();
  TextColumn get calculationMethod => text().withDefault(const Constant('MuslimWorldLeague'))();
  TextColumn get asrMethod => text().withDefault(const Constant('Standard'))();
  TextColumn get cityName => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get morningAdhkarEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get eveningAdhkarEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get widgetAutoProgress => boolean().withDefault(const Constant(true))();
  IntColumn get selectedRiwayahId => integer().withDefault(const Constant(1))();
  IntColumn get selectedTranslationId => integer().nullable()();
  IntColumn get selectedTafsirId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Reciters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nameArabic => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get biography => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

class ReciterRiwayat extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reciterId => integer().references(Reciters, #id)();
  IntColumn get riwayahId => integer().references(Riwayat, #id)();
  TextColumn get baseUrl => text().nullable()(); // for audio streams / downloads
  BoolColumn get isAvailable => boolean().withDefault(const Constant(false))();
}

class DownloadedAudios extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reciterId => integer()();
  IntColumn get riwayahId => integer()();
  IntColumn get surahNumber => integer()();
  TextColumn get localPath => text()();
  IntColumn get fileSizeBytes => integer().nullable()();
  DateTimeColumn get downloadedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  Surahs,
  Ayahs,
  Juzs,
  Hizbs,
  QuranPages,
  Riwayat,
  Translations,
  TranslationTexts,
  Tafsirs,
  TafsirTexts,
  AdhkarCategories,
  AdhkarItems,
  AdhkarTranslations,
  AdhkarProgress,
  AdhkarFavorites,
  Bookmarks,
  ReadingPositions,
  Khatmas,
  KhatmaDailyLogs,
  TasbeehCounters,
  TasbeehHistory,
  UserSettings,
  Reciters,
  ReciterRiwayat,
  DownloadedAudios,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Seed default settings row
        await into(userSettings).insert(UserSettingsCompanion.insert());
        // Seed basic Riwayat
        await into(riwayat).insert(RiwayatCompanion.insert(
          name: 'Hafs an Asim',
          nameArabic: 'حفص عن عاصم',
          narrator: 'Hafs ibn Sulayman',
        ));
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'quran_adhkar.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
