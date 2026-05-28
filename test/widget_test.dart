import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intention/data/storage.dart';
import 'package:intention/domain/app_state.dart';
import 'package:intention/main.dart';
import 'package:intention/providers/app_state_provider.dart';

import 'package:flutter/material.dart';

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
    final labels = ['late night', 'morning', 'afternoon', 'evening', 'night'];
    expect(labels.where((l) => find.text(l).evaluate().isNotEmpty).length, 1);
  });

  testWidgets('Begin → Setup shows Start with default 15 min', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageProvider.overrideWithValue(MemoryStorage(AppState.empty)),
        ],
        child: const IntentionApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();
    expect(find.text('Begin a session'), findsOneWidget);
    expect(find.text('Start · 15 min'), findsOneWidget);

    // Increment duration: + on Duration row, twice = +10 min
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();
    expect(find.text('Start · 25 min'), findsOneWidget);
  });
}
