# Quran & Adhkar – Offline-First Islamic Application

Complete Flutter application featuring:

- Full Mushaf (Uthmani) with multiple Riwayat architecture
- Tafsir & multi-language translations
- Daily Khatma tracking
- Interactive home-screen widgets (Android Glance + iOS WidgetKit)
- Automatic morning / evening Adhkar with local notifications
- Digital Tasbeeh
- Offline prayer times (adhan library)
- Multiple authentic reciters + downloadable audio
- Multilingual UI (AR, EN, FR, TR, ID, UR, BN, MS)
- Optional Supabase cloud backup + Firebase (Analytics, Crashlytics, FCM, Remote Config)

## Architecture

Clean Architecture + feature modules:

```
lib/
  app/
  core/          # theme, database, routing, notifications, audio...
  features/      # onboarding, home, quran, adhkar, tasbeeh, prayer_times...
  shared/
```

State: Riverpod  
Navigation: GoRouter  
Local DB: Drift (SQLite)  
Audio: just_audio + audio_service  
Prayer: adhan (fully offline)

## Design System

Sanctuary Editorial (from Stitch):

- Primary: Deep Emerald `#0F2C24`
- Background: Warm Ivory `#F7F4EC`
- Accent: Muted Gold `#C5A46D`
- Arabic-first typography with proper RTL support

## Getting Started (Developer Machine)

1. Install Flutter 3.24+ and Android SDK / Xcode.
2. `cd quran_adhkar_app`
3. `flutter pub get`
4. `dart run build_runner build --delete-conflicting-outputs` (Drift, Freezed, Riverpod)
5. Place Arabic fonts in `assets/fonts/` (Amiri, Scheherazade New, Noto Naskh Arabic, Inter).
6. (Optional) Configure Supabase & Firebase via `.env` / `google-services.json` / `GoogleService-Info.plist`.
7. `flutter run`

## Quran Data

Import process (Phase 2):

- Use verified open datasets (Tanzil.net Uthmani, Quran.com API dumps, or similar with clear license).
- Never generate or rewrite verses with AI.
- Each Riwayah must have its own text table / source metadata.

## Native Widgets

- Android: Jetpack Glance (or RemoteViews) – code under `android/` (to be added).
- iOS: WidgetKit + AppIntents – code under `ios/` (to be added).
- Shared state via App Groups (iOS) and shared preferences / content provider (Android).

## Offline-First Guarantee

Essential features (Quran reading, Adhkar, Tasbeeh, Khatma progress, prayer times, bookmarks, downloaded audio) work with zero network.

## License & Content

- App code: to be decided by publisher.
- Quran text & Adhkar: respect original licenses of source datasets.
- Audio: only use sources that permit redistribution or streaming under clear terms.

## Privacy

- Anonymous local usage by default.
- Optional account for cloud sync.
- No unnecessary personal data collection.
- Privacy policy screen to be added before store release.

See `DEVELOPMENT_STATUS.md` for current implementation progress.
