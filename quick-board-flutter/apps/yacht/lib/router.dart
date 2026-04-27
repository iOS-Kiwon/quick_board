import 'package:go_router/go_router.dart';
import 'screens/setup_screen.dart';
import 'screens/score_screen.dart';
import 'screens/result_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: '/score',
      builder: (context, state) => const ScoreScreen(),
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) => const ResultScreen(),
    ),
  ],
);
