import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intention/main.dart';

void main() {
  testWidgets('App boots and shows wordmark', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: IntentionApp()));
    expect(find.text('INTENTION'), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);
  });
}
