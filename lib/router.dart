import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/placeholders.dart';
import 'screens/setup_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
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
  ],
);
