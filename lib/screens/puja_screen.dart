import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/puja_data.dart';
import '../data/youtube_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/starfield.dart';

/// ऑनलाइन पूजा: देवता चुनिए।
class PujaScreen extends StatelessWidget {
  const PujaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🪔 ऑनलाइन पूजा')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'जिनकी पूजा करनी है, उन्हें चुनिए।',
              style: TextStyle(color: AppColors.textSoft, fontSize: 16),
            ),
          ),
          for (final d in deities)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PujaDeityScreen(deity: d),
                    ),
                  );
                },
                child: GlowCard(
                  margin: EdgeInsets.zero,
                  child: Row(
                    children: [
                      const Text('🪔', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.name,
                              style: const TextStyle(
                                color: AppColors.moon,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              d.sub,
                              style: const TextStyle(
                                color: AppColors.textSoft,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PujaDeityScreen extends StatefulWidget {
  final Deity deity;
  const PujaDeityScreen({super.key, required this.deity});

  @override
  State<PujaDeityScreen> createState() => _PujaDeityScreenState();
}

class _PujaDeityScreenState extends State<PujaDeityScreen>
    with TickerProviderStateMixin {
  late final AnimationController _flame;
  late final AnimationController _spin;
  Timer? _lineTimer;
  bool _diya = false;
  bool _aarti = false;
  int _line = 0;

  @override
  void initState() {
    super.initState();
    _flame = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _lineTimer?.cancel();
    _flame.dispose();
    _spin.dispose();
    super.dispose();
  }

  void _toggleDiya() {
    HapticFeedback.mediumImpact();
    setState(() => _diya = !_diya);
  }

  void _startAarti() {
    if (!_diya) setState(() => _diya = true);
    _line = 0;
    _aarti = true;
    _spin.repeat();
    _lineTimer?.cancel();
    _lineTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (!mounted) return;
      if (_line + 1 >= widget.deity.lines.length) {
        _stopAarti(done: true);
      } else {
        HapticFeedback.selectionClick();
        setState(() => _line++);
      }
    });
    setState(() {});
  }

  void _stopAarti({bool done = false}) {
    _lineTimer?.cancel();
    _spin.stop();
    if (!mounted) return;
    setState(() => _aarti = false);
    if (done) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('आरती पूरी हुई 🙏 जय हो!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.deity;
    final lines = d.lines;
    final cur = lines[_line.clamp(0, lines.length - 1).toInt()];
    return Scaffold(
      appBar: AppBar(title: Text(d.name)),
      body: Stack(
        children: [
          const Positioned.fill(child: StarField(count: 35, opacity: 0.8)),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: _toggleDiya,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 110,
                          height: 130,
                          child: AnimatedBuilder(
                            animation: _flame,
                            builder: (context, _) => CustomPaint(
                              painter: _DiyaPainter(_diya, _flame.value),
                            ),
                          ),
                        ),
                        Text(
                          _diya ? 'दीया बुझाएँ' : 'दीया जलाएँ',
                          style: const TextStyle(color: AppColors.textSoft),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_spin, _flame]),
                          builder: (context, _) => CustomPaint(
                            painter: _ThaliPainter(
                              _spin.value,
                              _aarti,
                              _flame.value,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        _aarti ? 'आरती हो रही है' : 'आरती की थाली',
                        style: const TextStyle(color: AppColors.textSoft),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GlowCard(
                child: Column(
                  children: [
                    Text(
                      _aarti ? cur : d.lines.first,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.moon,
                        fontSize: 23,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_aarti && _line + 1 < lines.length) ...[
                      const SizedBox(height: 10),
                      Text(
                        lines[_line + 1],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.accentDark,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _aarti
                        ? OutlinedButton.icon(
                            onPressed: _stopAarti,
                            icon: const Icon(Icons.stop_rounded),
                            label: const Text('आरती रोकें'),
                          )
                        : ElevatedButton.icon(
                            onPressed: _startAarti,
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('आरती शुरू करें'),
                          ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => HapticFeedback.heavyImpact(),
                    icon: const Icon(Icons.notifications_active_rounded),
                    label: const Text('घंटी'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      YoutubeService.openSearch(d.ytQuery),
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: const Text('YouTube पर आरती सुनें'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                d.note,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.accentDark,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _flameAt(Canvas canvas, Offset base, double h, double sway, double glow) {
  final path = Path()
    ..moveTo(base.dx, base.dy)
    ..quadraticBezierTo(
        base.dx - h * 0.45, base.dy - h * 0.5, base.dx + sway, base.dy - h)
    ..quadraticBezierTo(
        base.dx + h * 0.45, base.dy - h * 0.5, base.dx, base.dy)
    ..close();
  canvas.drawCircle(
    Offset(base.dx, base.dy - h * 0.45),
    h * 0.9,
    Paint()
      ..color = Color.fromRGBO(255, 200, 90, glow)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.6),
  );
  canvas.drawPath(
    path,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFFFFF2C0), Color(0xFFFFB02E), Color(0xFFFF6A00)],
      ).createShader(Rect.fromLTWH(base.dx - h, base.dy - h, h * 2, h)),
  );
}

class _DiyaPainter extends CustomPainter {
  final bool lit;
  final double t;
  _DiyaPainter(this.lit, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bowl = Path()
      ..moveTo(cx - 40, size.height - 50)
      ..quadraticBezierTo(cx, size.height - 8, cx + 40, size.height - 50)
      ..close();
    canvas.drawPath(
      bowl,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFD9822B), Color(0xFF8A4A12)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    if (lit) {
      _flameAt(canvas, Offset(cx, size.height - 52), 52 + 5 * t,
          (t - 0.5) * 8, 0.35 + 0.25 * t);
    } else {
      canvas.drawCircle(
        Offset(cx, size.height - 54),
        3,
        Paint()..color = const Color(0xFF444444),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DiyaPainter old) =>
      old.lit != lit || old.t != t;
}

class _ThaliPainter extends CustomPainter {
  final double spin;
  final bool on;
  final double t;
  _ThaliPainter(this.spin, this.on, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final angle = spin * 2 * math.pi;
    final shift = on
        ? Offset(math.cos(angle), math.sin(angle)) * 14
        : Offset.zero;
    final c = Offset(size.width / 2, size.height / 2) + shift;
    canvas.drawCircle(
      c,
      58,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFE08A), Color(0xFFD9A030), Color(0xFF8A5E12)],
        ).createShader(Rect.fromCircle(center: c, radius: 58)),
    );
    canvas.drawCircle(
      c,
      58,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFFFF0B0),
    );
    // बीच का बड़ा दीया और चारों ओर छोटे दीये
    for (var i = 0; i < 5; i++) {
      final a = 2 * math.pi * i / 5 + angle * 0.0;
      final p = i == 0 ? c : c + Offset(math.cos(a), math.sin(a)) * 34;
      canvas.drawCircle(p, 7, Paint()..color = const Color(0xFF6B3A0C));
      if (on) {
        _flameAt(canvas, p.translate(0, -5), 15 + 2 * t, (t - 0.5) * 3, 0.3);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ThaliPainter old) => true;
}
