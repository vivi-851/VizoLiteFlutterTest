import 'package:supabase_flutter/supabase_flutter.dart';

// 下注（二元盘口）：走 place_gen_bet(p_gen_id, p_side, p_stake) → 返回更新后的 profiles。
class BetRepository {
  BetRepository(this._db);
  final SupabaseClient _db;

  // 返回下注后的最新积分。异常向上抛（未登录/积分不足/已封盘等）。
  Future<int> placeBet({required String genId, required String side, required int stake}) async {
    final row = await _db.rpc('place_gen_bet', params: {
      'p_gen_id': genId,
      'p_side': side,
      'p_stake': stake,
    });
    return _points(row);
  }

  // 多选盘口下注：place_gen_bet_multi(p_outcome_id, p_stake)。
  Future<int> placeMultiBet({required String outcomeId, required int stake}) async {
    final row = await _db.rpc('place_gen_bet_multi', params: {
      'p_outcome_id': outcomeId,
      'p_stake': stake,
    });
    return _points(row);
  }

  int _points(dynamic row) {
    final map = row is List ? (row.first as Map<String, dynamic>) : (row as Map<String, dynamic>);
    return (map['points'] as num?)?.toInt() ?? 0;
  }
}
