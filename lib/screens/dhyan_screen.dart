import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/starfield.dart';

/// ध्यान: समय चुनिए, ॐ के साथ साँस लीजिए और छोड़िए।
class DhyanScreen extends StatefulWidget {
  const DhyanScreen({super.key});

  @override
  State<DhyanScreen> createState() => _DhyanScreenState();
}

class _DhyanScreenState extends State<DhyanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;
  Timer? _tick;
  DateTime? _end;
  int _minutes = 11;
  int _left = 0;
  bool _running = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _tick?.cancel();
    _breath.dispose();
    super.dispose();
  }

  void _start() {
    _end = DateTime.now().add(Duration(minutes: _minutes));
    _left = _minutes * 60;
    _done = false;
    _running = true;
    _breath.repeat(reverse: true);
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final e = _end;
      if (e == null) return;
      final r = e.difference(DateTime.now()).inSeconds;
      if (r <= 0) {
        _finish();
      } else if (mounted) {
        setState(() => _left = r);
      }
    });
    setState(() {});
  }

  void _stop() {
    _tick?.cancel();
    _breath.stop();
    setState(() {
      _running = false;
      _end = null;
    });
  }

  void _finish() {
    _tick?.cancel();
    _breath.stop();
    HapticFeedback.heavyImpact();
    if (!mounted) return;
    setState(() {
      _running = false;
      _done = true;
      _end = null;
    });
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ध्यान')),
      body: Stack(
        children: [
          const Positioned.fill(child: StarField(count: 40, opacity: 0.8)),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),
              Center(
                child: AnimatedBuilder(
                  animation: _breath,
                  builder: (context, _) {
                    final t = Curves.easeInOut.transform(_breath.value);
                    final size = 170 + 60 * t;
                    return SizedBox(
                      width: 260,
                      height: 260,
                      child: Center(
                        child: Container(
                          width: size,
                          height: size,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                AppColors.moon,
                                AppColors.accentLight,
                                AppColors.accent,
                                Color(0xFF1D4F96),
                              ],
                              stops: [0.0, 0.3, 0.65, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(77, 163, 255, 0.25 + 0.4 * t),
                                blurRadius: 20 + 40 * t,
                                spreadRadius: 2 + 8 * t,
                              ),
                            ],
                          ),
                          child: Text(
                            'ॐ',
                            style: TextStyle(
                              fontSize: 60 + 30 * t,
                              color: const Color(0xFF03112B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _running
                      ? _fmt(_left)
                      : (_done ? 'ध्यान पूरा हुआ 🙏' : '$_minutes मिनट'),
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: AppColors.moon,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: AnimatedBuilder(
                  animation: _breath,
                  builder: (context, _) {
                    String text = 'आँखें बंद करें और शांत बैठें';
                    if (_running) {
                      text = _breath.status == AnimationStatus.reverse
                          ? 'साँस छोड़ें…'
                          : 'साँस लें…';
                    }
                    return Text(
                      text,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 17,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (!_running)
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final m in const [5, 11, 21, 31, 51])
                      ChoiceChip(
                        label: Text('$m मिनट'),
                        selected: _minutes == m,
                        showCheckmark: false,
                        selectedColor: AppColors.accentFaint,
                        backgroundColor: AppColors.card,
                        labelStyle: TextStyle(
                          color: _minutes == m
                              ? AppColors.moon
                              : AppColors.textSoft,
                        ),
                        side: BorderSide(
                          color: _minutes == m
                              ? AppColors.accent
                              : AppColors.accentFaint,
                        ),
                        onSelected: (_) => setState(() => _minutes = m),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              Center(
                child: _running
                    ? OutlinedButton.icon(
                        onPressed: _stop,
                        icon: const Icon(Icons.stop_rounded),
                        label: const Text('रोकें'),
                      )
                    : ElevatedButton.icon(
                        onPressed: _start,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('ध्यान शुरू करें'),
                      ),
              ),
              const SizedBox(height: 20),
              const GlowCard(
                child: Text(
                  'मन में "ॐ नमः शिवाय" दोहराते हुए, गोले के साथ धीरे-धीरे साँस लें और छोड़ें। '
                  'ध्यान के समय ऐप खुला रखें।',
                  style: TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
