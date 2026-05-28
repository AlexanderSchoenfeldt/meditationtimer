import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/dates.dart';
import '../domain/session.dart';
import '../providers/app_state_provider.dart';
import '../providers/session_provider.dart';
import '../theme/palette.dart';
import '../widgets/progress_ring.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with WidgetsBindingObserver {
  late int _totalSeconds;
  int _bellMinutes = 0;
  Duration _elapsedBefore = Duration.zero;
  DateTime? _runStartedAt;
  Timer? _ticker;
  bool _dimmed = false;
  bool _completed = false;
  int _lastBellMin = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final pending = ref.read(pendingSessionProvider);
    if (pending == null) {
      _totalSeconds = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/');
      });
      return;
    }
    _totalSeconds = pending.duration * 60;
    _bellMinutes = pending.bell;
    _resume();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  bool get _running => _runStartedAt != null;

  Duration get _elapsed {
    if (_runStartedAt == null) return _elapsedBefore;
    return _elapsedBefore + DateTime.now().difference(_runStartedAt!);
  }

  int get _remainingSec {
    final r = _totalSeconds - _elapsed.inSeconds;
    return r < 0 ? 0 : r;
  }

  double get _progress {
    if (_totalSeconds == 0) return 0;
    return _elapsed.inMilliseconds / (_totalSeconds * 1000);
  }

  void _resume() {
    _runStartedAt = DateTime.now();
    _ticker ??= Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => _onTick(),
    );
    setState(() {});
  }

  void _pause() {
    if (_runStartedAt != null) {
      _elapsedBefore += DateTime.now().difference(_runStartedAt!);
      _runStartedAt = null;
    }
    setState(() {});
  }

  void _toggleRun() => _running ? _pause() : _resume();

  void _onTick() {
    if (!mounted) return;
    final elapsedMin = _elapsed.inMinutes;
    if (_bellMinutes > 0 &&
        elapsedMin > 0 &&
        elapsedMin % _bellMinutes == 0 &&
        elapsedMin != _lastBellMin) {
      _lastBellMin = elapsedMin;
      // Audio hook lives here — Phase 4 wires just_audio.
    }
    if (_elapsed.inSeconds >= _totalSeconds && !_completed) {
      _completed = true;
      _onComplete();
      return;
    }
    setState(() {});
  }

  Future<void> _onComplete() async {
    _ticker?.cancel();
    final pending = ref.read(pendingSessionProvider);
    if (pending != null) {
      final now = DateTime.now();
      await ref.read(appStateProvider.notifier).addSession(
            Session(
              date: todayKey(now),
              minutes: pending.duration,
              ts: now.millisecondsSinceEpoch,
              type: pending.type,
            ),
          );
    }
    if (!mounted) return;
    context.go('/complete');
  }

  Future<void> _confirmStop() async {
    if (_elapsed.inSeconds < 60) {
      _exit();
      return;
    }
    final p = context.palette;
    final wasRunning = _running;
    if (wasRunning) _pause();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dp = ctx.palette;
        return AlertDialog(
          backgroundColor: dp.bgElev,
          title: Text('End this sit?',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: dp.ink)),
          content: Text(
            'Time so far won\'t be recorded.',
            style: TextStyle(fontSize: 14, color: dp.ink2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: TextButton.styleFrom(foregroundColor: dp.ink3),
              child: const Text('Keep sitting'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: p.gold),
              child: const Text('End'),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (confirmed == true) {
      _exit();
    } else if (wasRunning) {
      _resume();
    }
  }

  void _exit() {
    _ticker?.cancel();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  String _formatRemaining(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatTotal() {
    final m = _totalSeconds ~/ 60;
    return m < 60 ? '$m min' : '${m ~/ 60}h ${m % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = _dimmed ? const Color(0xFF0E0F12) : p.bg;
    final inkColor = _dimmed ? const Color(0xFF6C707A) : p.ink;
    final trackColor = _dimmed ? const Color(0xFF1F2127) : p.lineSoft;
    final arcColor = _dimmed ? const Color(0xFF7A6638) : p.gold;
    final fadeFor = _dimmed ? 0.0 : 1.0;

    return Scaffold(
      backgroundColor: bg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _dimmed = !_dimmed),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: bg,
          child: SafeArea(
            child: Stack(
              children: [
                AnimatedOpacity(
                  opacity: fadeFor,
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: p.ink2),
                          onPressed: _confirmStop,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(260, 260),
                          painter: ProgressRingPainter(
                            progress: _progress,
                            track: trackColor,
                            arc: arcColor,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedOpacity(
                              opacity: fadeFor,
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                'REMAINING',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 2.8,
                                  color: _dimmed ? inkColor : p.ink3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _formatRemaining(_remainingSec),
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 56,
                                color: inkColor,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -1.2,
                                height: 1,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                  FontFeature.liningFigures(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            AnimatedOpacity(
                              opacity: fadeFor,
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                'OF ${_formatTotal()}',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 2.8,
                                  color: _dimmed ? inkColor : p.ink3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 32,
                  child: AnimatedOpacity(
                    opacity: fadeFor,
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CircleButton(
                          icon: Icons.stop,
                          outlined: true,
                          onTap: _confirmStop,
                        ),
                        const SizedBox(width: 24),
                        _CircleButton(
                          icon: _running ? Icons.pause : Icons.play_arrow,
                          outlined: false,
                          onTap: _toggleRun,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool outlined;
  final VoidCallback onTap;
  const _CircleButton({
    required this.icon,
    required this.outlined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: outlined ? Colors.transparent : p.gold,
          border: outlined ? Border.all(color: p.line) : null,
        ),
        child: Icon(
          icon,
          color: outlined ? p.ink2 : p.goldOn,
          size: 22,
        ),
      ),
    );
  }
}
