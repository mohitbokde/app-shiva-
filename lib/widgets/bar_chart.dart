import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/format.dart';

class BarItem {
  final String label;
  final BigInt value;
  const BarItem(this.label, this.value);
}

/// सुनहरे डंडों वाला सरल चार्ट (बिना किसी बाहरी package के)।
class BarChart extends StatelessWidget {
  final List<BarItem> items;
  final double height;
  final bool showValues;
  const BarChart({
    super.key,
    required this.items,
    this.height = 120,
    this.showValues = false,
  });

  double _barHeight(BigInt v, BigInt maxV) {
    if (maxV == BigInt.zero || v == BigInt.zero) return 2;
    final frac = (v * BigInt.from(1000) ~/ maxV).toInt() / 1000.0;
    final h = frac * height;
    return h < 4 ? 4 : h;
  }

  @override
  Widget build(BuildContext context) {
    var maxV = BigInt.zero;
    for (final it in items) {
      if (it.value > maxV) maxV = it.value;
    }
    return SizedBox(
      height: height + 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final it in items)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showValues && it.value > BigInt.zero)
                      SizedBox(
                        height: 14,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            compact(it.value),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSoft,
                            ),
                          ),
                        ),
                      ),
                    Container(
                      height: _barHeight(it.value, maxV),
                      decoration: BoxDecoration(
                        color: it.value > BigInt.zero
                            ? AppColors.accent
                            : AppColors.accentFaint,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 16,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          it.label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.accentDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
