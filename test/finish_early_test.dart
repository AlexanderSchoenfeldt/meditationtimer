import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intention/data/storage.dart';
import 'package:intention/domain/app_state.dart';
import 'package:intention/main.dart';
import 'package:intention/providers/app_state_provider.dart';

/// Drives the real timer UI: starts a sit, lets enough wall-clock pass to cross
/// the 60s "worth recording" threshold, pauses, and finishes early — asserting
/// the sit is recorded (with the elapsed minutes) rather than discarded.
///
/// NOTE: this exercises the real elapsed-time path, which reads the wall clock,
/// so it deliberately waits ~63 real seconds. It is not part of the fast unit
/// suite — run it explicitly: `flutter test test/finish_early_test.dart`.
void main() {
  testWidgets('a paused sit can be finished early and is recorded',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        storageProvider.overrideWithValue(
            MemoryStorage(const AppState(onboarded: true))),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const IntentionApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Begin → Setup → Start.
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start · 15 min'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.pause), findsOneWidget);

    // Before the 60s mark, only Stop + Pause are offered — no finish-early.
    expect(find.byIcon(Icons.check), findsNothing);

    // Let real time pass the 60s threshold (elapsed is wall-clock based).
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 63)));
    await tester.pump();

    // Pause.
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();

    // The paused state now offers three controls: Stop, Resume, Finish-early.
    expect(find.byIcon(Icons.stop), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    // Finish early → records the sit and moves to the complete screen.
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    expect(find.text('thank you'), findsOneWidget);

    // The sit was recorded with the elapsed minutes (~1), not discarded.
    final state = await container.read(appStateProvider.future);
    expect(state.sessions.length, 1);
    expect(state.sessions.first.minutes, greaterThanOrEqualTo(1));
    expect(state.sessions.first.minutes, lessThanOrEqualTo(2));
  });
}
