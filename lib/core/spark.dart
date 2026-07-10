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

// Figma 235:2 同款走势：靛蓝曲线 + 线下渐变填充。
class TrendPainter extends CustomPainter {
  TrendPainter(this.series);
  final List<double> series;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.length < 2) return;
    final line = Path();
    for (var i = 0; i < series.length; i++) {
      final x = size.width * i / (series.length - 1);
      final y = size.height * (1 - series[i]);
      i == 0 ? line.moveTo(x, y) : line.lineTo(x, y);
    }
    // 渐变填充（线下方）
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kIndigo.withValues(alpha: 0.18), kIndigo.withValues(alpha: 0.0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = kIndigo,
    );
  }

  @override
  bool shouldRepaint(TrendPainter old) => old.series != series;
}

// 走势大图 + 线尾当前概率药丸（Figma：曲线终点右侧挂靛蓝 41% 徽标）。
class TrendSpark extends StatelessWidget {
  const TrendSpark({super.key, required this.series, required this.pct, this.height = 64});
  final List<double> series;
  final int pct;
  final double height;

  @override
  Widget build(BuildContext context) {
    const badgeW = 46.0;
    return SizedBox(
      height: height,
      child: LayoutBuilder(builder: (context, c) {
        final end = series.isEmpty ? 0.5 : series.last;
        // 药丸中心对齐曲线终点，出界时夹住
        final y = ((1 - end) * height - 11).clamp(0.0, height - 22);
        return Stack(children: [
          Positioned.fill(
            right: badgeW + 6,
            child: CustomPaint(painter: TrendPainter(series), size: Size.infinite),
          ),
          Positioned(
            right: 0,
            top: y,
            child: Container(
              width: badgeW,
              padding: const EdgeInsets.symmetric(vertical: 3),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: kIndigo, borderRadius: BorderRadius.circular(999)),
              child: Text('$pct%', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
        ]);
      }),
    );
  }
}
