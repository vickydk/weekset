import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Seven days. One bar is lime. Shared by the icon and the splash.
class WeekMark extends StatelessWidget {
  const WeekMark({this.size = 88, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const WeekMarkPainter(),
    );
  }
}

class WeekMarkPainter extends CustomPainter {
  const WeekMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = AppColors.charcoal;
    final radius = size.width * 0.22;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      background,
    );
    const heights = [0.38, 0.52, 0.44, 0.72, 0.48, 0.56, 0.40];
    final barWidth = size.width * 0.07;
    final gap = size.width * 0.035;
    final total = heights.length * barWidth + (heights.length - 1) * gap;
    var x = (size.width - total) / 2;
    final baseline = size.height * 0.78;
    for (var i = 0; i < heights.length; i++) {
      final paint = Paint()..color = i == 3 ? AppColors.lime : AppColors.paper;
      final h = size.height * heights[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, baseline - h, barWidth, h),
          Radius.circular(barWidth / 2),
        ),
        paint,
      );
      x += barWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
