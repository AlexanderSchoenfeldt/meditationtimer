import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/app_state.dart';
import '../domain/preset.dart';
import '../providers/app_state_provider.dart';
import '../providers/session_provider.dart';
import '../theme/palette.dart';
import '../widgets/inline_stepper.dart';
import '../widgets/primary_button.dart';

const _bellOptions = [0, 1, 2, 5, 10, 15, 20];

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  late int _duration;
  late int _bell;
  String? _type;
  bool _initialized = false;

  void _ensureInit(AppState state) {
    if (_initialized) return;
    _duration = state.lastUsed.duration;
    _bell = state.lastUsed.bell;
    _type = state.lastUsed.type;
    _initialized = true;
  }

  void _decDuration() => setState(() {
        _duration = (_duration - 5).clamp(1, 240);
        _clampBell();
      });
  void _incDuration() => setState(() {
        _duration = (_duration + 5).clamp(1, 240);
      });

  void _clampBell() {
    if (_bell >= _duration) _bell = 0;
  }

  void _stepBell(int dir) {
    final idx = _bellOptions.indexOf(_bell);
    final next = (idx + dir).clamp(0, _bellOptions.length - 1);
    final candidate = _bellOptions[next];
    if (candidate >= _duration) return;
    setState(() => _bell = candidate);
  }

  Preset? _matchingPreset(AppState state) {
    for (final p in state.presets) {
      if (p.matches(duration: _duration, bell: _bell, type: _type)) return p;
    }
    return null;
  }

  Future<void> _pickType(AppState state) async {
    final picked = await showModalBottomSheet<_TypePickResult>(
      context: context,
      backgroundColor: context.palette.bgElev,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TypePickerSheet(types: state.types, selected: _type),
    );
    if (!mounted || picked == null) return;
    if (picked.addNew) {
      final name = await _promptName(title: 'Name this practice');
      if (name == null || name.isEmpty) return;
      await ref.read(appStateProvider.notifier).addType(name);
      if (!mounted) return;
      setState(() => _type = name);
    } else {
      setState(() => _type = picked.name);
    }
  }

  Future<String?> _promptName({required String title}) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        final p = ctx.palette;
        return AlertDialog(
          backgroundColor: p.bgElev,
          title: Text(title,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: p.ink)),
          content: TextField(
            controller: controller,
            autofocus: true,
            cursorColor: p.gold,
            style: TextStyle(color: p.ink, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'e.g. Loving-kindness',
              hintStyle: TextStyle(color: p.ink3),
              filled: true,
              fillColor: p.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: p.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: p.gold),
              ),
            ),
            onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              style: TextButton.styleFrom(foregroundColor: p.ink3),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(controller.text.trim()),
              style: TextButton.styleFrom(foregroundColor: p.gold),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePreset() async {
    final defaultName = _type != null
        ? '$_duration min $_type'
        : '$_duration min';
    final controller = TextEditingController(text: defaultName);
    if (!mounted) return;
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final p = ctx.palette;
        return AlertDialog(
          backgroundColor: p.bgElev,
          title: Text('Save preset',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: p.ink)),
          content: TextField(
            controller: controller,
            autofocus: true,
            cursorColor: p.gold,
            style: TextStyle(color: p.ink, fontSize: 15),
            decoration: InputDecoration(
              filled: true,
              fillColor: p.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: p.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: p.gold),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              style: TextButton.styleFrom(foregroundColor: p.ink3),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(controller.text.trim()),
              style: TextButton.styleFrom(foregroundColor: p.gold),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (!mounted || name == null || name.isEmpty) return;
    await ref.read(appStateProvider.notifier).addPreset(
          Preset(
            id: DateTime.now().millisecondsSinceEpoch.toRadixString(36),
            name: name,
            duration: _duration,
            bell: _bell,
            type: _type,
          ),
        );
  }

  Future<void> _start() async {
    await ref.read(appStateProvider.notifier).updateLastUsed(
          LastUsed(duration: _duration, bell: _bell, type: _type),
        );
    ref.read(pendingSessionProvider.notifier).state = PendingSession(
      duration: _duration,
      bell: _bell,
      type: _type,
    );
    if (!mounted) return;
    context.push('/timer');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final state = ref.watch(appStateProvider).requireValue;
    _ensureInit(state);
    final matching = _matchingPreset(state);
    final canSave = matching == null;
    final bellLabel = _bell == 0 ? 'Off' : '$_bell';

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
          'Begin a session',
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
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.presets.isNotEmpty) ...[
              _SectionHeader(label: 'PRESETS'),
              for (final preset in state.presets)
                _PresetRow(
                  preset: preset,
                  selected: matching?.id == preset.id,
                  onTap: () => setState(() {
                    _duration = preset.duration;
                    _bell = preset.bell;
                    _type = preset.type;
                  }),
                ),
              const SizedBox(height: 8),
            ],
            _SectionHeader(
              label: 'SESSION',
              actionLabel: canSave ? '+ SAVE PRESET' : null,
              onAction: canSave ? _savePreset : null,
            ),
            _ConfigRow(
              label: 'Practice',
              onTap: () => _pickType(state),
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
            ),
            _ConfigRow(
              label: 'Duration',
              trailing: InlineStepper(
                value: '$_duration',
                unit: 'MIN',
                onDecrement: _duration > 1 ? _decDuration : null,
                onIncrement: _duration < 240 ? _incDuration : null,
              ),
            ),
            _ConfigRow(
              label: 'Interval bell',
              trailing: InlineStepper(
                value: bellLabel,
                unit: _bell == 0 ? null : 'MIN',
                onDecrement: _bell > 0 ? () => _stepBell(-1) : null,
                onIncrement: () => _stepBell(1),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: PrimaryButton(
                label: 'Start · $_duration min',
                onPressed: _start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader({
    required this.label,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 12, 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: p.ink3,
              letterSpacing: 2.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: p.ink3),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 2.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  final Preset preset;
  final bool selected;
  final VoidCallback onTap;
  const _PresetRow({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.lineSoft)),
        ),
        child: Row(
          children: [
            // Selection bar
            Container(
              width: 3,
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              color: selected ? p.gold : Colors.transparent,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.name,
                    style: TextStyle(
                      fontSize: 15,
                      color: selected ? p.ink : p.ink2,
                      fontWeight:
                          selected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _detail(preset),
                    style: TextStyle(fontSize: 12, color: p.ink3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _detail(Preset p) {
    final parts = <String>['${p.duration} min'];
    if (p.type != null) parts.add(p.type!);
    if (p.bell > 0) parts.add('Bell ${p.bell}m');
    return parts.join(' · ');
  }
}

class _ConfigRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;
  const _ConfigRow({
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        constraints: const BoxConstraints(minHeight: 60),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.lineSoft)),
        ),
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

class _TypePickResult {
  final String? name;
  final bool addNew;
  const _TypePickResult({this.name, this.addNew = false});
}

class _TypePickerSheet extends StatelessWidget {
  final List<String> types;
  final String? selected;
  const _TypePickerSheet({required this.types, required this.selected});

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
                padding: EdgeInsets.zero,
                children: [
                  _row(context, name: 'Any', selected: selected == null),
                  for (final t in types)
                    _row(context, name: t, selected: t == selected),
                  _addRow(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context,
      {required String name, required bool selected}) {
    final p = context.palette;
    return InkWell(
      onTap: () => Navigator.of(context)
          .pop(_TypePickResult(name: name == 'Any' ? null : name)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.lineSoft)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  color: p.ink,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (selected) Icon(Icons.check, color: p.gold, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _addRow(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: () =>
          Navigator.of(context).pop(const _TypePickResult(addNew: true)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.lineSoft)),
        ),
        child: Text(
          'Add new…',
          style: TextStyle(
            fontSize: 16,
            color: p.ink3,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
