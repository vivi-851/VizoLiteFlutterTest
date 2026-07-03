import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme.dart';

// 登录（邮箱 OTP / magic link 骨架）。魔法链接需真实邮箱收信 → 完整回跳在真机验证。
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  bool _busy = false;
  String? _msg;

  Future<void> _sendLink() async {
    final email = _email.text.trim();
    if (email.isEmpty) return;
    setState(() { _busy = true; _msg = null; });
    try {
      await Supabase.instance.client.auth.signInWithOtp(email: email);
      setState(() => _msg = '已发送登录链接到 $email，去邮箱点开完成登录');
    } catch (e) {
      setState(() => _msg = '发送失败：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录'), leading: BackButton(onPressed: () => context.go('/feed'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('登录 Vizo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kInk)),
                const SizedBox(height: 6),
                const Text('赚积分、做任务、冲榜', style: TextStyle(color: kSubtle)),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: '邮箱', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _busy ? null : _sendLink,
                  style: FilledButton.styleFrom(backgroundColor: kIndigo, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _busy ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('发送登录链接'),
                ),
                if (_msg != null) Padding(padding: const EdgeInsets.only(top: 14), child: Text(_msg!, style: const TextStyle(color: kIndigo))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
