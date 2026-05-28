import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/app_state_provider.dart';
import 'screens/complete_screen.dart';
import 'screens/data_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/placeholders.dart';
import 'screens/recovery_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/timer_screen.dart';

final _routes = [
  GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
  GoRoute(path: '/setup', builder: (_, _) => const SetupScreen()),
  GoRoute(path: '/timer', builder: (_, _) => const TimerScreen()),
  GoRoute(path: '/complete', builder: (_, _) => const CompleteScreen()),
  GoRoute(path: '/stats', builder: (_, _) => const StatsScreen()),
  GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
  GoRoute(path: '/data', builder: (_, _) => const DataScreen()),
  GoRoute(path: '/recovery', builder: (_, _) => const RecoveryScreen()),
  GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
  GoRoute(path: '/open-sit', builder: (_, _) => const OpenSitScreen()),
];

GoRouter buildRouter({String initial = '/'}) =>
    GoRouter(initialLocation: initial, routes: _routes);

final routerProvider = Provider<GoRouter>((ref) {
  // Read once at construction time. We only need the initial location;
  // after that go_router owns navigation. If we watch instead of read,
  // any AppState mutation would rebuild the router and reset the stack.
  final initial = ref.read(appStateProvider).maybeWhen(
        data: (s) => s.onboarded ? '/' : '/onboarding',
        orElse: () => '/',
      );
  return buildRouter(initial: initial);
});
