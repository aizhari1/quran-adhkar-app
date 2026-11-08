package com.example.quran_adhkar_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

abstract class TextWidgetProvider : AppWidgetProvider() {
    abstract val widgetTitle: String

    /** Returns (body, footer). */
    abstract fun content(ctx: Context): Pair<String, String>

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val (body, footer) = content(context)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_text)
            views.setTextViewText(R.id.widget_title, widgetTitle)
            views.setTextViewText(R.id.widget_body, body)
            views.setTextViewText(R.id.widget_footer, footer)
            views.setOnClickPendingIntent(R.id.widget_root, WidgetData.openAppIntent(context))
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}

class VerseWidgetProvider : TextWidgetProvider() {
    override val widgetTitle = "آية اليوم"
    override fun content(ctx: Context) = WidgetData.verseOfTheDay(ctx)
}

class DhikrWidgetProvider : TextWidgetProvider() {
    override val widgetTitle = "ذكر اليوم"
    override fun content(ctx: Context) = WidgetData.dhikrOfTheDay(ctx)
}
