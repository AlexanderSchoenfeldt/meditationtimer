import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/dates.dart';
import '../domain/session.dart';
import '../providers/app_state_provider.dart';
import '../providers/session_provider.dart';
import '../services/audio_service.dart';
import '../theme/palette.dart';

class OpenSitScreen extends ConsumerStatefulWidget {
  const OpenSitScreen({super.key});

  @override
  ConsumerState<OpenSitScreen> createState() => _OpenSitScreenState();
}

class _OpenSitScreenState extends ConsumerState<OpenSitScreen> {
  late final DateTime _startedAt;
  bool _ending = false;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    unawaited(_acquireWakelock());
  }

  @override
  void dispose() {
    unawaited(_releaseWakelock());
    super.dispose();
  }

  Future<void> _acquireWakelock() async {
    try {
      await WakelockPlus.enable();
    } catch (e) {
      if (kDebugMode) debugPrint('Wakelock acquire failed: $e');
    }
  }

  Future<void> _releaseWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }

  Future<void> _end() async {
    if (_ending) return;
    setState(() => _ending = true);

    final elapsed = DateTime.now().difference(_startedAt);
    // Round to the nearest minute, floor to 1 so a quick tap still counts.
    final minutes = (elapsed.inSeconds / 60).round().clamp(1, 24 * 60);

    unawaited(ref.read(audioServiceProvider).ringEndingBell());

    final now = DateTime.now();
    await ref.read(appStateProvider.notifier).addSession(
          Session(
            date: todayKey(now),
            minutes: minutes,
            ts: now.millisecondsSinceEpoch,
          ),
        );

    // Surface the same minutes/type to /complete so its meta line matches.
    ref.read(pendingSessionProvider.notifier).state =
        PendingSession(duration: minutes);

    if (!mounted) return;
    context.go('/complete');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return PopScope(
      canPop: !_ending,
      child: Scaffold(
        backgroundColor: p.bg,
        body: GestureDetector(
          onTap: _ending ? null : _end,
          behavior: HitTestBehavior.opaque,
          child: SafeArea(
            child: Stack(
              children: [
                // Subtle "X close" only while the hint is visible — after the
                // ambient fade-out the screen belongs to the sit, no controls.
                Positioned(
                  top: 4,
                  left: 4,
                  child: _HintFade(
                    delay: Duration.zero,
                    child: IconButton(
                      icon: Icon(Icons.close, color: p.ink3, size: 20),
                      onPressed: _ending
                          ? null
                          : () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            },
                      tooltip: 'Leave without recording',
                    ),
                  ),
                ),
                Center(
                  child: _HintBody(palette: p),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HintBody extends StatelessWidget {
  final Palette palette;
  const _HintBody({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HintFade(
          delay: Duration.zero,
          child: Text(
            'sitting',
            style: TextStyle(
              fontSize: 11,
              color: palette.ink3,
              letterSpacing: 3.0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _HintFade(
          delay: const Duration(milliseconds: 200),
          child: Text(
            'tap when you\'re done',
            style: TextStyle(
              fontSize: 11,
              color: palette.ink3,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

// Plays the design's 7-second fade: 0 → 0.55 (~1 s) → hold (~3 s) → 0 (~2.5 s).
// Once the cycle finishes the child stays at 0 opacity for the rest of the sit.
class _HintFade extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _HintFade({required this.child, required this.delay});

  @override
  State<_HintFade> createState() => _HintFadeState();
}

class _HintFadeState extends State<_HintFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  Timer? _kickoff;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.55), weight: 15),
      TweenSequenceItem(tween: ConstantTween(0.55), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 0.55, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      _kickoff = Timer(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _kickoff?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}
