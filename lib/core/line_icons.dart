import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 线性图标（1:1 复刻 web icons.tsx：viewBox 24、stroke 1.7、round）。
// 内部 path 用占位描边色，渲染时用 colorFilter 统一上色。
const _inner = <String, String>{
  'feed': '<path d="M4 7h16"/><path d="M4 12h16"/><path d="M4 17h10"/>',
  'market': '<path d="M3 16l5-5 4 4 7-8"/><path d="M16 7h5v5"/>',
  'trophy':
      '<path d="M7 4h10v5a5 5 0 0 1-10 0z"/><path d="M7 5H4.5v1.5A3 3 0 0 0 7.6 9.5"/><path d="M17 5h2.5v1.5A3 3 0 0 1 16.4 9.5"/><path d="M12 14v3"/><path d="M8.5 19.5h7"/>',
  'tasks': '<circle cx="12" cy="12" r="8.5"/><path d="M8 12l2.6 2.6L16 9"/>',
  'user': '<circle cx="12" cy="8" r="3.4"/><path d="M5.5 19.5c0-3.6 3-5.6 6.5-5.6s6.5 2 6.5 5.6"/>',
};

class LineIcon extends StatelessWidget {
  const LineIcon(this.name, {super.key, this.size = 22, required this.color});
  final String name;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final svg =
        '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
        '<g stroke="#000" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">'
        '${_inner[name] ?? ''}</g></svg>';
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
