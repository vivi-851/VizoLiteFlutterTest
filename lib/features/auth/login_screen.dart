import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme.dart';

// 登录：邮箱验证码(OTP code)两步——发码 → 输 6 位码 → verifyOTP。
// 不依赖深链回跳，原生/Web 都可完成登录（比 magic link 更适合 App）。
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _sent = false;
  bool _busy = false;
  String? _msg;

  SupabaseClient get _sb => Supabase.instance.client;

  Future<void> _sendCode() async {
    final email = _email.text.trim();
    if (email.isEmpty) return;
    setState(() { _busy = true; _msg = null; });
    try {
      await _sb.auth.signInWithOtp(email: email, shouldCreateUser: true);
      setState(() { _sent = true; _msg = '验证码已发到 $email，查收邮件填入下方'; });
    } catch (e) {
      setState(() => _msg = '发送失败：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final email = _email.text.trim();
    final code = _code.text.trim();
    if (code.isEmpty) return;
    setState(() { _busy = true; _msg = null; });
    try {
      await _sb.auth.verifyOTP(email: email, token: code, type: OtpType.email);
      if (!mounted) return;
      context.go('/feed'); // 会话已建立，回首页
    } catch (e) {
      setState(() => _msg = '验证失败：验证码错误或已过期');
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
                const Text('邮箱验证码登录 · 免密码', style: TextStyle(color: kSubtle)),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  enabled: !_sent,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: '邮箱', border: OutlineInputBorder()),
                ),
                if (_sent) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _code,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '6 位验证码', border: OutlineInputBorder()),
                  ),
                ],
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _busy ? null : (_sent ? _verify : _sendCode),
                  style: FilledButton.styleFrom(backgroundColor: kIndigo, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _busy
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_sent ? '验证并登录' : '发送验证码'),
                ),
                if (_sent)
                  TextButton(
                    onPressed: _busy ? null : () => setState(() { _sent = false; _code.clear(); _msg = null; }),
                    child: const Text('换个邮箱'),
                  ),
                if (_msg != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_msg!, style: const TextStyle(color: kIndigo, fontSize: 13))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
