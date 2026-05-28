import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_state_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: IntentionApp()));
}

class IntentionApp extends ConsumerWidget {
  const IntentionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final palette = ref.watch(paletteProvider);
    final theme = buildTheme(palette);

    return state.when(
      data: (_) => MaterialApp.router(
        title: 'Intention',
        debugShowCheckedModeBanner: false,
        theme: theme,
        routerConfig: ref.watch(routerProvider),
      ),
      loading: () => MaterialApp(
        theme: theme,
        debugShowCheckedModeBanner: false,
        home: const _Splash(),
      ),
      error: (e, _) => MaterialApp(
        theme: theme,
        debugShowCheckedModeBanner: false,
        home: _ErrorView(error: e),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Wordmark()));
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load your data.\n$error',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
