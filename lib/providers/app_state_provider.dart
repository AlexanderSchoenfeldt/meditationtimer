import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/storage.dart';
import '../data/streak.dart';
import '../domain/app_state.dart';
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
