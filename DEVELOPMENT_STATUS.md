# DEVELOPMENT STATUS – Quran & Adhkar App

**Last updated:** 2026-11-05  
**Repository:** https://github.com/aizhari1/quran-adhkar-app

## Phase 1 – COMPLETED
- Clean Architecture + feature folders
- Design system (Deep Emerald / Warm Ivory / Muted Gold) + Light/Dark themes
- Full Drift SQLite schema (Quran, Adhkar, Khatma, Tasbeeh, Settings, Reciters...)
- GoRouter + bottom navigation
- Localization scaffolding (ar + en ARB)
- README + content integrity docs

## Features completed & pushed to GitHub

### Home Dashboard
- Welcome card with Basmala
- Quick actions (Mushaf / Adhkar / Tasbeeh) with navigation
- Next Prayer card
- Continue Reading card
- Morning Adhkar reminder card

### Digital Tasbeeh
- Interactive counter with haptic feedback
- Subhan Allah, Alhamdulillah, Allahu Akbar, Astaghfirullah
- Circular progress ring (Muted Gold)
- Reset with confirmation
- Fully offline

### Morning & Evening Adhkar
- Tabbed UI (الصباح / المساء)
- Real Arabic text + sources (Muslim, Tirmidhi, Bukhari)
- Per-item repetition counter with progress
- Completion checkmarks + category progress
- Reset per category
- Haptic on each tap

## Next (Phase 2 + 5)
1. Quran data import (Tanzil Uthmani) + Mushaf reader
2. Offline Prayer Times with adhan package
3. Khatma planner
4. Persist Tasbeeh & Adhkar progress to Drift
5. Native widgets scaffolding

## How to run
```bash
git clone https://github.com/aizhari1/quran-adhkar-app.git
cd quran-adhkar-app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Place Arabic fonts in `assets/fonts/` before running.
