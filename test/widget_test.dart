import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_adhkar_app/main.dart';

void main() {
  testWidgets('App loads', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: QuranAdhkarApp()),
    );
    await tester.pump();
    expect(find.byType(QuranAdhkarApp), findsOneWidget);
  });
}
