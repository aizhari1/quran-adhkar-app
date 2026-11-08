package com.example.quran_adhkar_app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "quran_adhkar/widgets")
            .setMethodCallHandler { call, result ->
                if (call.method == "refresh") {
                    refreshWidgets()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun refreshWidgets() {
        val mgr = AppWidgetManager.getInstance(this)
        val providers = listOf(
            VerseWidgetProvider::class.java,
            DhikrWidgetProvider::class.java,
            PrayerWidgetProvider::class.java
        )
        for (cls in providers) {
            val ids = mgr.getAppWidgetIds(ComponentName(this, cls))
            if (ids.isNotEmpty()) {
                val intent = Intent(this, cls)
                    .setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
                    .putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                sendBroadcast(intent)
            }
        }
    }
}
