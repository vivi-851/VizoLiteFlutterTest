import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import 'feed_providers.dart';
import 'market.dart';

// 信息流：读中文在售盘口，卡片列表，点卡进详情。
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text('要闻', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: () => context.push('/login'), icon: const Icon(Icons.person_outline)),
          const SizedBox(width: 8),
        ],
      ),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('加载失败：$e'))),
        data: (items) => RefreshIndicator(
          onRefresh: () async => ref.refresh(feedProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _MarketCard(m: items[i]),
          ),
        ),
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  const _MarketCard({required this.m});
  final Market m;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/news/${m.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.newsImage != null && m.newsImage!.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(m.newsImage!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: kBg)),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    if (m.category != null) _Chip(m.category!),
                    const Spacer(),
                    if (m.newsSource != null) Text(m.newsSource!, style: const TextStyle(fontSize: 11, color: kSubtle)),
                  ]),
                  const SizedBox(height: 8),
                  Text(m.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: kInk, height: 1.3)),
                  const SizedBox(height: 10),
                  Row(children: [
                    _ProbBadge(pct: m.probPct),
                    const SizedBox(width: 8),
                    const Text('会发生?', style: TextStyle(fontSize: 12, color: kSubtle)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: kIndigo.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kIndigo)),
      );
}

class _ProbBadge extends StatelessWidget {
  const _ProbBadge({required this.pct});
  final int pct;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kIndigo, kViolet]),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text('$pct%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
      );
}
