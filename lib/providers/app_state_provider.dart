import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/storage.dart';
import '../data/streak.dart';
import '../domain/app_state.dart';
import '../domain/preset.dart';
import '../theme/palette.dart';

final storageProvider = Provider<Storage>((_) => FileStorage());

class AppStateController extends AsyncNotifier<AppState> {
  Storage get _storage => ref.read(storageProvider);

  @override
  Future<AppState> build() => _storage.load();

  Future<void> _mutate(AppState Function(AppState) updater) async {
    final current = state.valueOrNull ?? AppState.empty;
    final next = updater(current);
    state = AsyncData(next);
    await _storage.save(next);
  }

  Future<void> setTheme(AppTheme theme) => _mutate(
        (s) => s.copyWith(settings: s.settings.copyWith(theme: theme)),
      );

  Future<void> setUseSerif(bool value) => _mutate(
        (s) => s.copyWith(settings: s.settings.copyWith(useSerif: value)),
      );

  Future<void> markOnboarded() => _mutate((s) => s.copyWith(onboarded: true));

  Future<void> replace(AppState next) => _mutate((_) => next);

  Future<void> addPreset(Preset preset) =>
      _mutate((s) => s.copyWith(presets: [...s.presets, preset]));

  Future<void> removePreset(String id) => _mutate((s) =>
      s.copyWith(presets: s.presets.where((p) => p.id != id).toList()));

  Future<void> addType(String name) {
    final trimmed = name.trim();
    return _mutate((s) {
      if (trimmed.isEmpty || s.types.contains(trimmed)) return s;
      return s.copyWith(types: [...s.types, trimmed]..sort());
    });
  }

  Future<void> removeType(String name) => _mutate(
      (s) => s.copyWith(types: s.types.where((t) => t != name).toList()));

  Future<void> updateLastUsed(LastUsed last) =>
      _mutate((s) => s.copyWith(lastUsed: last));
}

final appStateProvider =
    AsyncNotifierProvider<AppStateController, AppState>(AppStateController.new);

// Convenience: themed colour palette derived from current settings.
// While loading, falls back to light to keep the splash neutral.
final paletteProvider = Provider<Palette>((ref) {
  final state = ref.watch(appStateProvider);
  return Palette.of(
    state.maybeWhen(
      data: (s) => s.settings.theme,
      orElse: () => AppTheme.light,
    ),
  );
});

final streakProvider = Provider<StreakInfo>((ref) {
  final s = ref.watch(appStateProvider).valueOrNull;
  if (s == null) {
    return const StreakInfo(streak: 0, doneToday: false);
  }
  return computeStreak(s.sessions);
});
