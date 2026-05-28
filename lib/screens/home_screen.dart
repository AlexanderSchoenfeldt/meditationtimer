import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/dates.dart';
import '../data/stats.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../theme/palette.dart';
import '../widgets/primary_button.dart';
import '../widgets/streak_dots.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final state = ref.watch(appStateProvider).requireValue;
    final streak = ref.watch(streakProvider);
    final gap = gapDays(streak.lastDate);
    final showRecover =
        gap >= 2 && state.streakDismissedFor != todayKey() && gap < (1 << 29);
    final week = lastSevenDays(state.sessions);
    final last = state.sessions.isEmpty ? null : state.sessions.last;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  const Expanded(child: Center(child: Wordmark())),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: p.ink3),
                    onPressed: () => context.push('/settings'),
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ),

            if (showRecover) _RecoverCard(gapDays: gap),

            const Spacer(),

            // Streak hero
            Column(
              children: [
                Text(
                  streak.doneToday ? 'TODAY COMPLETE' : 'CURRENT STREAK',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  '${streak.streak}',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  streak.streak == 1 ? 'DAY IN A ROW' : 'DAYS IN A ROW',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 28),
                StreakDots(days: week),
              ],
            ),

            const Spacer(),

            // Begin
            Center(
              child: PrimaryButton(
                label: 'Begin',
                onPressed: () => context.push('/setup'),
              ),
            ),
            const SizedBox(height: 14),
            if (last != null)
              Center(
                child: Text(
                  'last sit · ${last.minutes} min · ${relativeDay(last.date)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: p.ink3,
                      ),
                ),
              )
            else
              const SizedBox(height: 18),

            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => context.push('/stats'),
                style: TextButton.styleFrom(foregroundColor: p.ink3),
                child: const Text(
                  'view stats',
                  style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2.8,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

String relativeDay(String date) {
  final gap = gapDays(date);
  if (gap == 0) return 'today';
  if (gap == 1) return 'yesterday';
  return '$gap days ago';
}

class _RecoverCard extends StatelessWidget {
  final int gapDays;
  const _RecoverCard({required this.gapDays});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: InkWell(
        onTap: () => context.push('/recovery'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: p.lineSoft),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'After $gapDays days',
                      style: TextStyle(
                          fontSize: 13,
                          color: p.ink2,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'If practice happened, you may mark it.',
                      style: TextStyle(
                        fontSize: 12,
                        color: p.ink3,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: p.ink3, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
