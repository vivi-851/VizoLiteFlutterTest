import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  final String id;
  final String? email;
  final int points;
  Profile({required this.id, this.email, required this.points});
  factory Profile.fromJson(Map<String, dynamic> j) =>
      Profile(id: j['id'] as String, email: j['email'] as String?, points: (j['points'] as num?)?.toInt() ?? 0);
}

class BetRow {
  final String marketTitle;
  final String outcomeLabel; // Yes / No
  final int stake;
  final num entryPrice;
  final DateTime createdAt;
  final String? genMarketId;
  BetRow({
    required this.marketTitle,
    required this.outcomeLabel,
    required this.stake,
    required this.entryPrice,
    required this.createdAt,
    this.genMarketId,
  });
  factory BetRow.fromJson(Map<String, dynamic> j) => BetRow(
        marketTitle: (j['market_title'] ?? '') as String,
        outcomeLabel: (j['outcome_label'] ?? '') as String,
        stake: (j['stake'] as num?)?.toInt() ?? 0,
        entryPrice: (j['entry_price'] as num?) ?? 0,
        createdAt: DateTime.tryParse((j['created_at'] ?? '') as String) ?? DateTime.now(),
        genMarketId: j['gen_market_id'] as String?,
      );
  // 押对可得 = 注额 / 入场价（份额 × 1 分）。
  int get payout => entryPrice <= 0 ? stake : (stake / entryPrice).round();
}

// 账户读取（自读 RLS：profiles/bets 仅本人）。
class AccountRepository {
  AccountRepository(this._db);
  final SupabaseClient _db;

  Future<Profile?> fetchProfile() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _db.from('profiles').select('id, email, points').eq('id', uid).maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  Future<List<BetRow>> fetchMyBets() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _db
        .from('bets')
        .select('market_title, outcome_label, stake, entry_price, created_at, gen_market_id')
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(30);
    return (rows as List).map((e) => BetRow.fromJson(e as Map<String, dynamic>)).toList();
  }
}
