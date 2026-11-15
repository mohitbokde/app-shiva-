import 'dart:math' as math;

import 'package:flutter/material.dart';

class _Star {
  final double x;
  final double y;
  final double r;
  final double phase;
  final int speed;
  const _Star(this.x, this.y, this.r, this.phase, this.speed);
}

/// हल्के-हल्के टिमटिमाते तारे (रात का आकाश)।
class StarField extends StatefulWidget {
  final int count;
  final double opacity;
  const StarField({super.key, this.count = 45, this.opacity = 1});

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(7);
    _stars = List<_Star>.generate(widget.count, (_) {
      return _Star(
        rnd.nextDouble(),
        rnd.nextDouble(),
        0.6 + rnd.nextDouble() * 1.3,
        rnd.nextDouble() * math.pi * 2,
        1 + rnd.nextInt(3),
      );
    });
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _StarPainter(_stars, _c, widget.opacity),
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final Animation<double> anim;
  final double opacity;

  _StarPainter(this.stars, this.anim, this.opacity) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final s in stars) {
      final wave =
          0.5 + 0.5 * math.sin(2 * math.pi * s.speed * anim.value + s.phase);
      final alpha = (opacity * (0.25 + 0.75 * wave)).clamp(0.0, 1.0).toDouble();
      paint.color = Color.fromRGBO(200, 225, 255, alpha);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) {
    return oldDelegate.stars != stars || oldDelegate.opacity != opacity;
  }
}
