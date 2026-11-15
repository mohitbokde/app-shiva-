import 'package:flutter/material.dart';

import '../app_info.dart';
import '../theme.dart';
import 'starfield.dart';
import 'trishul.dart';

class _MoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    final cut = Path()
      ..addOval(
        Rect.fromLTWH(
          size.width * 0.32,
          -size.height * 0.06,
          size.width * 0.92,
          size.height * 0.92,
        ),
      );
    final moon = Path.combine(PathOperation.difference, full, cut);
    canvas.drawShadow(moon, AppColors.accent, 6, false);
    canvas.drawPath(moon, Paint()..color = AppColors.moon);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// होम स्क्रीन का ऊपरी बड़ा हिस्सा: रात का आकाश, चाँद, त्रिशूल और "हर हर महादेव"।
class HeroHeader extends StatefulWidget {
  final String dateText;
  const HeroHeader({super.key, required this.dateText});

  @override
  State<HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<HeroHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B2C63), Color(0xFF041230), Color(0xFF000000)],
        ),
        border: Border.all(color: const Color(0x664DA3FF)),
        boxShadow: const [
          BoxShadow(color: Color(0x334DA3FF), blurRadius: 28),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            const Positioned.fill(child: StarField(count: 42)),
            Positioned(
              top: 16,
              left: 18,
              child: SizedBox(
                width: 38,
                height: 38,
                child: CustomPaint(painter: _MoonPainter()),
              ),
            ),
            Positioned(
              right: 8,
              top: 20,
              bottom: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x334DA3FF), Color(0x004DA3FF)],
                    ),
                  ),
                  child: const Trishul(height: 170),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              right: 130,
              child: AnimatedBuilder(
                animation: _glow,
                builder: (context, _) {
                  final g = _glow.value;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),
                      Text(
                        '🔱 ${AppInfo.name}',
                        style: const TextStyle(
                          color: AppColors.accentLight,
                          fontSize: 15,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'हर हर\nमहादेव',
                        style: TextStyle(
                          fontSize: 32,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                          color: AppColors.moon,
                          shadows: [
                            Shadow(
                              color: Color.fromRGBO(77, 163, 255, 0.35 + 0.5 * g),
                              blurRadius: 12 + 18 * g,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.dateText,
                        style: const TextStyle(
                          color: AppColors.textSoft,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '${AppInfo.dedication} 💙',
                        style: TextStyle(
                          color: AppColors.accentLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
