# Local Adhkar Notifications

## Behavior

- Morning Adhkar: daily **06:30** local when enabled
- Evening Adhkar: daily **17:30** local when enabled
- `flutter_local_notifications` + timezone (not FCM)
- Settings toggles reschedule immediately

## Android permissions

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

Uses `inexactAllowWhileIdle` for broader device compatibility.

## Code

- `lib/core/notifications/notification_service.dart`
- Wired from `AppSettingsNotifier` on notification toggles
