import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_state_provider.dart';
import '../theme/palette.dart';
import 'stats_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _tab = 'practice';

  static const _tabs = [
    ('practice', 'Practice'),
    ('appearance', 'Appearance'),
    ('data', 'Data'),
    ('about', 'About'),
  ];

  @override
  Widget build(BuildContext context) {
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
          'Settings',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: p.ink2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _TabBar(active: _tab, tabs: _tabs, onSelect: (id) => setState(() => _tab = id)),
          Expanded(child: _paneFor(_tab)),
        ],
      ),
    );
  }

  Widget _paneFor(String id) {
    switch (id) {
      case 'practice':
        return const StatsBody();
      case 'appearance':
        return const _AppearancePane();
      case 'data':
        return const _DataPane();
      case 'about':
        return const _AboutPane();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TabBar extends StatelessWidget {
  final String active;
  final List<(String, String)> tabs;
  final ValueChanged<String> onSelect;
  const _TabBar({
    required this.active,
    required this.tabs,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.lineSoft)),
      ),
      child: Row(
        children: [
          for (final (id, label) in tabs)
            Expanded(
              child: InkWell(
                onTap: () => onSelect(id),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: id == active ? p.ink : Colors.transparent,
                        width: 1.4,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: id == active ? p.ink : p.ink3,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppearancePane extends ConsumerWidget {
  const _AppearancePane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final state = ref.watch(appStateProvider).requireValue;
    final notifier = ref.read(appStateProvider.notifier);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        _RowFrame(
          label: 'Theme',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final t in AppTheme.values) ...[
                _ThemeSwatch(
                  theme: t,
                  selected: t == state.settings.theme,
                  onTap: () => notifier.setTheme(t),
                ),
                if (t != AppTheme.values.last) const SizedBox(width: 10),
              ],
            ],
          ),
        ),
        _RowFrame(
          label: 'Numerals',
          trailing: _Segmented(
            options: const [('serif', 'Serif'), ('sans', 'Sans')],
            value: state.settings.useSerif ? 'serif' : 'sans',
            onChanged: (v) => notifier.setUseSerif(v == 'serif'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
          child: Text(
            'Themes also follow the time of day in feel — light is warm off-white, sepia softens for long sits, dark fits late practice.',
            style: TextStyle(
              fontSize: 12,
              color: p.ink3,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final AppTheme theme;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeSwatch({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final swatchPalette = Palette.of(theme);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? p.ink : p.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: swatchPalette.bg,
            border: Border.all(color: swatchPalette.line, width: 0.5),
          ),
        ),
      ),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;
  const _Segmented({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: p.bgSunk,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (v, label) in options)
            GestureDetector(
              onTap: () => onChanged(v),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: v == value ? p.bg : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: v == value ? p.ink : p.ink3,
                    fontWeight:
                        v == value ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RowFrame extends StatelessWidget {
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;
  const _RowFrame({
    required this.label,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.lineSoft)),
        ),
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 13, color: p.ink3),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _DataPane extends ConsumerWidget {
  const _DataPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final state = ref.watch(appStateProvider).requireValue;
    final sits = state.sessions.length;
    final mins = state.sessions.fold<int>(0, (a, s) => a + s.minutes);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Text(
            'Everything you record lives in one plain-text file on this device. Nothing leaves it.',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: p.ink2,
              height: 1.55,
            ),
          ),
        ),
        _RowFrame(
          label: 'Export & import',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$sits sits · $mins min',
                style: TextStyle(fontSize: 13, color: p.ink3),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: p.ink3, size: 18),
            ],
          ),
          onTap: () => context.push('/data'),
        ),
        _RowFrame(
          label: 'Add past practice',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'backlog',
                style: TextStyle(
                  fontSize: 13,
                  color: p.ink3,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: p.ink3, size: 18),
            ],
          ),
          onTap: () => context.push('/recovery'),
        ),
      ],
    );
  }
}

class _AboutPane extends StatelessWidget {
  const _AboutPane();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Text(
            'Intention is a quiet meditation timer.\nNo accounts, no cloud, no network. Your practice is yours.',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: p.ink2,
              height: 1.6,
            ),
          ),
        ),
        _RowFrame(
          label: 'Show welcome again',
          trailing: Icon(Icons.chevron_right, color: p.ink3, size: 18),
          onTap: () => context.push('/onboarding'),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'v0.1.1',
            style: TextStyle(
              fontSize: 11,
              color: p.ink3,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
