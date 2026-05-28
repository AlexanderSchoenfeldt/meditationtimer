import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/dates.dart';
import '../data/stats.dart';
import '../data/streak.dart';
import '../domain/app_state.dart';
import '../providers/app_state_provider.dart';
import '../theme/palette.dart';
import '../widgets/bar_chart.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: p.ink2),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Stats',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: p.ink2,
          ),
        ),
        centerTitle: true,
      ),
      body: const StatsBody(),
    );
  }
}

class StatsBody extends ConsumerWidget {
  const StatsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider).requireValue;
    final streak = ref.watch(streakProvider);
    return state.sessions.isEmpty
        ? const _EmptyState()
        : _Filled(state: state, streak: streak);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'Your practice will live here\nonce you sit your first session.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            color: p.ink3,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _Filled extends StatelessWidget {
  final AppState state;
  final StreakInfo streak;

  const _Filled({required this.state, required this.streak});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final sessions = state.sessions;
    final total = totalMinutes(sessions);
    final longest = longestStreak(sessions);
    final avg = averages(sessions);
    final buckets = weeklyBuckets(sessions, weeks: 8);
    final firstDate = sessions
        .map((s) => s.date)
        .reduce((a, b) => a.compareTo(b) < 0 ? a : b);
    final since = _formatSince(firstDate);

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const SizedBox(height: 8),
        _HeroTotal(minutes: total),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'since $since',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: p.ink3,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 36),
        _DualStat(
          left: _StatBlock(label: 'Current streak', value: '${streak.streak}', unit: 'days'),
          right: _StatBlock(label: 'Longest streak', value: '$longest', unit: 'days'),
        ),
        const SizedBox(height: 36),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SectionLabel('LAST 8 WEEKS'),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: WeeklyBars(values: buckets),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              for (int i = 0; i < buckets.length; i++) ...[
                Expanded(
                  child: Text(
                    i == buckets.length - 1 ? 'now' : '−${buckets.length - 1 - i}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: p.ink3),
                  ),
                ),
                if (i < buckets.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 36),
        if (avg != null) _AveragesGrid(avg: avg, longestSessionMin: avg.longestSession),
      ],
    );
  }

  String _formatSince(String firstDate) {
    final d = parseDayKey(firstDate);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _HeroTotal extends StatelessWidget {
  final int minutes;
  const _HeroTotal({required this.minutes});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return Center(
      child: Column(
        children: [
          Text(
            'TOTAL PRACTICE',
            style: TextStyle(
              fontSize: 10,
              color: p.ink3,
              letterSpacing: 2.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (h > 0) ...[
                Text(
                  '$h',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 72,
                    color: p.ink,
                    fontWeight: FontWeight.w300,
                    height: 1,
                    letterSpacing: -3,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'h',
                  style: TextStyle(
                    fontSize: 14,
                    color: p.ink3,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                '$m',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 72,
                  color: p.ink,
                  fontWeight: FontWeight.w300,
                  height: 1,
                  letterSpacing: -3,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'min',
                style: TextStyle(
                  fontSize: 14,
                  color: p.ink3,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DualStat extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _DualStat({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: left),
            Container(width: 1, color: p.lineSoft),
            Expanded(child: right),
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  const _StatBlock({required this.label, required this.value, this.unit});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: p.ink3,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 32,
                  color: p.ink,
                  height: 1,
                  letterSpacing: -1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: TextStyle(
                    fontSize: 12,
                    color: p.ink3,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        color: p.ink3,
        letterSpacing: 2.6,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _AveragesGrid extends StatelessWidget {
  final Averages avg;
  final int longestSessionMin;
  const _AveragesGrid({required this.avg, required this.longestSessionMin});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cells = <_AvgCell>[
      _AvgCell(value: avg.perWeek.round().toString(), suffix: 'min', label: 'PER WEEK'),
      _AvgCell(value: avg.perSession.round().toString(), suffix: 'min', label: 'PER SESSION'),
      _AvgCell(value: avg.sessionsPerWeek.toStringAsFixed(1), suffix: 'sits', label: 'SESSIONS / WEEK'),
      _AvgCell(value: '$longestSessionMin', suffix: 'min', label: 'LONGEST SIT'),
      if (avg.bestDay != null)
        _AvgCell(text: avg.bestDay!, label: 'BEST DAY'),
      if (avg.typicalTime != null)
        _AvgCell(text: avg.typicalTime!.toLowerCase(), label: 'TYPICAL TIME'),
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: p.lineSoft),
          bottom: BorderSide(color: p.lineSoft),
        ),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        childAspectRatio: 1.7,
        children: [
          for (final c in cells)
            Container(
              color: p.bg,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: c,
            ),
        ],
      ),
    );
  }
}

class _AvgCell extends StatelessWidget {
  final String? value;
  final String? suffix;
  final String? text;
  final String label;
  const _AvgCell({this.value, this.suffix, this.text, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isText = text != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              isText ? text! : value!,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: isText ? 22 : 32,
                color: p.ink,
                height: 1,
                letterSpacing: isText ? -0.3 : -1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 4),
              Text(
                suffix!,
                style: TextStyle(fontSize: 12, color: p.ink3),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: p.ink3,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
