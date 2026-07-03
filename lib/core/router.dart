import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'scaffold_with_nav.dart';
import '../features/feed/feed_screen.dart';
import '../features/feed/market_detail_screen.dart';
import '../features/me/me_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/common/placeholder_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/feed',
    routes: [
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNav(child: child),
        routes: [
          GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
          GoRoute(path: '/markets', builder: (_, __) => const PlaceholderScreen(icon: 'market', title: '市场', slice: '盘口集合')),
          GoRoute(path: '/tournaments', builder: (_, __) => const PlaceholderScreen(icon: 'trophy', title: '锦标赛', slice: '锦标赛/拆题竞猜')),
          GoRoute(path: '/tasks', builder: (_, __) => const PlaceholderScreen(icon: 'tasks', title: '任务', slice: '每日任务')),
          GoRoute(path: '/me', builder: (_, __) => const MeScreen()),
        ],
      ),
      GoRoute(path: '/news/:id', builder: (_, s) => MarketDetailScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    ],
  );
});
