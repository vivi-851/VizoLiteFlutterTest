import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_providers.dart';
import 'browse.dart';

final marketsRepoProvider = Provider<MarketsRepository>((ref) => MarketsRepository(Supabase.instance.client));

// 筛选状态（话题 / 排序 / 搜索 / 我的）。
class BrowseFilterNotifier extends Notifier<BrowseFilter> {
  @override
  BrowseFilter build() => const BrowseFilter();
  void set(BrowseFilter f) => state = f;
}

final browseFilterProvider = NotifierProvider<BrowseFilterNotifier, BrowseFilter>(BrowseFilterNotifier.new);

final browseMarketsProvider = FutureProvider<List<BrowseMarket>>((ref) {
  ref.watch(sessionProvider); // 「我的」随登录态变化
  final f = ref.watch(browseFilterProvider);
  return ref.read(marketsRepoProvider).fetchBrowse(f);
});
