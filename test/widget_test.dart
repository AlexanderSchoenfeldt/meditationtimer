import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intention/data/storage.dart';
import 'package:intention/domain/app_state.dart';
import 'package:intention/main.dart';
import 'package:intention/providers/app_state_provider.dart';

void main() {
  testWidgets('App boots, finishes loading, and shows wordmark', (tester) async {
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
    expect(find.text('0'), findsOneWidget); // streak default
  });
}
