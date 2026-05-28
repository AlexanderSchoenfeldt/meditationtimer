import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intention/data/dates.dart';
import 'package:intention/data/storage.dart';
import 'package:intention/domain/app_state.dart';
import 'package:intention/domain/session.dart';
import 'package:intention/main.dart';
import 'package:intention/providers/app_state_provider.dart';
import 'package:intention/router.dart';

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

  testWidgets('Stats shows empty state with no sessions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageProvider.overrideWithValue(MemoryStorage(AppState.empty)),
          routerProvider.overrideWith((_) => buildRouter(initial: '/stats')),
        ],
        child: const IntentionApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Stats'), findsOneWidget);
    expect(find.textContaining('Your practice will live here'), findsOneWidget);
  });

  testWidgets('Stats renders totals and streaks with seeded sessions',
      (tester) async {
    final today = DateTime.now();
    final seeded = AppState(
      sessions: [
        Session(
          date: todayKey(dateAdd(today, -1)),
          minutes: 20,
          ts: dateAdd(today, -1).millisecondsSinceEpoch,
        ),
        Session(
          date: todayKey(today),
          minutes: 30,
          ts: today.millisecondsSinceEpoch,
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageProvider.overrideWithValue(MemoryStorage(seeded)),
          routerProvider.overrideWith((_) => buildRouter(initial: '/stats')),
        ],
        child: const IntentionApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('TOTAL PRACTICE'), findsOneWidget);
    expect(find.text('Current streak'), findsOneWidget);
    expect(find.text('Longest streak'), findsOneWidget);
    expect(find.text('LAST 8 WEEKS'), findsOneWidget);
    // 50 minutes total surfaces as a serif numeral somewhere on screen
    expect(find.text('50'), findsAtLeastNWidgets(1));
  });

  testWidgets('Settings shows four sub-tabs and switches between them',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageProvider.overrideWithValue(MemoryStorage(AppState.empty)),
          routerProvider.overrideWith((_) => buildRouter(initial: '/settings')),
        ],
        child: const IntentionApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('PRACTICE'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('DATA'), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);

    // Default lands on Practice → empty stats
    expect(find.textContaining('Your practice will live here'), findsOneWidget);

    // Switch to About
    await tester.tap(find.text('ABOUT'));
    await tester.pumpAndSettle();
    expect(find.textContaining('v0.1.0'), findsOneWidget);

    // Switch to Appearance → "Theme" row is present
    await tester.tap(find.text('APPEARANCE'));
    await tester.pumpAndSettle();
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Numerals'), findsOneWidget);
  });

  testWidgets('Setup → Start lands on Timer with remaining time',
      (tester) async {
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
    await tester.tap(find.text('Start · 15 min'));
    await tester.pump(); // schedule navigation
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('REMAINING'), findsOneWidget);
    expect(find.text('OF 15 min'), findsOneWidget);
    // Pause icon shown while running
    expect(find.byIcon(Icons.pause), findsOneWidget);
    // Stop ticker so the test ends cleanly
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
