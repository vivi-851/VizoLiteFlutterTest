import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/spark.dart';
import '../../core/theme.dart';
import '../auth/auth_providers.dart';
import '../bet/bet_sheet.dart';
import '../feed/market.dart' as feed;
import 'browse.dart';
import 'markets_providers.dart';

// /markets 集合页（对齐 web：话题标签+我的 / 热门·即将结算 / 搜索 / 二元加厚卡 · 多选行式）。
class MarketsScreen extends ConsumerWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(browseFilterProvider);
    final markets = ref.watch(browseMarketsProvider);
    final session = ref.watch(sessionProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(browseMarketsProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text('市场', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kInk)),
          ),

          // 一级标签：我的 + 话题
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _CatChip(
                label: '我的',
                active: f.mine,
                mineStyle: true,
                onTap: () => ref.read(browseFilterProvider.notifier).set(f.copyWith(mine: !f.mine, cat: '全部')),
              ),
              for (final c in kMarketCategories) ...[
                const SizedBox(width: 8),
                _CatChip(
                  label: c,
                  active: !f.mine && f.cat == c,
                  onTap: () => ref.read(browseFilterProvider.notifier).set(f.copyWith(cat: c, mine: false)),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 12),

          // 控制行：排序 + 搜索
          Row(children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: const Color(0xFFECECEF), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                _SortBtn(label: '热门', active: f.sort == 'hot', onTap: () => ref.read(browseFilterProvider.notifier).set(f.copyWith(sort: 'hot'))),
                _SortBtn(label: '即将结算', active: f.sort == 'ending', onTap: () => ref.read(browseFilterProvider.notifier).set(f.copyWith(sort: 'ending'))),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  onSubmitted: (v) => ref.read(browseFilterProvider.notifier).set(f.copyWith(q: v)),
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '搜索盘口…',
                    hintStyle: const TextStyle(fontSize: 13, color: kSubtle),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),

          markets.when(
            loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Padding(padding: const EdgeInsets.all(24), child: Text('加载失败：$e')),
            data: (list) {
              if (f.mine && session == null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Column(children: [
                    const Text('登录后查看「我的」盘口', style: TextStyle(color: kSubtle)),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.push('/login'),
                      style: FilledButton.styleFrom(backgroundColor: kIndigo),
                      child: const Text('去登录'),
                    ),
                  ]),
                );
              }
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: Text('没有匹配的盘口', style: TextStyle(color: kSubtle))),
                );
              }
              return Column(children: [for (final m in list) _BrowseCard(m: m)]);
            },
          ),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({required this.label, required this.active, required this.onTap, this.mineStyle = false});
  final String label;
  final bool active;
  final bool mineStyle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final Color bg = active
        ? (mineStyle ? kIndigo : kInk)
        : (mineStyle ? kIndigo.withValues(alpha: 0.08) : Colors.white);
    final Color fg = active ? Colors.white : (mineStyle ? kIndigo : kSubtle);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? Colors.transparent : (mineStyle ? kIndigo.withValues(alpha: 0.3) : kBorder)),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg)),
      ),
    );
  }
}

class _SortBtn extends StatelessWidget {
  const _SortBtn({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8)),
          child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: active ? FontWeight.w800 : FontWeight.w500, color: active ? kInk : kSubtle)),
        ),
      );
}

class _BrowseCard extends ConsumerWidget {
  const _BrowseCard({required this.m});
  final BrowseMarket m;

  // 下注弹层要 feed.Market；用池信息重建（价格口径一致）。
  feed.Market _asFeedMarket() => feed.Market(
        id: m.id,
        question: m.question,
        poolYes: m.yesProb * m.liquidity,
        poolNo: (1 - m.yesProb) * m.liquidity,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spark = m.isBinary ? synthSpark(m.id.hashCode, m.yesProb) : const <double>[];
    final delta = m.isBinary ? ((spark.last - spark.first) * 100).round() : 0;
    final up = delta >= 0;

    return InkWell(
      onTap: () => context.push('/news/${m.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 头部：来源徽标 + 类目 + 涨跌/截止
          Row(children: [
            _Pill(text: 'AI 盘口', bg: kIndigo.withValues(alpha: 0.10), fg: kIndigo),
            const SizedBox(width: 6),
            _Pill(text: m.category, bg: const Color(0xFFF0F0F2), fg: kSubtle),
            const Spacer(),
            if (m.isBinary)
              _Pill(
                text: '${up ? '↗' : '↘'} ${delta.abs()}% 近24h',
                bg: (up ? kGreen : const Color(0xFFEF4444)).withValues(alpha: 0.10),
                fg: up ? kGreen : const Color(0xFFEF4444),
              ),
          ]),
          const SizedBox(height: 10),
          Text(m.question, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kInk, height: 1.35)),
          const SizedBox(height: 12),

          if (m.isBinary) ...[
            TrendSpark(series: spark, pct: m.yesPct),
            const SizedBox(height: 12),
            Row(children: [
              for (final o in m.outcomes.take(2)) ...[
                Expanded(
                  child: _BuyBtn(
                    o: o,
                    onTap: () => showBetSheet(context, _asFeedMarket(), o.tone == Tone.green ? 'yes' : 'no'),
                  ),
                ),
                if (o != m.outcomes[1]) const SizedBox(width: 8),
              ],
            ]),
          ] else
            Column(children: [
              for (final o in m.outcomes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: o.outcomeId == null
                        ? null
                        : () => showMultiBetSheet(context, marketId: m.id, title: m.question, outcomeId: o.outcomeId!, label: o.label, price: o.pct / 100),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(o.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: o.tone == Tone.green ? FontWeight.w800 : FontWeight.w500, color: o.tone == Tone.green ? kInk : const Color(0xFF555A60))),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: SizedBox(
                              height: 3,
                              child: LinearProgressIndicator(
                                value: o.pct / 100,
                                backgroundColor: const Color(0xFFE9E9EC),
                                valueColor: AlwaysStoppedAnimation(o.tone == Tone.green ? kGreen : const Color(0xFFA0A4AA)),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 10),
                      Text('×${o.mult}', style: const TextStyle(fontSize: 12, color: kSubtle)),
                      const SizedBox(width: 8),
                      Container(
                        width: 56,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: o.tone == Tone.green ? kGreen.withValues(alpha: 0.5) : kBorder, width: 1.5),
                        ),
                        child: Text('${o.pct}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: o.tone == Tone.green ? kGreen : const Color(0xFF555A60))),
                      ),
                    ]),
                  ),
                ),
            ]),

          // meta footer
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEFEFF1)))),
            child: Row(children: [
              Text('流动性 ${_fmtNum(m.liquidity.round())} 分', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF555A60))),
              const Spacer(),
              Text(
                [if (!m.isBinary) '${m.outcomes.length} 选项', if (m.endDate != null) '${m.endDate!} 截止'].join(' · '),
                style: const TextStyle(fontSize: 11, color: kSubtle),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

String _fmtNum(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
      );
}

class _BuyBtn extends StatelessWidget {
  const _BuyBtn({required this.o, required this.onTap});
  final BrowseOutcome o;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = o.tone == Tone.green ? kGreen : const Color(0xFFEF4444);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(o.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          Row(children: [
            Text('×${o.mult}', style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7))),
            const SizedBox(width: 6),
            Text('${o.pct}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
          ]),
        ]),
      ),
    );
  }
}
