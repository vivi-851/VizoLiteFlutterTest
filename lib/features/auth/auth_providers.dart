import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 会话状态：监听 Supabase 鉴权变化，暴露当前 session。
final authChangeProvider = StreamProvider<AuthState>(
    (ref) => Supabase.instance.client.auth.onAuthStateChange);

final sessionProvider = Provider<Session?>((ref) {
  ref.watch(authChangeProvider); // 变化时重算
  return Supabase.instance.client.auth.currentSession;
});
