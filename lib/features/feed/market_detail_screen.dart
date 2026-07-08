import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../account/account_providers.dart';
import '../bet/bet_sheet.dart';
import 'feed_providers.dart';

// 盘口详情：题面 + 概率 + 摘要 + 来源 + 真下注（会发生/不会 → 下注弹层）。
class MarketDetailScreen extends ConsumerWidget {
  const MarketDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(marketProvider(id));
    final profile = ref.watch(profileProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('盘口详情'),
        actions: [
          if (profile != null)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(child: Text('${profile.points} 分', style: const TextStyle(fontWeight: FontWeight.w800, color: kIndigo))),
            ),
        ],
      ),
      body: m.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (market) {
          if (market == null) return const Center(child: Text('盘口不存在'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (market.newsImage != null && market.newsImage!.isNotEmpty)
                ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(market.newsImage!, errorBuilder: (_, __, ___) => const SizedBox())),
              const SizedBox(height: 14),
              Text(market.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kInk, height: 1.3)),
              const SizedBox(height: 12),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [kIndigo, kViolet]), borderRadius: BorderRadius.circular(999)),
                  child: Text('当前 ${market.probPct}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                if (market.newsSource != null) Text(market.newsSource!, style: const TextStyle(color: kSubtle)),
              ]),
              const SizedBox(height: 16),
              Text(market.question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kInk)),
              if (market.newsSummary != null) ...[
                const SizedBox(height: 12),
                Text(market.newsSummary!, style: const TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.55)),
              ],
              const SizedBox(height: 24),
              if (market.isMulti)
                const Center(child: Text('多选盘口 · 下注切片后续接入', style: TextStyle(fontSize: 13, color: kSubtle)))
              else
                Row(children: [
                  Expanded(child: _BetButton(label: '会发生', pct: (market.price('yes') * 100).round(), color: kGreen, onTap: () => showBetSheet(context, market, 'yes'))),
                  const SizedBox(width: 12),
                  Expanded(child: _BetButton(label: '不会', pct: (market.price('no') * 100).round(), color: const Color(0xFF64748B), onTap: () => showBetSheet(context, market, 'no'))),
                ]),
            ],
          );
        },
      ),
    );
  }
}

class _BetButton extends StatelessWidget {
  const _BetButton({required this.label, required this.pct, required this.color, required this.onTap});
  final String label;
  final int pct;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14)),
        child: Column(children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          Text('$pct%', style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ]),
      );
}
