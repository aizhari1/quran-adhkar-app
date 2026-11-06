# Home Screen Verse Widget

## Goal

Interactive Quran verse on the home screen:
- Shows current ayah (Arabic + optional translation)
- Tap **قرأت الآية** → advances to next ayah
- Works offline from local data

## Flutter

- Package: `home_widget: ^0.7.0`
- Service: `lib/features/widgets/verse_widget_service.dart`

## Android

1. `AppWidgetProvider` named `QuranVerseWidgetProvider` (stub in `android/.../QuranVerseWidgetProvider.kt`).
2. Read keys: `surahNumber`, `ayahNumber`, `surahNameArabic`, `textArabic`, `translation`, `pageNumber`.
3. Button opens deep link `quranadhkar://widget/read`.
4. Theme: deep emerald / ivory / gold.

## iOS

1. WidgetKit extension **QuranVerseWidget**.
2. App Group: `group.com.quranadhkar.app`.
3. Same keys via `UserDefaults(suiteName:)`.

## After Quran import

Replace `fallback` with next ayah from Drift (reading position / Khatma).

## Integrity

Only verified Uthmani text from local DB. Never AI-generated ayah text.
