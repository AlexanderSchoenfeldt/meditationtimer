import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intention/data/storage.dart';
import 'package:intention/domain/app_state.dart';
import 'package:intention/main.dart';
import 'package:intention/providers/app_state_provider.dart';

void main() {
  testWidgets('Home shows wordmark, time-of-day, and Begin', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageProvider.overrideWithValue(MemoryStorage(AppState.empty)),
        ],
        child: const IntentionApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('INTENTION'), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);
    expect(find.text('or sit without a timer'), findsOneWidget);
    // exactly one of the five possible part-of-day labels is shown
    final labels = ['late night', 'morning', 'afternoon', 'evening', 'night'];
    expect(labels.where((l) => find.text(l).evaluate().isNotEmpty).length, 1);
  });
}
