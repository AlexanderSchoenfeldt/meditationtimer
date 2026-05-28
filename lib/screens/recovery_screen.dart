import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/dates.dart';
import '../domain/session.dart';
import '../providers/app_state_provider.dart';
import '../theme/palette.dart';
import '../widgets/inline_stepper.dart';
import '../widgets/primary_button.dart';

class RecoveryScreen extends ConsumerStatefulWidget {
  const RecoveryScreen({super.key});

  @override
  ConsumerState<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends ConsumerState<RecoveryScreen> {
  int _perSession = 15;
  int _days = 30;
  String? _type;

  void _incPer() => setState(() => _perSession = (_perSession + 5).clamp(1, 240));
  void _decPer() => setState(() => _perSession = (_perSession - 5).clamp(1, 240));
  void _incDays() => setState(() => _days = (_days + 1).clamp(1, 3650));
  void _decDays() => setState(() => _days = (_days - 1).clamp(1, 3650));

  Future<void> _pickType() async {
    final state = ref.read(appStateProvider).requireValue;
    final picked = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: context.palette.bgElev,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SimpleTypePicker(types: state.types, selected: _type),
    );
    if (!mounted) return;
    // sentinel: null means "no change"; passing '' means clear
    if (picked == '') {
      setState(() => _type = null);
    } else if (picked != null) {
      setState(() => _type = picked);
    }
  }

  Future<void> _addStreak() async {
    final today = startOfDay(DateTime.now());
    final current = ref.read(appStateProvider).requireValue;
    final used = current.sessions.map((s) => s.date).toSet();
    final imported = <Session>[];
    for (int i = 0; i < _days; i++) {
      final d = dateAdd(today, -i);
      final key = todayKey(d);
      if (used.contains(key)) continue;
      imported.add(Session(
        date: key,
        minutes: _perSession,
        ts: d.millisecondsSinceEpoch + 8 * 3600 * 1000,
        type: _type,
        imported: true,
        summary: true,
      ));
    }
    final merged = [...current.sessions, ...imported]
      ..sort((a, b) => a.ts.compareTo(b.ts));
    await ref
        .read(appStateProvider.notifier)
        .replace(current.copyWith(
          sessions: merged,
          clearStreakDismissed: true,
        ));
    if (!mounted) return;
    _back();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  String _formatHM(int totalMin) {
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '$h h';
    return '$h h $m';
  }

  String _formatStartDate() {
    final start = dateAdd(startOfDay(DateTime.now()), -(_days - 1));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[start.month - 1]} ${start.day}';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final totalMinutes = _days * _perSession;

    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: p.ink2),
          onPressed: _back,
        ),
        title: Text(
          'Backlog',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: p.ink2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add past practice',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: p.ink,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Already sitting for months or years? Add a continuous streak ending today.',
              style: TextStyle(
                fontSize: 14,
                color: p.ink2,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            _Row(
              label: 'Practice',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _type ?? 'Any',
                    style: TextStyle(
                      fontSize: 16,
                      color: _type == null ? p.ink3 : p.ink,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right, color: p.ink3, size: 18),
                ],
              ),
              onTap: _pickType,
            ),
            _Row(
              label: 'Per session',
              trailing: InlineStepper(
                value: '$_perSession',
                unit: 'MIN',
                onDecrement: _perSession > 1 ? _decPer : null,
                onIncrement: _perSession < 240 ? _incPer : null,
              ),
            ),
            _Row(
              label: 'Days unbroken',
              trailing: InlineStepper(
                value: '$_days',
                unit: 'DAYS',
                onDecrement: _days > 1 ? _decDays : null,
                onIncrement: _days < 3650 ? _incDays : null,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$_days',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 64,
                          fontWeight: FontWeight.w300,
                          color: p.ink,
                          letterSpacing: -2,
                          height: 1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'DAYS',
                        style: TextStyle(
                          fontSize: 12,
                          color: p.ink3,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatHM(totalMinutes)} of practice',
                    style: TextStyle(fontSize: 13, color: p.ink3),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'from ${_formatStartDate()} to today',
                    style: TextStyle(
                      fontSize: 12,
                      color: p.ink3,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Days that already have a session will be left untouched.',
              style: TextStyle(
                fontSize: 11,
                color: p.ink3,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: PrimaryButton(
                label: 'Add $_days-day streak',
                onPressed: _addStreak,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _back,
                style: TextButton.styleFrom(foregroundColor: p.ink3),
                child: Text(
                  'Skip — starting fresh',
                  style: TextStyle(
                      fontSize: 13,
                      color: p.ink3,
                      decoration: TextDecoration.underline,
                      decorationColor: p.ink3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;
  const _Row({required this.label, required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.lineSoft)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: p.ink2),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _SimpleTypePicker extends StatelessWidget {
  final List<String> types;
  final String? selected;
  const _SimpleTypePicker({required this.types, required this.selected});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: p.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'PRACTICE',
              style: TextStyle(
                fontSize: 11,
                color: p.ink3,
                letterSpacing: 2.8,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView(
                shrinkWrap: true,
                children: [
                  _row(context, label: 'Any', value: '', isSelected: selected == null),
                  for (final t in types)
                    _row(context, label: t, value: t, isSelected: t == selected),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context,
      {required String label, required String value, required bool isSelected}) {
    final p = context.palette;
    return InkWell(
      onTap: () => Navigator.of(context).pop(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.lineSoft)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: p.ink,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check, color: p.gold, size: 18),
          ],
        ),
      ),
    );
  }
}
