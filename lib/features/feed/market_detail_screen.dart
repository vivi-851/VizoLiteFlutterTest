import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import 'feed_providers.dart';

// 盘口详情（切片版：题面 + 概率 + 摘要 + 来源；下注为占位，交易 RPC 后续接）。
class MarketDetailScreen extends ConsumerWidget {
  const MarketDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(marketProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('盘口详情')),
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
              Row(children: [
                Expanded(child: _BetButton(label: '会发生', color: kGreen)),
                const SizedBox(width: 12),
                Expanded(child: _BetButton(label: '不会', color: const Color(0xFF64748B))),
              ]),
              const SizedBox(height: 8),
              const Center(child: Text('下注为占位 · 交易 RPC 切片二接入', style: TextStyle(fontSize: 12, color: kSubtle))),
            ],
          );
        },
      ),
    );
  }
}

class _BetButton extends StatelessWidget {
  const _BetButton({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('交易将在切片二接入'))),
        style: FilledButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 16)),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      );
}
