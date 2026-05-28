import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_state_provider.dart';
import '../theme/palette.dart';
import '../widgets/primary_button.dart';

class _Panel {
  final String? eyebrow;
  final String title;
  final String body;
  const _Panel({this.eyebrow, required this.title, required this.body});
}

const _panels = [
  _Panel(
    eyebrow: 'INTENTION',
    title: 'A quiet timer for your practice.',
    body:
        'No accounts. No cloud. No distractions. Just a serif clock and the room you are in.',
  ),
  _Panel(
    eyebrow: 'PRIVATE',
    title: 'Yours alone.',
    body:
        'Your sits stay on this device. There is no network. Nothing leaves your phone.',
  ),
  _Panel(
    eyebrow: 'DAY BY DAY',
    title: 'A streak you can pick back up.',
    body:
        'Sit today, then tomorrow. Miss a day and Intention will quietly ask if you practiced while away.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_index < _panels.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOut,
      );
    } else {
      await ref.read(appStateProvider.notifier).markOnboarded();
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isLast = _index == _panels.length - 1;

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 56, 32, 40),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _panels.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _PanelView(panel: _panels[i]),
                ),
              ),
              _Dots(active: _index, count: _panels.length),
              const SizedBox(height: 28),
              PrimaryButton(
                label: isLast ? 'Begin' : 'Continue',
                onPressed: _next,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: isLast
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: () => _controller.animateToPage(
                          _panels.length - 1,
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOut,
                        ),
                        style: TextButton.styleFrom(foregroundColor: p.ink3),
                        child: const Text(
                          'skip',
                          style: TextStyle(fontSize: 12, letterSpacing: 2.4),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelView extends StatelessWidget {
  final _Panel panel;
  const _PanelView({required this.panel});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (panel.eyebrow != null) ...[
          Text(
            panel.eyebrow!,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 12,
              color: p.ink3,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 32),
        ],
        Text(
          panel.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 32,
            color: p.ink,
            fontWeight: FontWeight.w400,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            panel.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: p.ink2,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  final int active;
  final int count;
  const _Dots({required this.active, required this.count});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == active ? p.ink : p.line,
            ),
          ),
          if (i < count - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}
