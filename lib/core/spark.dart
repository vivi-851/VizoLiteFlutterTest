import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

// 合成走势（确定性随机游走，终点=当前概率）。与 web genSpark 同观感。
List<double> synthSpark(int seed, double end, {int n = 20}) {
  final rnd = math.Random(seed);
  final ys = <double>[];
  double v = (end + (rnd.nextDouble() - 0.5) * 0.3).clamp(0.1, 0.9);
  for (var i = 0; i < n; i++) {
    v = (v + (rnd.nextDouble() - 0.5) * 0.12).clamp(0.08, 0.92);
    ys.add(v);
  }
  ys[n - 1] = end.clamp(0.05, 0.95);
  return ys;
}

class SparkPainter extends CustomPainter {
  SparkPainter(this.series);
  final List<double> series;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.length < 2) return;
    final path = Path();
    for (var i = 0; i < series.length; i++) {
      final x = size.width * i / (series.length - 1);
      final y = size.height * (1 - series[i]);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    final up = series.last >= series.first;
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = up ? kGreen : const Color(0xFFEF4444),
    );
  }

  @override
  bool shouldRepaint(SparkPainter old) => old.series != series;
}
