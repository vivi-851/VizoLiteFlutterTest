import 'package:supabase_flutter/supabase_flutter.dart';
import 'market.dart';

// 读中文在售盘口（复用 web 的 generated_markets，anon 可读，RLS: gen_select_all）。
class FeedRepository {
  FeedRepository(this._db);
  final SupabaseClient _db;

  static const _cols =
      'id, question, category, news_headline, news_summary, news_source, news_image, news_url, init_prob, created_at';

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
}
