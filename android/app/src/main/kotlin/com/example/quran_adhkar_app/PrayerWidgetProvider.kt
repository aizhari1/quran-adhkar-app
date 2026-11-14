package com.example.quran_adhkar_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import org.json.JSONObject
import java.util.Calendar

/**
 * Shows the next prayer. Flutter computes 7 days of times (adhan) and stores
 * them in SharedPreferences ("flutter.widget_prayer_json"); this provider only
 * reads them, so it keeps working offline and without the app running.
 */
class PrayerWidgetProvider : AppWidgetProvider() {
    private val names = arrayOf("الفجر", "الظهر", "العصر", "المغرب", "العشاء")
    private val nameIds = intArrayOf(R.id.p0_name, R.id.p1_name, R.id.p2_name, R.id.p3_name, R.id.p4_name)
    private val timeIds = intArrayOf(R.id.p0_time, R.id.p1_time, R.id.p2_time, R.id.p3_time, R.id.p4_time)

    private fun fmt(ms: Long): String {
        val c = Calendar.getInstance().apply { timeInMillis = ms }
        val h24 = c.get(Calendar.HOUR_OF_DAY)
        val h = if (h24 % 12 == 0) 12 else h24 % 12
        val m = c.get(Calendar.MINUTE)
        return WidgetData.arabicDigits("%d:%02d %s".format(h, m, if (h24 < 12) "ص" else "م"))
    }

    private fun times(days: JSONObject, c: Calendar): LongArray? {
        val arr = days.optJSONArray(WidgetData.dateString(c)) ?: return null
        if (arr.length() < 5) return null
        return LongArray(5) { arr.getLong(it) }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val json = prefs.getString("flutter.widget_prayer_json", null)

        var city = ""
        var today: LongArray? = null
        var tomorrow: LongArray? = null
        try {
            if (json != null) {
                val root = JSONObject(json)
                city = root.optString("city", "")
                val days = root.getJSONObject("days")
                val now = Calendar.getInstance()
                today = times(days, now)
                val next = Calendar.getInstance().apply { add(Calendar.DAY_OF_MONTH, 1) }
                tomorrow = times(days, next)
            }
        } catch (e: Exception) {
            today = null
        }

        val nowMs = System.currentTimeMillis()
        var nextIdx = -1
        var nextMs = 0L
        if (today != null) {
            for (i in 0 until 5) {
                if (today[i] > nowMs) { nextIdx = i; nextMs = today[i]; break }
            }
            if (nextIdx == -1 && tomorrow != null) { nextIdx = 0; nextMs = tomorrow[0] }
        }

        for (id in appWidgetIds) {
            val v = RemoteViews(context.packageName, R.layout.widget_prayer)
            v.setOnClickPendingIntent(R.id.widget_root, WidgetData.openAppIntent(context))
            if (today == null || nextIdx == -1) {
                v.setTextViewText(R.id.next_name, "افتح التطبيق")
                v.setTextViewText(R.id.next_time, "لتحديث المواقيت")
                v.setTextViewText(R.id.widget_city, "")
                for (i in 0 until 5) {
                    v.setTextViewText(nameIds[i], names[i])
                    v.setTextViewText(timeIds[i], "--")
                }
            } else {
                v.setTextViewText(R.id.next_name, names[nextIdx])
                v.setTextViewText(R.id.next_time, fmt(nextMs))
                v.setTextViewText(R.id.widget_city, city)
                for (i in 0 until 5) {
                    v.setTextViewText(nameIds[i], names[i])
                    v.setTextViewText(timeIds[i], fmt(today[i]))
                    val highlight = if (i == nextIdx) Color.parseColor("#FFE3C58B") else Color.parseColor("#FFF3F9F6")
                    v.setTextColor(nameIds[i], highlight)
                    v.setTextColor(timeIds[i], highlight)
                }
            }
            appWidgetManager.updateAppWidget(id, v)
        }

        if (nextIdx != -1) scheduleRefresh(context, nextMs + 2000)
    }

    /** Refresh right after the next prayer time so "next" moves on promptly. */
    private fun scheduleRefresh(ctx: Context, atMs: Long) {
        try {
            val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val ids = AppWidgetManager.getInstance(ctx)
                .getAppWidgetIds(ComponentName(ctx, PrayerWidgetProvider::class.java))
            val intent = Intent(ctx, PrayerWidgetProvider::class.java)
                .setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
                .putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            val pi = PendingIntent.getBroadcast(
                ctx, 7, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            am.set(AlarmManager.RTC, atMs, pi)
        } catch (e: Exception) {
            // Widget still refreshes on the system's periodic update.
        }
    }
}
