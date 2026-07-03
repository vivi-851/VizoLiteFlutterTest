import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme.dart';
import '../auth/auth_providers.dart';

// 我的（切片占位）：登录态显示邮箱 + 退出；未登录引导登录。持仓/战绩切片三接入。
class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Center(
        child: session == null
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('登录后赚积分、做任务、冲榜', style: TextStyle(color: kSubtle)),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => context.push('/login'),
                  style: FilledButton.styleFrom(backgroundColor: kIndigo),
                  child: const Text('登录 / 注册'),
                ),
              ])
            : Column(mainAxisSize: MainAxisSize.min, children: [
                const CircleAvatar(radius: 28, backgroundColor: kIndigo, child: Icon(Icons.person, color: Colors.white)),
                const SizedBox(height: 10),
                Text(session.user.email ?? '已登录', style: const TextStyle(fontWeight: FontWeight.w700, color: kInk)),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () => Supabase.instance.client.auth.signOut(),
                  child: const Text('退出登录'),
                ),
                const SizedBox(height: 8),
                const Text('持仓 / 战绩 · 切片三接入', style: TextStyle(fontSize: 12, color: kSubtle)),
              ]),
      ),
    );
  }
}
