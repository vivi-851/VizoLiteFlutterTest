import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme.dart';
import '../account/account.dart';
import '../account/account_providers.dart';
import '../auth/auth_providers.dart';

// 我的：登录态显示积分 + 持仓/战绩（本人 bets）；未登录引导登录。
class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (session == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('登录后赚积分、做任务、冲榜', style: TextStyle(color: kSubtle)),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => context.push('/login'),
            style: FilledButton.styleFrom(backgroundColor: kIndigo),
            child: const Text('登录 / 注册'),
          ),
        ]),
      );
    }

    final profile = ref.watch(profileProvider);
    final bets = ref.watch(myBetsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(profileProvider);
        ref.invalidate(myBetsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 积分头卡
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kIndigo, kViolet]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const CircleAvatar(radius: 24, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(session.user.email ?? '已登录', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.value?.points ?? '—'} 积分',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ]),
              ),
              TextButton(
                onPressed: () => Supabase.instance.client.auth.signOut(),
                child: const Text('退出', style: TextStyle(color: Colors.white70)),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('我的持仓 / 战绩', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kInk)),
          const SizedBox(height: 10),
          bets.when(
            loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('加载失败：$e', style: const TextStyle(color: kSubtle)),
            data: (list) => list.isEmpty
                ? const Padding(padding: EdgeInsets.symmetric(vertical: 28), child: Center(child: Text('还没有下注 · 去要闻挑一个盘口', style: TextStyle(color: kSubtle))))
                : Column(children: [for (final b in list) _BetTile(b)]),
          ),
        ],
      ),
    );
  }
}

class _BetTile extends StatelessWidget {
  const _BetTile(this.b);
  final BetRow b;
  @override
  Widget build(BuildContext context) {
    final yes = b.outcomeLabel.toLowerCase() == 'yes';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(b.marketTitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: kInk, height: 1.3)),
        const SizedBox(height: 8),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: (yes ? kGreen : const Color(0xFF64748B)).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
            child: Text(yes ? '会发生' : '不会', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: yes ? kGreen : const Color(0xFF64748B))),
          ),
          const SizedBox(width: 8),
          Text('${b.stake} 分', style: const TextStyle(fontSize: 12.5, color: kSubtle)),
          const Spacer(),
          Text('押对可得 ${b.payout}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: kGreen)),
        ]),
      ]),
    );
  }
}
