import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_header.dart';
import 'line_icons.dart';
import 'theme.dart';

// 全局壳：顶栏 + 底部 5 tab（对齐 web MobileTabBar：要闻/市场/锦标赛/任务/我的）。
class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    ('/feed', 'feed', '要闻'),
    ('/markets', 'market', '市场'),
    ('/tournaments', 'trophy', '锦标赛'),
    ('/tasks', 'tasks', '任务'),
    ('/me', 'user', '我的'),
  ];

  int _index(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    final i = _tabs.indexWhere((t) => loc.startsWith(t.$1));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final current = _index(context);
    return Scaffold(
      appBar: const VizoAppBar(),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _TabItem(
                      icon: _tabs[i].$2,
                      label: _tabs[i].$3,
                      active: i == current,
                      onTap: () => context.go(_tabs[i].$1),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.icon, required this.label, required this.active, required this.onTap});
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? kIndigo : const Color(0xFF9AA0A6);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LineIcon(icon, size: 22, color: color),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}
