import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_adhkar_app/core/notifications/notification_service.dart';
import 'package:quran_adhkar_app/features/quran/data/surah_metadata.dart';
import 'package:quran_adhkar_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotificationService implements NotificationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App loads', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider
              .overrideWithValue(_FakeNotificationService()),
        ],
        child: const QuranAdhkarApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(QuranAdhkarApp), findsOneWidget);
  });

  testWidgets('App opens straight on the home screen (no start button)',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider
              .overrideWithValue(_FakeNotificationService()),
        ],
        child: const QuranAdhkarApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('السلام عليكم'), findsOneWidget);
    expect(find.text('ابدأ الآن'), findsNothing);
  });

  test('Surah metadata is complete and consistent', () {
    expect(allSurahs.length, 114);
    expect(allSurahs.map((s) => s.number).toList(),
        List.generate(114, (i) => i + 1));
    expect(allSurahs.fold<int>(0, (sum, s) => sum + s.ayahCount), 6236);
    for (var i = 1; i < allSurahs.length; i++) {
      expect(allSurahs[i].pageStart >= allSurahs[i - 1].pageStart, isTrue);
    }
  });
}
