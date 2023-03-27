import 'dart:math';

import 'package:flutter/material.dart';

class ProgressWidget extends StatefulWidget {
  const ProgressWidget({super.key});

  @override
  State<ProgressWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
          ),
          child: const RadiantPercentWidget(
            percent: 65,
            fillColor: Colors.blue,
            freeColor: Colors.yellow,
            lineCoolor: Colors.red,
            lineWidth: 5,
            child: Text(
              '65%',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          )),
    );
  }
}

class RadiantPercentWidget extends StatelessWidget {
  final Widget child;

  final double percent;
  final Color fillColor;
  final Color lineCoolor;
  final Color freeColor;
  final double lineWidth;

  const RadiantPercentWidget({
    super.key,
    required this.child,
    required this.percent,
    required this.fillColor,
    required this.lineCoolor,
    required this.freeColor,
    required this.lineWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _MyPainter(
        lineWidth: lineWidth,
        fillColor: fillColor,
        freeColor: freeColor,
        lineCoolor: lineCoolor,
        percent: percent
        )),
        Center(child: child),
      ],
    );
  }
}

class _MyPainter extends CustomPainter {
  final double percent;
  final Color fillColor;
  final Color lineCoolor;
  final Color freeColor;
  final double lineWidth;

  _MyPainter({
    required this.percent,
    required this.fillColor,
    required this.lineCoolor,
    required this.freeColor,
    required this.lineWidth,
});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect arcRect = calculateArcRect(size);

    drawBackground(canvas, size);
    drawFreeArc(canvas, arcRect);
    drawFilledArc(canvas, arcRect);
  }

  void drawFilledArc(Canvas canvas, Rect arcRect) {
    final paint = Paint();
    paint.color = lineCoolor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5;
    paint.strokeCap = StrokeCap.round;
    canvas.drawArc(
      arcRect,
      -pi / 2, // початкове значення в рад  іанах
      pi * 2 * percent / 100, // довжина дуги в радіанах
      false,
      paint,
    );
  }

  void drawFreeArc(Canvas canvas, Rect arcRect) {
    final paint = Paint();
    paint.color = freeColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5;
    canvas.drawArc(
      arcRect,
      (pi * 2 * percent / 100) - pi / 2, // початкове значення в рад  іанах
      pi * 2 * (1.0 - percent / 100), // довжина дуги в радіанах
      false,
      paint,
    );
  }

  void drawBackground(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = fillColor;
    paint.style = PaintingStyle.fill;
    canvas.drawOval(Offset.zero & size, paint);
  }

  Rect calculateArcRect(Size size) {
    const linesMargin = 3;
    final offset = lineWidth / 2 + linesMargin;
    final arcRect = Offset(offset, offset) & Size(size.width - offset * 2, size.height - offset * 2);
    return arcRect;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
