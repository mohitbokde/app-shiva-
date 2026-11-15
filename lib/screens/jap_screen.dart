import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/jap_store.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/goal_dialog.dart';
import '../widgets/starfield.dart';
import 'history_screen.dart';

class JapScreen extends StatefulWidget {
  const JapScreen({super.key});

  @override
  State<JapScreen> createState() => _JapScreenState();
}

class _JapScreenState extends State<JapScreen>
    with SingleTickerProviderStateMixin {
  final JapStore store = JapStore.instance;
  late final AnimationController _ripple;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  void _onCount() {
    final r = store.tap();
    _ripple.forward(from: 0);
    String? msg;
    if (r.goalReached) {
      msg = '🎯 आज का लक्ष्य पूरा हुआ! हर हर महादेव';
    } else if (r.malaDone) {
      msg = '🔱 एक माला (108 जाप) पूरी हुई। हर हर महादेव!';
    }
    if (msg != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
        );
    }
  }

  void _release() {
    if (_pressed) setState(() => _pressed = false);
  }

  Future<void> _editCustom() async {
    final controller = TextEditingController(text: store.customMantra);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardHigh,
        title: const Text(
          'अपना मंत्र लिखें',
          style: TextStyle(color: AppColors.accentLight),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          minLines: 1,
          style: const TextStyle(color: AppColors.moon, fontSize: 18),
          decoration: const InputDecoration(
            hintText: 'जैसे: ॐ नमः शिवाय',
            hintStyle: TextStyle(color: AppColors.accentDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('रद्द करें'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('सेव करें'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      store.setCustom(result);
    }
  }

  Widget _chip(String label, String id) {
    final selected = store.selectedId == id;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppColors.accentFaint,
      backgroundColor: AppColors.card,
      labelStyle: TextStyle(
        color: selected ? AppColors.moon : AppColors.textSoft,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? AppColors.accent : AppColors.accentFaint,
      ),
      onSelected: (_) {
        if (id == 'custom' && store.customMantra.isEmpty) {
          store.select('custom');
          _editCustom();
        } else {
          store.select(id);
        }
      },
    );
  }

  Widget _orb(int pos) {
    return GestureDetector(
      onTap: _onCount,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => _release(),
      onTapCancel: _release,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(300, 300),
                painter: _RipplePainter(_ripple),
              ),
              CustomPaint(
                size: const Size(270, 270),
                painter: _RingPainter(pos / 108),
              ),
              Container(
                width: 214,
                height: 214,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.3, -0.4),
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
                      color: Color.fromRGBO(77, 163, 255, _pressed ? 0.85 : 0.4),
                      blurRadius: _pressed ? 46 : 26,
                      spreadRadius: _pressed ? 6 : 1,
                    ),
                  ],
                ),
                child: const Text(
                  'ॐ',
                  style: TextStyle(
                    fontSize: 100,
                    color: Color(0xFF03112B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: StarField(count: 30, opacity: 0.7)),
        AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final pos = store.malaPosition;
            final isCustomEmpty =
                store.selectedId == 'custom' && store.customMantra.isEmpty;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final m in japMantras) _chip(m.name, m.id),
                    _chip('अपना मंत्र', 'custom'),
                  ],
                ),
                const SizedBox(height: 14),
                GlowCard(
                  child: Column(
                    children: [
                      Text(
                        isCustomEmpty
                            ? 'अभी कोई मंत्र नहीं लिखा। नीचे बटन से अपना मंत्र लिखें।'
                            : store.currentMantraText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isCustomEmpty ? 16 : 22,
                          height: 1.5,
                          color: isCustomEmpty
                              ? AppColors.textSoft
                              : AppColors.moon,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (store.selectedId == 'custom')
                        TextButton.icon(
                          onPressed: _editCustom,
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text('अपना मंत्र लिखें / बदलें'),
                        ),
                    ],
                  ),
                ),
                const Center(
                  child: Text(
                    'आज का जाप',
                    style: TextStyle(color: AppColors.textSoft, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      indian(store.today),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.moon,
                        shadows: [
                          Shadow(color: Color(0x884DA3FF), blurRadius: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(child: _orb(pos)),
                const Center(
                  child: Text(
                    'हर टैप पर ठीक एक जाप',
                    style: TextStyle(color: AppColors.accentDark, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 18),
                GlowCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '🎯 आज का लक्ष्य',
                            style: TextStyle(
                              color: AppColors.accentLight,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => editGoalDialog(context),
                            child: const Text('बदलें'),
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: store.goalProgress,
                          minHeight: 10,
                          color: AppColors.accent,
                          backgroundColor: AppColors.accentFaint,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        store.goalDoneToday
                            ? 'लक्ष्य पूरा! ${indian(store.today)} / ${indian(BigInt.from(store.goal))}'
                            : '${indian(store.today)} / ${indian(BigInt.from(store.goal))}',
                        style: const TextStyle(
                          color: AppColors.textSoft,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                GlowCard(
                  child: Column(
                    children: [
                      _row('माला', '$pos / 108'),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: pos / 108,
                          minHeight: 10,
                          color: AppColors.accentLight,
                          backgroundColor: AppColors.accentFaint,
                        ),
                      ),
                      const Divider(height: 26),
                      _row('पूरी हुई मालाएँ', indian(store.malaCount)),
                      const SizedBox(height: 6),
                      _row('अब तक का कुल जाप', indian(store.lifetime)),
                      const SizedBox(height: 6),
                      _row('लगातार जाप के दिन', '${store.streak}'),
                    ],
                  ),
                ),
                GlowCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'टैप पर कंपन (vibration)',
                      style: TextStyle(color: AppColors.textSoft),
                    ),
                    value: store.vibrate,
                    onChanged: (v) => store.setVibrate(v),
                  ),
                ),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: const Text('जाप का इतिहास और कैलेंडर'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSoft, fontSize: 15),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.moon,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// हर टैप पर फैलने वाली नीली लहर
class _RipplePainter extends CustomPainter {
  final Animation<double> anim;
  _RipplePainter(this.anim) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;
    if (t == 0 || t == 1) return;
    final c = Offset(size.width / 2, size.height / 2);
    final radius = 108 + 42 * t;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Color.fromRGBO(168, 211, 255, (1 - t) * 0.7);
    canvas.drawCircle(c, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) => false;
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    final bg = Paint()
      ..color = AppColors.accentFaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final fg = Paint()
      ..color = AppColors.accentLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, bg);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
