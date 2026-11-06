package com.quranadhkar.quran_adhkar_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context

/**
 * Stub AppWidgetProvider for the Quran verse home widget.
 * Complete with RemoteViews layout + SharedPreferences binding on device.
 */
class QuranVerseWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // TODO: bind R.layout.quran_verse_widget from HomeWidget / prefs data
    }
}
