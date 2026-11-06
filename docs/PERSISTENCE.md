# Local Persistence

## Active offline storage (SharedPreferences)

| Data | Survives restart |
|------|------------------|
| App settings (lang, theme, font, prayer method, notifications) | Yes |
| Tasbeeh current counter (name + count + target) | Yes |
| Adhkar progress (counts + completed ids) | Yes |
| Khatma plans (all fields) | Yes |

## Drift (SQLite) – after `build_runner`

Schema is ready in `lib/core/database/app_database.dart`.
Repository stubs exist for Settings / Tasbeeh / Khatma.

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Keys

- Settings: `settings_*`
- Tasbeeh: `tasbeeh_current`
- Adhkar: `adhkar_counts`, `adhkar_completed`
- Khatma: `khatma_plans`
