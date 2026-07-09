// 盘口/新闻卡数据模型（映射 generated_markets 子集）。
class Market {
  final String id;
  final String question;
  final String? category;
  final String? newsHeadline;
  final String? newsSummary;
  final String? newsSource;
  final String? newsImage;
  final String? newsUrl;
  final num? initProb;
  final num poolYes;
  final num poolNo;
  final String? kind;

  Market({
    required this.id,
    required this.question,
    this.category,
    this.newsHeadline,
    this.newsSummary,
    this.newsSource,
    this.newsImage,
    this.newsUrl,
    this.initProb,
    this.poolYes = 1,
    this.poolNo = 1,
    this.kind,
  });

  factory Market.fromJson(Map<String, dynamic> j) => Market(
        id: j['id'] as String,
        question: (j['question'] ?? '') as String,
        category: j['category'] as String?,
        newsHeadline: j['news_headline'] as String?,
        newsSummary: j['news_summary'] as String?,
        newsSource: j['news_source'] as String?,
        newsImage: j['news_image'] as String?,
        newsUrl: j['news_url'] as String?,
        initProb: j['init_prob'] as num?,
        poolYes: (j['pool_yes'] as num?) ?? 1,
        poolNo: (j['pool_no'] as num?) ?? 1,
        kind: j['kind'] as String?,
      );

  bool get isMulti => kind == 'multi';

  // 当前隐含概率（成交价口径，与 place_gen_bet 一致）：pool_yes/(pool_yes+pool_no)。
  double get prob {
    final total = poolYes + poolNo;
    if (total <= 0) return (initProb ?? 0.5).toDouble();
    return poolYes / total;
  }

  int get probPct => (prob * 100).round().clamp(1, 99);

  // 某一边的成交价（= 该边池 / 总池）。
  double price(String side) {
    final total = poolYes + poolNo;
    if (total <= 0) return 0.5;
    return side == 'yes' ? poolYes / total : poolNo / total;
  }

  // 押对可得 = 注额 / 价格（每份额结算 1 分）。
  double payout(String side, int stake) {
    final p = price(side);
    return p <= 0 ? stake.toDouble() : stake / p;
  }

  String get title => (newsHeadline?.isNotEmpty == true) ? newsHeadline! : question;
}

// 多选盘口候选项（generated_market_outcomes）。
class Outcome {
  final String id;
  final int idx;
  final String label;
  final num pool;
  Outcome({required this.id, required this.idx, required this.label, required this.pool});
  factory Outcome.fromJson(Map<String, dynamic> j) => Outcome(
        id: j['id'] as String,
        idx: (j['idx'] as num?)?.toInt() ?? 0,
        label: (j['label'] ?? '') as String,
        pool: (j['pool'] as num?) ?? 1,
      );
}

