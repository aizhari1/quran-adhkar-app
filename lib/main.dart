import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/notifications/notification_service.dart';
import 'features/onboarding/data/onboarding_prefs.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/widgets/verse_widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  try {
    final widgetService = VerseWidgetService();
    await widgetService.init();
    await widgetService.showFallback();
  } catch (_) {}

  try {
    await NotificationService().init();
  } catch (_) {}

  final onboardingDone = await OnboardingPrefs.isDone();

  runApp(
    ProviderScope(
      overrides: [
        onboardingDoneProvider.overrideWithValue(onboardingDone),
      ],
      child: const QuranAdhkarApp(),
    ),
  );
}

class QuranAdhkarApp extends ConsumerWidget {
  const QuranAdhkarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      title: 'القرآن والأذكار',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: Locale(settings.languageCode),
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('fr'),
        Locale('tr'),
        Locale('id'),
        Locale('ur'),
        Locale('bn'),
        Locale('ms'),
      ],
    );
  }
}
