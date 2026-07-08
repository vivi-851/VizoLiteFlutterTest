import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_providers.dart';
import 'account.dart';

final accountRepoProvider = Provider<AccountRepository>((ref) => AccountRepository(Supabase.instance.client));

// 随登录态变化重取（登录/退出/下注后 invalidate 均刷新）。
final profileProvider = FutureProvider<Profile?>((ref) {
  ref.watch(sessionProvider);
  return ref.read(accountRepoProvider).fetchProfile();
});

final myBetsProvider = FutureProvider<List<BetRow>>((ref) {
  ref.watch(sessionProvider);
  return ref.read(accountRepoProvider).fetchMyBets();
});
