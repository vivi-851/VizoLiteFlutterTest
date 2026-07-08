import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../bet/bet_sheet.dart';
import 'feed_providers.dart';
import 'market.dart';

// 信息流：读中文在售盘口，卡片列表，点卡进详情。顶栏/底栏由外壳 ScaffoldWithNav 提供。
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);
    return feed.when(
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
                    const SizedBox(width: 12),
                    Expanded(child: SizedBox(height: 26, child: CustomPaint(painter: _Spark(seed: m.id.hashCode, end: m.prob), size: Size.infinite))),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _QuickBet(label: '会发生', color: kGreen, onTap: () => showBetSheet(context, m, 'yes'))),
                    const SizedBox(width: 8),
                    Expanded(child: _QuickBet(label: '不会', color: const Color(0xFF64748B), onTap: () => showBetSheet(context, m, 'no'))),
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

// 内嵌快速下注按钮（点它下注，不触发卡片跳转）。
class _QuickBet extends StatelessWidget {
  const _QuickBet({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ),
      );
}

// 合成走势曲线（确定性随机游走，终点=当前概率），复刻 web 的 genSpark 观感。
class _Spark extends CustomPainter {
  _Spark({required this.seed, required this.end});
  final int seed;
  final double end;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 20;
    final rnd = math.Random(seed);
    final ys = <double>[];
    double v = (end + (rnd.nextDouble() - 0.5) * 0.3).clamp(0.1, 0.9);
    for (var i = 0; i < n; i++) {
      v = (v + (rnd.nextDouble() - 0.5) * 0.12).clamp(0.08, 0.92);
      ys.add(v);
    }
    ys[n - 1] = end.clamp(0.05, 0.95); // 终点=真实概率
    final path = Path();
    for (var i = 0; i < n; i++) {
      final x = size.width * i / (n - 1);
      final y = size.height * (1 - ys[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final up = ys.last >= ys.first;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = up ? kGreen : const Color(0xFFEF4444);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_Spark old) => old.seed != seed || old.end != end;
}
