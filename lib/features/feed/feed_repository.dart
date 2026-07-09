import 'package:supabase_flutter/supabase_flutter.dart';
import 'market.dart';

// 读中文在售盘口（复用 web 的 generated_markets，anon 可读，RLS: gen_select_all）。
class FeedRepository {
  FeedRepository(this._db);
  final SupabaseClient _db;

  static const _cols =
      'id, question, category, news_headline, news_summary, news_source, news_image, news_url, init_prob, pool_yes, pool_no, kind, created_at';

  Future<List<Market>> fetchFeed({int limit = 20, int offset = 0}) async {
    final rows = await _db
        .from('generated_markets')
        .select(_cols)
        .eq('lang', 'zh')
        .eq('status', 'open')
        .eq('hidden', false)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return (rows as List)
        .map((e) => Market.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Market?> fetchOne(String id) async {
    final row = await _db
        .from('generated_markets')
        .select(_cols)
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Market.fromJson(row);
  }

  // 多选盘口候选项（公开可读 gmo_select_all）。
  Future<List<Outcome>> fetchOutcomes(String marketId) async {
    final rows = await _db
        .from('generated_market_outcomes')
        .select('id, idx, label, pool')
        .eq('market_id', marketId)
        .order('idx', ascending: true);
    return (rows as List).map((e) => Outcome.fromJson(e as Map<String, dynamic>)).toList();
  }
}
