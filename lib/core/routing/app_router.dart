import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/quran/presentation/quran_library_screen.dart';
import '../../features/quran/mushaf/presentation/mushaf_reader_screen.dart';
import '../../features/adhkar/presentation/adhkar_screen.dart';
import '../../features/tasbeeh/presentation/tasbeeh_screen.dart';
import '../../features/prayer_times/presentation/prayer_times_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/quran/khatma/presentation/khatma_screen.dart';
import '../../features/quran/reciters/presentation/reciters_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/quran',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuranLibraryScreen(),
            ),
            routes: [
              GoRoute(
                path: 'mushaf',
                builder: (context, state) {
                  final page = int.tryParse(state.uri.queryParameters['page'] ?? '1') ?? 1;
                  return MushafReaderScreen(initialPage: page);
                },
              ),
              GoRoute(
                path: 'khatma',
                builder: (context, state) => const KhatmaScreen(),
              ),
              GoRoute(
                path: 'reciters',
                builder: (context, state) => const RecitersScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/adhkar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdhkarScreen(),
            ),
          ),
          GoRoute(
            path: '/tasbeeh',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TasbeehScreen(),
            ),
          ),
          GoRoute(
            path: '/prayer',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PrayerTimesScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _AppBottomNav(),
    );
  }
}

class _AppBottomNav extends ConsumerWidget {
  const _AppBottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    int index = 0;
    if (location.startsWith('/quran')) index = 1;
    else if (location.startsWith('/adhkar')) index = 2;
    else if (location.startsWith('/tasbeeh')) index = 3;
    else if (location.startsWith('/prayer')) index = 4;

    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/quran');
            break;
          case 2:
            context.go('/adhkar');
            break;
          case 3:
            context.go('/tasbeeh');
            break;
          case 4:
            context.go('/prayer');
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Quran'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Adhkar'),
        NavigationDestination(icon: Icon(Icons.fingerprint_outlined), selectedIcon: Icon(Icons.fingerprint), label: 'Tasbeeh'),
        NavigationDestination(icon: Icon(Icons.access_time_outlined), selectedIcon: Icon(Icons.access_time), label: 'Prayer'),
      ],
    );
  }
}
