import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 设计 tokens（对齐 web）：ink / indigo→violet / amber / 卡边 / 底色。
const kInk = Color(0xFF0D0D0D);
const kIndigo = Color(0xFF6366F1);
const kViolet = Color(0xFF8B5CF6);
const kGreen = Color(0xFF16A34A);
const kAmber = Color(0xFFD9A406);
const kBorder = Color(0xFFE6E6EB);
const kBg = Color(0xFFF5F5F7);
const kSubtle = Color(0xFF8A8A8E);

final ThemeData vizoTheme = () {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: kBg,
    colorScheme: ColorScheme.fromSeed(seedColor: kIndigo).copyWith(surface: Colors.white),
    cardTheme: const CardThemeData(color: Colors.white, elevation: 0),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: kInk, elevation: 0, scrolledUnderElevation: 0),
  );
  // 中文字形对齐 web 的 Noto Sans SC（运行时按需加载，真机/Chrome 生效）。
  return base.copyWith(
    textTheme: GoogleFonts.notoSansScTextTheme(base.textTheme),
  );
}();
