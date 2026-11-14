/// Adhan recordings bundled inside the app (android/app/src/main/res/raw),
/// so they play at prayer time without any internet connection.
class AdhanVoice {
  final String id;
  final String nameAr;

  /// Android raw resource name (no extension).
  final String rawName;
  final bool isFajr;
  const AdhanVoice(this.id, this.nameAr, this.rawName, {this.isFajr = false});
}

const List<AdhanVoice> kAdhanVoices = [
  AdhanVoice('makkah', 'الحرم المكي', 'adhan_makkah'),
  AdhanVoice('madinah', 'الحرم المدني', 'adhan_madinah'),
  AdhanVoice('aqsa', 'المسجد الأقصى', 'adhan_aqsa'),
  AdhanVoice('afasy', 'مشاري العفاسي', 'adhan_afasy'),
  AdhanVoice('qatami', 'ناصر القطامي', 'adhan_qatami'),
  AdhanVoice('abdulbasit', 'عبدالباسط عبدالصمد (القاهرة)', 'adhan_abdulbasit'),
  AdhanVoice('hussary', 'محمود خليل الحصري (القاهرة)', 'adhan_hussary'),
];

const List<AdhanVoice> kFajrAdhanVoices = [
  AdhanVoice('fajr_makkah', 'أذان الفجر - الحرم المكي', 'adhan_fajr_makkah',
      isFajr: true),
  AdhanVoice('fajr_madinah', 'أذان الفجر - الحرم المدني', 'adhan_fajr_madinah',
      isFajr: true),
  AdhanVoice('fajr_cairo', 'أذان الفجر - القاهرة', 'adhan_fajr_cairo',
      isFajr: true),
];

const String kDefaultAdhanVoiceId = 'makkah';
const String kDefaultFajrVoiceId = 'fajr_makkah';

AdhanVoice adhanVoiceById(String id) {
  for (final v in [...kAdhanVoices, ...kFajrAdhanVoices]) {
    if (v.id == id) return v;
  }
  return kAdhanVoices.first;
}
