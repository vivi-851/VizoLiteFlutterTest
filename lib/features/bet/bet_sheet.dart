import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme.dart';
import '../account/account_providers.dart';
import '../auth/auth_providers.dart';
import '../feed/feed_providers.dart';
import '../feed/market.dart';
import 'bet_repository.dart';

final betRepoProvider = Provider<BetRepository>((ref) => BetRepository(Supabase.instance.client));

// 打开下注弹层。多选盘口暂不支持（切片后续）。
void showBetSheet(BuildContext context, Market market, String side) {
  if (market.isMulti) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('多选盘口下注切片后续接入')));
    return;
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _BetSheet(market: market, initialSide: side),
  );
}

const _amounts = [50, 100, 200, 500];

class _BetSheet extends ConsumerStatefulWidget {
  const _BetSheet({required this.market, required this.initialSide});
  final Market market;
  final String initialSide;
  @override
  ConsumerState<_BetSheet> createState() => _BetSheetState();
}

class _BetSheetState extends ConsumerState<_BetSheet> {
  late String _side = widget.initialSide;
  int _stake = 100;
  bool _busy = false;
  String? _error;

  Future<void> _confirm() async {
    setState(() { _busy = true; _error = null; });
    try {
      final points = await ref.read(betRepoProvider).placeBet(genId: widget.market.id, side: _side, stake: _stake);
      ref.invalidate(profileProvider);
      ref.invalidate(myBetsProvider);
      ref.invalidate(feedProvider);
      ref.invalidate(marketProvider(widget.market.id));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('下注成功 · 余额 $points 分')));
    } catch (e) {
      final msg = e.toString();
      setState(() => _error = msg.contains('insufficient') ? '积分不足' : msg.contains('closed') ? '盘口已封盘' : '下注失败：$msg');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final m = widget.market;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(999)))),
          const SizedBox(height: 16),
          Text(m.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: kInk, height: 1.3)),
          const SizedBox(height: 16),

          if (session == null) ...[
            const Text('登录后即可下注', style: TextStyle(color: kSubtle)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () { Navigator.of(context).pop(); context.push('/login'); },
              style: FilledButton.styleFrom(backgroundColor: kIndigo, padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('去登录'),
            ),
          ] else ...[
            // 选边
            Row(children: [
              Expanded(child: _SideBtn(label: '会发生', pct: (m.price('yes') * 100).round(), color: kGreen, active: _side == 'yes', onTap: () => setState(() => _side = 'yes'))),
              const SizedBox(width: 10),
              Expanded(child: _SideBtn(label: '不会', pct: (m.price('no') * 100).round(), color: const Color(0xFF64748B), active: _side == 'no', onTap: () => setState(() => _side = 'no'))),
            ]),
            const SizedBox(height: 16),
            // 金额
            const Text('下注金额', style: TextStyle(fontSize: 12.5, color: kSubtle)),
            const SizedBox(height: 8),
            Row(children: [
              for (final a in _amounts) ...[
                Expanded(child: _AmountChip(amount: a, active: _stake == a, onTap: () => setState(() => _stake = a))),
                if (a != _amounts.last) const SizedBox(width: 8),
              ],
            ]),
            const SizedBox(height: 16),
            // 押对可得 + 余额
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Text('押对可得', style: TextStyle(color: kSubtle, fontSize: 13)),
                const Spacer(),
                Text('${m.payout(_side, _stake).round()} 分', style: const TextStyle(fontWeight: FontWeight.w800, color: kGreen, fontSize: 16)),
              ]),
            ),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _confirm,
              style: FilledButton.styleFrom(backgroundColor: kInk, padding: const EdgeInsets.symmetric(vertical: 15)),
              child: _busy
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('确认下注 · $_stake 分', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ],
      ),
    );
  }
}

class _SideBtn extends StatelessWidget {
  const _SideBtn({required this.label, required this.pct, required this.color, required this.active, required this.onTap});
  final String label;
  final int pct;
  final Color color;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? color : kBorder, width: active ? 1.5 : 1),
        ),
        child: Column(children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: active ? color : kInk)),
          const SizedBox(height: 2),
          Text('$pct%', style: TextStyle(fontSize: 12, color: active ? color : kSubtle)),
        ]),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({required this.amount, required this.active, required this.onTap});
  final int amount;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? kInk : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? kInk : kBorder),
        ),
        child: Text('$amount', style: TextStyle(fontWeight: FontWeight.w700, color: active ? Colors.white : kInk)),
      ),
    );
  }
}
