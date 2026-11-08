package com.example.quran_adhkar_app

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import org.json.JSONObject
import java.util.Calendar

/** Reads the app's bundled Flutter assets so widgets work fully offline. */
object WidgetData {
    private const val QURAN_ASSET = "flutter_assets/assets/quran/quran-uthmani.json"
    private const val ADHKAR_ASSET = "flutter_assets/assets/adhkar/hisn-al-muslim.json"

    private val SURAH_NAMES = arrayOf(
        "الفاتحة",
        "البقرة",
        "آل عمران",
        "النساء",
        "المائدة",
        "الأنعام",
        "الأعراف",
        "الأنفال",
        "التوبة",
        "يونس",
        "هود",
        "يوسف",
        "الرعد",
        "إبراهيم",
        "الحجر",
        "النحل",
        "الإسراء",
        "الكهف",
        "مريم",
        "طه",
        "الأنبياء",
        "الحج",
        "المؤمنون",
        "النور",
        "الفرقان",
        "الشعراء",
        "النمل",
        "القصص",
        "العنكبوت",
        "الروم",
        "لقمان",
        "السجدة",
        "الأحزاب",
        "سبأ",
        "فاطر",
        "يس",
        "الصافات",
        "ص",
        "الزمر",
        "غافر",
        "فصلت",
        "الشورى",
        "الزخرف",
        "الدخان",
        "الجاثية",
        "الأحقاف",
        "محمد",
        "الفتح",
        "الحجرات",
        "ق",
        "الذاريات",
        "الطور",
        "النجم",
        "القمر",
        "الرحمن",
        "الواقعة",
        "الحديد",
        "المجادلة",
        "الحشر",
        "الممتحنة",
        "الصف",
        "الجمعة",
        "المنافقون",
        "التغابن",
        "الطلاق",
        "التحريم",
        "الملك",
        "القلم",
        "الحاقة",
        "المعارج",
        "نوح",
        "الجن",
        "المزمل",
        "المدثر",
        "القيامة",
        "الإنسان",
        "المرسلات",
        "النبأ",
        "النازعات",
        "عبس",
        "التكوير",
        "الانفطار",
        "المطففين",
        "الانشقاق",
        "البروج",
        "الطارق",
        "الأعلى",
        "الغاشية",
        "الفجر",
        "البلد",
        "الشمس",
        "الليل",
        "الضحى",
        "الشرح",
        "التين",
        "العلق",
        "القدر",
        "البينة",
        "الزلزلة",
        "العاديات",
        "القارعة",
        "التكاثر",
        "العصر",
        "الهمزة",
        "الفيل",
        "قريش",
        "الماعون",
        "الكوثر",
        "الكافرون",
        "النصر",
        "المسد",
        "الإخلاص",
        "الفلق",
        "الناس")

    private const val DIGITS = "٠١٢٣٤٥٦٧٨٩"

    fun arabicDigits(s: String): String {
        val b = StringBuilder()
        for (c in s) b.append(if (c in '0'..'9') DIGITS[c - '0'] else c)
        return b.toString()
    }

    fun dayKey(): Int {
        val c = Calendar.getInstance()
        return c.get(Calendar.YEAR) * 1000 + c.get(Calendar.DAY_OF_YEAR)
    }

    fun dateString(c: Calendar): String =
        "%04d-%02d-%02d".format(c.get(Calendar.YEAR), c.get(Calendar.MONTH) + 1, c.get(Calendar.DAY_OF_MONTH))

    private fun readAsset(ctx: Context, path: String): String =
        ctx.assets.open(path).bufferedReader(Charsets.UTF_8).use { it.readText() }

    /** Returns (verse text, "سورة X • آية N"). Changes once per day. */
    fun verseOfTheDay(ctx: Context): Pair<String, String> {
        return try {
            val ayahs = JSONObject(readAsset(ctx, QURAN_ASSET)).getJSONArray("ayahs")
            val n = ayahs.length()
            val start = ((dayKey().toLong() * 2654435761L) % n).toInt()
            for (i in 0 until n) {
                val row = ayahs.getJSONArray((start + i) % n)
                val text = row.getString(5)
                if (text.length in 25..170) {
                    val surah = row.getInt(0)
                    val footer = "سورة " + SURAH_NAMES[surah - 1] + " • آية " + arabicDigits(row.getInt(1).toString())
                    return Pair(text + " \uFD3F" + arabicDigits(row.getInt(1).toString()) + "\uFD3E", footer)
                }
            }
            Pair("", "")
        } catch (e: Exception) {
            Pair("افتح التطبيق لعرض آية اليوم", "")
        }
    }

    /** Returns (dhikr text, chapter title). Changes once per day. */
    fun dhikrOfTheDay(ctx: Context): Pair<String, String> {
        return try {
            val cats = JSONObject(readAsset(ctx, ADHKAR_ASSET)).getJSONArray("categories")
            val texts = ArrayList<String>()
            val titles = ArrayList<String>()
            for (i in 0 until cats.length()) {
                val c = cats.getJSONObject(i)
                val items = c.getJSONArray("items")
                for (j in 0 until items.length()) {
                    val t = items.getJSONObject(j).getString("text")
                    if (t.length in 15..170) {
                        texts.add(t)
                        titles.add(c.getString("title"))
                    }
                }
            }
            if (texts.isEmpty()) return Pair("", "")
            val idx = ((dayKey().toLong() * 40503L + 17L) % texts.size).toInt()
            Pair(texts[idx], titles[idx])
        } catch (e: Exception) {
            Pair("افتح التطبيق لعرض ذكر اليوم", "")
        }
    }

    fun openAppIntent(ctx: Context): PendingIntent {
        val i = Intent(ctx, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        return PendingIntent.getActivity(
            ctx, 0, i, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}
