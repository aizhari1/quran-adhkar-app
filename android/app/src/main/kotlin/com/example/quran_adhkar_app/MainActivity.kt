package com.example.quran_adhkar_app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.media.MediaPlayer
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var previewPlayer: MediaPlayer? = null

    private fun stopPreview() {
        previewPlayer?.let {
            try { it.stop() } catch (e: Exception) { }
            it.release()
        }
        previewPlayer = null
    }

    private fun playPreview(name: String): Boolean {
        stopPreview()
        val id = resources.getIdentifier(name, "raw", packageName)
        if (id == 0) return false
        val mp = MediaPlayer.create(this, id) ?: return false
        mp.setOnCompletionListener { stopPreview() }
        previewPlayer = mp
        mp.start()
        return true
    }

    override fun onDestroy() {
        stopPreview()
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "quran_adhkar/audio")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "preview" -> result.success(playPreview(call.arguments as? String ?: ""))
                    "stopPreview" -> { stopPreview(); result.success(null) }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "quran_adhkar/widgets")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "refresh" -> {
                        refreshWidgets()
                        result.success(null)
                    }
                    "pin" -> result.success(pinWidget(call.arguments as? String ?: ""))
                    else -> result.notImplemented()
                }
            }
    }

    /** Asks the launcher to add a widget to the home screen (Android 8+). */
    private fun pinWidget(kind: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        val cls = when (kind) {
            "verse" -> VerseWidgetProvider::class.java
            "dhikr" -> DhikrWidgetProvider::class.java
            "prayer" -> PrayerWidgetProvider::class.java
            else -> return false
        }
        val mgr = AppWidgetManager.getInstance(this)
        if (!mgr.isRequestPinAppWidgetSupported) return false
        return mgr.requestPinAppWidget(ComponentName(this, cls), null, null)
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
