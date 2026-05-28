import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/dates.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../theme/palette.dart';
import '../widgets/primary_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late DateTime _now;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _partOfDay(int hour) {
    if (hour < 5) return 'late night';
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    if (hour < 21) return 'evening';
    return 'night';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final state = ref.watch(appStateProvider).requireValue;
    final streak = ref.watch(streakProvider);
    final gap = gapDays(streak.lastDate);
    final showRecover =
        gap >= 2 && state.streakDismissedFor != todayKey() && gap < (1 << 29);
    final timeStr = DateFormat('h:mm a').format(_now).toLowerCase();
    final partOfDay = _partOfDay(_now.hour);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            _TimeMarker(time: timeStr, label: partOfDay),
            const SizedBox(height: 56),
            Center(
              child: PrimaryButton(
                label: 'Begin',
                onPressed: () => context.push('/setup'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.push('/open-sit'),
                style: TextButton.styleFrom(foregroundColor: p.ink3),
                child: Text(
                  'or sit without a timer',
                  style: TextStyle(
                    fontSize: 13,
                    color: p.ink3,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _TimeMarker extends StatelessWidget {
  final String time;
  final String label;
  const _TimeMarker({required this.time, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Text(
          time,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 56,
            fontWeight: FontWeight.w300,
            height: 1,
            letterSpacing: -1.4,
            color: p.ink,
            fontFeatures: const [
              FontFeature.tabularFigures(),
              FontFeature.liningFigures(),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: p.ink3,
            letterSpacing: 3.0,
          ),
        ),
      ],
    );
  }
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
                          fontSize: 13, color: p.ink2, letterSpacing: 0.2),
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
