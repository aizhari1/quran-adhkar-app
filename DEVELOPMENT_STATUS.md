# DEVELOPMENT STATUS – Quran & Adhkar App

**Last updated:** 2026-11-05

## Environment Limitations (Blocking full mobile builds)

- No Android SDK / Android Studio → cannot compile APK or test Glance widgets.
- No Xcode / macOS → cannot compile iOS or test WidgetKit / App Groups.
- Limited RAM (~1.2 GB) → heavy `flutter pub get` + codegen may OOM.
- Flutter installed at `/opt/flutter` (3.24.5).

## Phase 1 – COMPLETED (Architecture, Design System, Navigation, DB Schema, l10n)

### Implemented
- Clean Architecture + feature-based folder structure.
- Full design system from Stitch DESIGN.md:
  - Deep Emerald `#0F2C24`, Warm Ivory `#F7F4EC`, Muted Gold `#C5A46D`.
  - Light + Dark ThemeData (Material 3).
  - Typography tokens for Quran (ScheherazadeNew), Arabic UI (NotoNaskhArabic), Latin (Inter).
- GoRouter with ShellRoute + bottom navigation (Home / Quran / Adhkar / Tasbeeh / Prayer).
- Complete Drift (SQLite) schema covering:
  - Quran (Surahs, Ayahs, Juz, Hizb, Pages, Riwayat, Translations, Tafsir).
  - Adhkar (Categories, Items, Translations, Progress, Favorites).
  - User data (Bookmarks, ReadingPositions, Khatmas, Tasbeeh, Settings).
  - Reciters + downloaded audio metadata.
- Localization scaffolding (ARB for `en` + `ar`, 8 supported locales declared).
- Home screen with real design tokens (welcome card, quick actions, next prayer, continue reading).
- Placeholder screens for all major features (ready to be replaced).
- `pubspec.yaml` with all production dependencies (Riverpod, Drift, just_audio, adhan, Supabase, Firebase, etc.).
- `main.dart` with ProviderScope, theme switching, localization delegates.

### Files created / modified
- `pubspec.yaml`
- `lib/main.dart`
- `lib/core/theme/app_colors.dart`, `app_typography.dart`, `app_theme.dart`
- `lib/core/database/app_database.dart` (full schema)
- `lib/core/routing/app_router.dart`
- `lib/features/home/presentation/home_screen.dart` (+ other feature placeholders)
- `l10n.yaml`, `l10n/app_en.arb`, `l10n/app_ar.arb`
- Folder structure under `lib/{app,core,features,shared}`

### Tests executed
- None yet (codegen + pub get not run due to environment constraints).

### Remaining in Phase 1
- Run `flutter pub get` + `build_runner` for Drift/Freezed/Riverpod when environment allows.
- Download open-source Arabic fonts into `assets/fonts/`.
- Add more ARB languages (fr, tr, id, ur, bn, ms).

## Phase 2 – NEXT
- Import verified Uthmani Quran text (e.g. from Tanzil or Quran.com open data).
- Implement Mushaf page mode + continuous mode.
- Tafsir & translation data models + downloadable packs.
- Bookmarks + last reading position persistence.

## Phase 4 (partial) – Digital Tasbeeh COMPLETED early

### Implemented
- Fully interactive Tasbeeh counter with:
  - Subhan Allah, Alhamdulillah, Allahu Akbar, Astaghfirullah
  - Haptic feedback on each count
  - Circular progress ring (Muted Gold)
  - Reset with confirmation dialog
  - Riverpod state
  - Design-system compliant UI
- Works completely offline (in-memory for now; will persist via Drift next)

### Remaining for Tasbeeh
- Persist counts & history to Drift `TasbeehCounters` / `TasbeehHistory`
- Multiple simultaneous counters
- Daily statistics

## External Dependencies Required for Full Release
- Android SDK + emulator / real device.
- Apple Developer account + Xcode for iOS widgets.
- Supabase project (free tier) for optional cloud sync.
- Firebase project (free tier) for Crashlytics / Analytics / FCM / Remote Config.
- Licensed or open Quran audio sources (will never invent URLs).
- Verified Adhkar text sources (Hisn al-Muslim etc.).

## Content Integrity Notes
- Quran text will be imported from documented open sources only.
- No AI-generated Quran verses.
- Riwayat other than Hafs marked unavailable until verified text is present.
