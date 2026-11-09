import '../quran/data/surah_metadata.dart';

class Reciter {
  /// Edition identifier on the Islamic Network CDN (e.g. ar.alafasy).
  final String id;
  final String nameAr;
  const Reciter(this.id, this.nameAr);
}

/// Verse-by-verse (ayah-level) Arabic editions listed by the official
/// Al Quran Cloud audio-editions API (api.alquran.cloud/v1/edition/format/audio).
const List<Reciter> kReciters = [
  Reciter('ar.alafasy', 'مشاري العفاسي'),
  Reciter('ar.abdurrahmaansudais', 'عبدالرحمن السديس'),
  Reciter('ar.saoodshuraym', 'سعود الشريم'),
  Reciter('ar.mahermuaiqly', 'ماهر المعيقلي'),
  Reciter('ar.abdulsamad', 'عبدالباسط عبدالصمد'),
  Reciter('ar.husary', 'محمود خليل الحصري'),
  Reciter('ar.husarymujawwad', 'الحصري (المجوّد)'),
  Reciter('ar.hudhaify', 'علي الحذيفي'),
  Reciter('ar.shaatree', 'أبو بكر الشاطري'),
  Reciter('ar.hanirifai', 'هاني الرفاعي'),
  Reciter('ar.muhammadayyoub', 'محمد أيوب'),
  Reciter('ar.muhammadjibreel', 'محمد جبريل'),
  Reciter('ar.ahmedajamy', 'أحمد العجمي'),
  Reciter('ar.ibrahimakhbar', 'إبراهيم الأخضر'),
  Reciter('ar.abdullahbasfar', 'عبدالله بصفر'),
  Reciter('ar.aymanswoaid', 'أيمن سويد'),
];

const String kDefaultReciterId = 'ar.alafasy';

/// Bitrates documented by the CDN, tried in order until one exists.
const List<int> kBitrates = [128, 64, 192, 48, 40, 32];

/// Global ayah number 1..6236 (surah 1 ayah 1 = 1, surah 2 ayah 255 = 262).
int globalAyahNumber(int surah, int ayah) {
  var n = 0;
  for (var i = 0; i < surah - 1; i++) {
    n += allSurahs[i].ayahCount;
  }
  return n + ayah;
}

/// Documented format: https://cdn.islamic.network/quran/audio/{bitrate}/{edition}/{number}.mp3
String ayahAudioUrl(int bitrate, String reciterId, int surah, int ayah) {
  return 'https://cdn.islamic.network/quran/audio/$bitrate/$reciterId/${globalAyahNumber(surah, ayah)}.mp3';
}

/// Adhkar audio files live in the same repository as the text.
List<String> adhkarAudioUrls(String file) => [
      'https://cdn.jsdelivr.net/gh/rn0x/Adhkar-json@main/audio/$file',
      'https://raw.githubusercontent.com/rn0x/Adhkar-json/main/audio/$file',
    ];
