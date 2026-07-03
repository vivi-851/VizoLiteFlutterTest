import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'theme.dart';

// 品牌 Mark（1:1 复刻 web LogoMark）：青→蓝渐变话筒弧 + 四角星（currentColor=ink）。
const _markSvg = '''
<svg viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="vz" x1="150" y1="150" x2="380" y2="400" gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="#41D6F5"/>
      <stop offset="1" stop-color="#0EA0E9"/>
    </linearGradient>
  </defs>
  <path d="M132 150 A 240 240 0 0 0 372 390" stroke="url(#vz)" stroke-width="84"/>
  <path d="M372 120 C378 152 398 172 430 178 C398 184 378 204 372 236 C366 204 346 184 314 178 C346 172 366 152 372 120 Z" fill="currentColor"/>
</svg>
''';

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 26});
  final double size;
  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _markSvg,
      width: size,
      height: size,
      theme: const SvgTheme(currentColor: kInk),
    );
  }
}

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.wordmark = true});
  final bool wordmark;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LogoMark(size: 26),
        if (wordmark) ...[
          const SizedBox(width: 8),
          const Text('Vizo Lite',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kInk, letterSpacing: -0.2)),
        ],
      ],
    );
  }
}
