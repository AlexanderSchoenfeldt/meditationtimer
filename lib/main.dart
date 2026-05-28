import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_state_provider.dart';
import 'theme/app_theme.dart';
import 'theme/palette.dart';

void main() {
  runApp(const ProviderScope(child: IntentionApp()));
}

class IntentionApp extends ConsumerWidget {
  const IntentionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final palette = ref.watch(paletteProvider);
    return MaterialApp(
      title: 'Intention',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(palette),
      home: state.when(
        data: (_) => const _ThemePreview(),
        loading: () => const _Splash(),
        error: (e, _) => _ErrorView(error: e),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Wordmark()),
    );
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

class _ThemePreview extends ConsumerWidget {
  const _ThemePreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final state = ref.watch(appStateProvider).requireValue;
    final streak = ref.watch(streakProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Wordmark(),
            const Spacer(),
            Text('${streak.streak}',
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 4),
            Text('DAYS IN A ROW',
                style: Theme.of(context).textTheme.labelMedium),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: p.gold,
                foregroundColor: p.goldOn,
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 56, vertical: 18),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onPressed: () {},
              child: const Text('Begin'),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final m in AppTheme.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: TextButton(
                      onPressed: () => ref
                          .read(appStateProvider.notifier)
                          .setTheme(m),
                      child: Text(
                        m.name,
                        style: TextStyle(
                          color: m == state.settings.theme ? p.ink : p.ink3,
                          fontWeight: m == state.settings.theme
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
