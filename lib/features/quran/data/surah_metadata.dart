/// Public Surah metadata (not Quran verse text).
class SurahMeta {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameTransliteration;
  final int ayahCount;
  final String revelationType;
  final int pageStart;
  const SurahMeta({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTransliteration,
    required this.ayahCount,
    required this.revelationType,
    required this.pageStart,
  });
}

const List<SurahMeta> allSurahs = [
  SurahMeta(number: 1, nameArabic: 'الفاتحة', nameEnglish: 'The Opening', nameTransliteration: 'Al-Fatihah', ayahCount: 7, revelationType: 'Meccan', pageStart: 1),
  SurahMeta(number: 2, nameArabic: 'البقرة', nameEnglish: 'The Cow', nameTransliteration: 'Al-Baqarah', ayahCount: 286, revelationType: 'Medinan', pageStart: 2),
  SurahMeta(number: 3, nameArabic: 'آل عمران', nameEnglish: 'Family of Imran', nameTransliteration: 'Ali Imran', ayahCount: 200, revelationType: 'Medinan', pageStart: 50),
  SurahMeta(number: 4, nameArabic: 'النساء', nameEnglish: 'The Women', nameTransliteration: 'An-Nisa', ayahCount: 176, revelationType: 'Medinan', pageStart: 77),
  SurahMeta(number: 5, nameArabic: 'المائدة', nameEnglish: 'The Table', nameTransliteration: 'Al-Maidah', ayahCount: 120, revelationType: 'Medinan', pageStart: 106),
  SurahMeta(number: 6, nameArabic: 'الأنعام', nameEnglish: 'The Cattle', nameTransliteration: 'Al-Anam', ayahCount: 165, revelationType: 'Meccan', pageStart: 128),
  SurahMeta(number: 7, nameArabic: 'الأعراف', nameEnglish: 'The Heights', nameTransliteration: 'Al-Araf', ayahCount: 206, revelationType: 'Meccan', pageStart: 151),
  SurahMeta(number: 8, nameArabic: 'الأنفال', nameEnglish: 'The Spoils', nameTransliteration: 'Al-Anfal', ayahCount: 75, revelationType: 'Medinan', pageStart: 177),
  SurahMeta(number: 9, nameArabic: 'التوبة', nameEnglish: 'Repentance', nameTransliteration: 'At-Tawbah', ayahCount: 129, revelationType: 'Medinan', pageStart: 187),
  SurahMeta(number: 10, nameArabic: 'يونس', nameEnglish: 'Jonah', nameTransliteration: 'Yunus', ayahCount: 109, revelationType: 'Meccan', pageStart: 208),
  SurahMeta(number: 11, nameArabic: 'هود', nameEnglish: 'Hud', nameTransliteration: 'Hud', ayahCount: 123, revelationType: 'Meccan', pageStart: 221),
  SurahMeta(number: 12, nameArabic: 'يوسف', nameEnglish: 'Joseph', nameTransliteration: 'Yusuf', ayahCount: 111, revelationType: 'Meccan', pageStart: 235),
  SurahMeta(number: 13, nameArabic: 'الرعد', nameEnglish: 'Thunder', nameTransliteration: 'Ar-Rad', ayahCount: 43, revelationType: 'Medinan', pageStart: 249),
  SurahMeta(number: 14, nameArabic: 'إبراهيم', nameEnglish: 'Abraham', nameTransliteration: 'Ibrahim', ayahCount: 52, revelationType: 'Meccan', pageStart: 255),
  SurahMeta(number: 15, nameArabic: 'الحجر', nameEnglish: 'The Rock', nameTransliteration: 'Al-Hijr', ayahCount: 99, revelationType: 'Meccan', pageStart: 262),
  SurahMeta(number: 16, nameArabic: 'النحل', nameEnglish: 'The Bee', nameTransliteration: 'An-Nahl', ayahCount: 128, revelationType: 'Meccan', pageStart: 267),
  SurahMeta(number: 17, nameArabic: 'الإسراء', nameEnglish: 'Night Journey', nameTransliteration: 'Al-Isra', ayahCount: 111, revelationType: 'Meccan', pageStart: 282),
  SurahMeta(number: 18, nameArabic: 'الكهف', nameEnglish: 'The Cave', nameTransliteration: 'Al-Kahf', ayahCount: 110, revelationType: 'Meccan', pageStart: 293),
  SurahMeta(number: 19, nameArabic: 'مريم', nameEnglish: 'Mary', nameTransliteration: 'Maryam', ayahCount: 98, revelationType: 'Meccan', pageStart: 305),
  SurahMeta(number: 20, nameArabic: 'طه', nameEnglish: 'Ta-Ha', nameTransliteration: 'Ta-Ha', ayahCount: 135, revelationType: 'Meccan', pageStart: 312),
  SurahMeta(number: 21, nameArabic: 'الأنبياء', nameEnglish: 'The Prophets', nameTransliteration: 'Al-Anbiya', ayahCount: 112, revelationType: 'Meccan', pageStart: 322),
  SurahMeta(number: 22, nameArabic: 'الحج', nameEnglish: 'Pilgrimage', nameTransliteration: 'Al-Hajj', ayahCount: 78, revelationType: 'Medinan', pageStart: 332),
  SurahMeta(number: 23, nameArabic: 'المؤمنون', nameEnglish: 'Believers', nameTransliteration: 'Al-Muminun', ayahCount: 118, revelationType: 'Meccan', pageStart: 342),
  SurahMeta(number: 24, nameArabic: 'النور', nameEnglish: 'The Light', nameTransliteration: 'An-Nur', ayahCount: 64, revelationType: 'Medinan', pageStart: 350),
  SurahMeta(number: 25, nameArabic: 'الفرقان', nameEnglish: 'Criterion', nameTransliteration: 'Al-Furqan', ayahCount: 77, revelationType: 'Meccan', pageStart: 359),
  SurahMeta(number: 26, nameArabic: 'الشعراء', nameEnglish: 'The Poets', nameTransliteration: 'Ash-Shuara', ayahCount: 227, revelationType: 'Meccan', pageStart: 367),
  SurahMeta(number: 27, nameArabic: 'النمل', nameEnglish: 'The Ant', nameTransliteration: 'An-Naml', ayahCount: 93, revelationType: 'Meccan', pageStart: 377),
  SurahMeta(number: 28, nameArabic: 'القصص', nameEnglish: 'The Stories', nameTransliteration: 'Al-Qasas', ayahCount: 88, revelationType: 'Meccan', pageStart: 385),
  SurahMeta(number: 29, nameArabic: 'العنكبوت', nameEnglish: 'The Spider', nameTransliteration: 'Al-Ankabut', ayahCount: 69, revelationType: 'Meccan', pageStart: 396),
  SurahMeta(number: 30, nameArabic: 'الروم', nameEnglish: 'The Romans', nameTransliteration: 'Ar-Rum', ayahCount: 60, revelationType: 'Meccan', pageStart: 404),
  SurahMeta(number: 36, nameArabic: 'يس', nameEnglish: 'Ya-Sin', nameTransliteration: 'Ya-Sin', ayahCount: 83, revelationType: 'Meccan', pageStart: 440),
  SurahMeta(number: 55, nameArabic: 'الرحمن', nameEnglish: 'The Beneficent', nameTransliteration: 'Ar-Rahman', ayahCount: 78, revelationType: 'Medinan', pageStart: 531),
  SurahMeta(number: 67, nameArabic: 'الملك', nameEnglish: 'Sovereignty', nameTransliteration: 'Al-Mulk', ayahCount: 30, revelationType: 'Meccan', pageStart: 562),
  SurahMeta(number: 112, nameArabic: 'الإخلاص', nameEnglish: 'Sincerity', nameTransliteration: 'Al-Ikhlas', ayahCount: 4, revelationType: 'Meccan', pageStart: 604),
  SurahMeta(number: 113, nameArabic: 'الفلق', nameEnglish: 'Daybreak', nameTransliteration: 'Al-Falaq', ayahCount: 5, revelationType: 'Meccan', pageStart: 604),
  SurahMeta(number: 114, nameArabic: 'الناس', nameEnglish: 'Mankind', nameTransliteration: 'An-Nas', ayahCount: 6, revelationType: 'Meccan', pageStart: 604),
];
