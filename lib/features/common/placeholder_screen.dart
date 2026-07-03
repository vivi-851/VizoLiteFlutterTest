import 'package:flutter/material.dart';

import '../../core/line_icons.dart';
import '../../core/theme.dart';

// 尚未移植的 tab 占位（市场/锦标赛/任务）。壳先完整，内容后续切片接入。
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.icon, required this.title, required this.slice});
  final String icon;
  final String title;
  final String slice;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LineIcon(icon, size: 40, color: const Color(0xFFCBD0D6)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kInk)),
          const SizedBox(height: 4),
          Text('$slice 切片接入', style: const TextStyle(fontSize: 12.5, color: kSubtle)),
        ],
      ),
    );
  }
}
