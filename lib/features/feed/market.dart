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
      );

  int get probPct => (((initProb ?? 0.5)) * 100).round().clamp(1, 99);
  String get title => (newsHeadline?.isNotEmpty == true) ? newsHeadline! : question;
}
