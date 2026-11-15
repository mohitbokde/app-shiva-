import 'dart:async';

import 'package:flutter/material.dart';

import '../app_info.dart';
import '../theme.dart';
import '../widgets/starfield.dart';
import '../widgets/trishul.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _timer = Timer(const Duration(milliseconds: 3000), _goHome);
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.0,
            colors: [Color(0xFF0A1B3D), AppColors.black],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: StarField(count: 55)),
            const Center(
              child: Text(
                'ॐ',
                style: TextStyle(
                  fontSize: 320,
                  color: Color(0x144DA3FF),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1200),
                  builder: (context, fade, child) =>
                      Opacity(opacity: fade, child: child),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Trishul(height: 190),
                      const SizedBox(height: 28),
                      AnimatedBuilder(
                        animation: _glow,
                        builder: (context, _) {
                          final g = _glow.value;
                          return Text(
                            'हर हर महादेव',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentLight,
                              shadows: [
                                Shadow(
                                  color: Color.fromRGBO(
                                      77, 163, 255, 0.3 + 0.6 * g),
                                  blurRadius: 10 + 25 * g,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        AppInfo.name,
                        style: TextStyle(
                          fontSize: 28,
                          color: AppColors.accent,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '${AppInfo.dedication} 💙',
                        style: TextStyle(
                          fontSize: 17,
                          color: AppColors.accentLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 36,
              child: Text(
                AppInfo.developer,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.accentDark,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
