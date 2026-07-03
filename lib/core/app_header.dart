import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'brand.dart';
import 'theme.dart';
import '../features/auth/auth_providers.dart';

// 全局顶栏（对齐 web AppHeader 移动态）：logo 左，登录/头像 右，白底 + 底边。
class VizoAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const VizoAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return AppBar(
      titleSpacing: 16,
      centerTitle: false,
      title: GestureDetector(onTap: () => context.go('/feed'), child: const BrandLogo()),
      shape: const Border(bottom: BorderSide(color: kBorder)),
      actions: [
        if (session == null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => context.push('/login'),
              style: TextButton.styleFrom(
                backgroundColor: kInk,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('登录', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.go('/me'),
              child: const CircleAvatar(radius: 15, backgroundColor: kIndigo, child: Icon(Icons.person, size: 18, color: Colors.white)),
            ),
          ),
      ],
    );
  }
}
