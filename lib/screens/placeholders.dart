// Placeholder screens. Each is replaced by a real implementation as we
// move through Phase 3. Keeping them in one file keeps the per-screen
// commits small.

import 'package:flutter/material.dart';

import '../theme/palette.dart';

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: p.ink2),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(title, style: TextStyle(color: p.ink2, fontSize: 15)),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          '$title — coming next',
          style: TextStyle(color: p.ink3, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderScreen('Stats');
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderScreen('Settings');
}

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderScreen('Data');
}

class RecoveryScreen extends StatelessWidget {
  const RecoveryScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderScreen('Recovery');
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderScreen('Welcome');
}

class OpenSitScreen extends StatelessWidget {
  const OpenSitScreen({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderScreen('Open sit');
}
