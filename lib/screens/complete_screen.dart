import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/session_provider.dart';
import '../theme/palette.dart';

class CompleteScreen extends ConsumerStatefulWidget {
  const CompleteScreen({super.key});

  @override
  ConsumerState<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends ConsumerState<CompleteScreen> {
  bool _showThank = false;
  bool _showDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _showThank = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _showDone = true);
      });
    });
  }

  void _done() {
    ref.read(pendingSessionProvider.notifier).state = null;
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final pending = ref.read(pendingSessionProvider);
    final minutes = pending?.duration;
    final type = pending?.type;
    final meta = minutes == null
        ? null
        : (type != null ? '$minutes min · $type' : '$minutes min');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _done();
      },
      child: Scaffold(
        backgroundColor: p.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 48),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 1800),
                      opacity: _showThank ? 1.0 : 0.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'thank you',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 40,
                              fontWeight: FontWeight.w300,
                              height: 1.1,
                              letterSpacing: -1.0,
                              color: p.ink,
                            ),
                          ),
                          if (meta != null) ...[
                            const SizedBox(height: 18),
                            Text(
                              meta,
                              style: TextStyle(
                                fontSize: 12,
                                color: p.ink3,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 1200),
                  opacity: _showDone ? 1.0 : 0.0,
                  child: TextButton(
                    onPressed: _done,
                    style: TextButton.styleFrom(
                      foregroundColor: p.ink3,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'done',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2.8,
                      ),
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
