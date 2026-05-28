import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';
import 'theme/palette.dart';

void main() {
  runApp(const ProviderScope(child: IntentionApp()));
}

final appThemeProvider = StateProvider<AppTheme>((_) => AppTheme.light);

class IntentionApp extends ConsumerWidget {
  const IntentionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeProvider);
    return MaterialApp(
      title: 'Intention',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Palette.of(mode)),
      home: const _ThemePreview(),
    );
  }
}

class _ThemePreview extends ConsumerWidget {
  const _ThemePreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final mode = ref.watch(appThemeProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Wordmark(),
            const Spacer(),
            Text('23', style: Theme.of(context).textTheme.displayLarge),
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
                      onPressed: () =>
                          ref.read(appThemeProvider.notifier).state = m,
                      child: Text(
                        m.name,
                        style: TextStyle(
                          color: m == mode ? p.ink : p.ink3,
                          fontWeight:
                              m == mode ? FontWeight.w600 : FontWeight.w400,
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
