# Local Persistence

## Current (works offline without codegen)

| Data | Storage | Status |
|------|---------|--------|
| App settings (lang, theme, font, prayer method, notifications) | SharedPreferences | **Active** – survives app restart |
| Tasbeeh counts | In-memory (+ Drift repo ready) | After build_runner |
| Adhkar progress | In-memory | After build_runner |
| Khatma plans | In-memory (+ Drift repo ready) | After build_runner |
| Reading position | Drift schema ready | After Quran import + codegen |

## After `dart run build_runner build`

1. Drift generates `app_database.g.dart`.
2. Use `SettingsRepository`, `TasbeehRepository`, `KhatmaRepository` for SQLite.
3. Optional: migrate SharedPreferences settings into Drift `UserSettings`.

## SharedPreferences keys

- `settings_lang`, `settings_theme`, `settings_font`, `settings_calc`, `settings_asr`
- `settings_notif`, `settings_morning`, `settings_evening`, `settings_widget`
