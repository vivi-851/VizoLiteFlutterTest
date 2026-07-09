import 'package:supabase_flutter/supabase_flutter.dart';

// /markets 数据层（对齐 web lib/markets.ts 的 AI 部分）。
// 注：Polymarket 混排走 web 服务端外部 API，App 端暂只展示 AI 盘口。

const kMarketCategories = ['全部', '政治', '财经', '加密', '体育', '科技', '游戏', '娱乐'];

enum Tone { green, red, gray }

class BrowseOutcome {
  final String label;
  final int pct;
  final double mult; // 押对可得倍数 = 1/价格
  final Tone tone;
  final String? outcomeId; // 多选档 id（下注用）；二元为 null
  BrowseOutcome({required this.label, required this.pct, required this.mult, required this.tone, this.outcomeId});
}

class BrowseMarket {
  final String id;
  final String category;
  final String question;
  final String? endDate;
  final bool isBinary;
  final int yesPct;
  final double yesProb;
  final List<BrowseOutcome> outcomes;
  final num liquidity; // 积分池
  BrowseMarket({
    required this.id,
    required this.category,
    required this.question,
    required this.endDate,
    required this.isBinary,
    required this.yesPct,
    required this.yesProb,
    required this.outcomes,
    required this.liquidity,
  });
}

class BrowseFilter {
  final String cat;
  final String sort; // hot | ending
  final String q;
  final bool mine;
  const BrowseFilter({this.cat = '全部', this.sort = 'hot', this.q = '', this.mine = false});
  BrowseFilter copyWith({String? cat, String? sort, String? q, bool? mine}) =>
      BrowseFilter(cat: cat ?? this.cat, sort: sort ?? this.sort, q: q ?? this.q, mine: mine ?? this.mine);
}

double _mult(double price) => price <= 0 ? 1 : (1 / price * 10).round() / 10;

class MarketsRepository {
  MarketsRepository(this._db);
  final SupabaseClient _db;

  Future<List<BrowseMarket>> fetchBrowse(BrowseFilter f) async {
    final rows = await _db
        .from('generated_markets')
        .select('id, question, category, end_date, pool_yes, pool_no, kind, event_key, news_headline, created_at')
        .eq('lang', 'zh')
        .eq('status', 'open')
        .eq('hidden', false)
        .order('created_at', ascending: false)
        .limit(60);
    final list = (rows as List).cast<Map<String, dynamic>>();

    // 多档盘口候选项（批量一次）
    final multiIds = [
      for (final r in list)
        if (r['kind'] == 'multi' || r['kind'] == 'range') r['id'] as String,
    ];
    final ocMap = <String, List<Map<String, dynamic>>>{};
    if (multiIds.isNotEmpty) {
      final ocs = await _db
          .from('generated_market_outcomes')
          .select('id, market_id, idx, label, pool')
          .inFilter('market_id', multiIds)
          .order('idx', ascending: true);
      for (final o in (ocs as List).cast<Map<String, dynamic>>()) {
        ocMap.putIfAbsent(o['market_id'] as String, () => []).add(o);
      }
    }

    // 「我的」= 本人未平仓 AI 盘口
    Set<String>? mineIds;
    if (f.mine) {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) return [];
      final bets = await _db.from('bets').select('gen_market_id').eq('user_id', uid).not('gen_market_id', 'is', null);
      mineIds = {for (final b in (bets as List).cast<Map<String, dynamic>>()) b['gen_market_id'] as String};
    }

    // 事件级去重 + 组装
    final seen = <String>{};
    final out = <BrowseMarket>[];
    for (final r in list) {
      final key = (r['event_key'] as String?) ??
          ((r['news_headline'] ?? r['question'] ?? r['id']) as String).replaceAll(RegExp(r'\s+'), '').substring(0);
      if (seen.contains(key)) continue;
      seen.add(key);

      final id = r['id'] as String;
      if (mineIds != null && !mineIds.contains(id)) continue;

      final ocs = ocMap[id];
      if ((r['kind'] == 'multi' || r['kind'] == 'range') && ocs != null && ocs.length >= 2) {
        final total = ocs.fold<num>(0, (s, o) => s + (o['pool'] as num? ?? 0));
        var best = -1.0;
        for (final o in ocs) {
          final p = total > 0 ? (o['pool'] as num) / total : 0.0;
          if (p > best) best = p.toDouble();
        }
        out.add(BrowseMarket(
          id: id,
          category: (r['category'] ?? '其他') as String,
          question: (r['question'] ?? '') as String,
          endDate: r['end_date'] as String?,
          isBinary: false,
          yesPct: 0,
          yesProb: 0.5,
          liquidity: total,
          outcomes: [
            for (final o in ocs)
              () {
                final p = total > 0 ? ((o['pool'] as num) / total).toDouble() : 0.5;
                return BrowseOutcome(
                  label: (o['label'] ?? '') as String,
                  pct: (p * 100).round(),
                  mult: _mult(p),
                  tone: p >= best ? Tone.green : Tone.gray,
                  outcomeId: o['id'] as String,
                );
              }(),
          ],
        ));
      } else {
        final py = (r['pool_yes'] as num?) ?? 1;
        final pn = (r['pool_no'] as num?) ?? 1;
        final total = py + pn;
        final yes = total > 0 ? (py / total).toDouble() : 0.5;
        out.add(BrowseMarket(
          id: id,
          category: (r['category'] ?? '其他') as String,
          question: (r['question'] ?? '') as String,
          endDate: r['end_date'] as String?,
          isBinary: true,
          yesPct: (yes * 100).round().clamp(1, 99),
          yesProb: yes,
          liquidity: total,
          outcomes: [
            BrowseOutcome(label: '会发生', pct: (yes * 100).round(), mult: _mult(yes), tone: Tone.green),
            BrowseOutcome(label: '不会', pct: ((1 - yes) * 100).round(), mult: _mult(1 - yes), tone: Tone.red),
          ],
        ));
      }
    }

    // 筛选 + 排序
    var res = out;
    if (f.cat != '全部' && !f.mine) res = res.where((m) => m.category == f.cat).toList();
    if (f.q.trim().isNotEmpty) res = res.where((m) => m.question.contains(f.q.trim())).toList();
    if (f.sort == 'ending') {
      res.sort((a, b) => (a.endDate ?? '9999').compareTo(b.endDate ?? '9999'));
    } else {
      res.sort((a, b) => b.liquidity.compareTo(a.liquidity)); // 热门 ≈ 池子深
    }
    return res;
  }
}
