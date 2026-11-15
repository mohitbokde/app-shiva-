import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/jap_store.dart';
import '../theme.dart';

/// रोज़ का जाप-लक्ष्य बदलने की खिड़की।
Future<void> editGoalDialog(BuildContext context) async {
  final controller = TextEditingController(text: '${JapStore.instance.goal}');
  final result = await showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cardHigh,
      title: const Text(
        'रोज़ का लक्ष्य',
        style: TextStyle(color: AppColors.accentLight),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: AppColors.moon, fontSize: 22),
            decoration: const InputDecoration(
              hintText: 'कितने जाप रोज़?',
              hintStyle: TextStyle(color: AppColors.accentDark),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              for (final n in const [108, 216, 540, 1008])
                ActionChip(
                  label: Text('$n'),
                  backgroundColor: AppColors.accentFaint,
                  labelStyle: const TextStyle(color: AppColors.accentLight),
                  onPressed: () => Navigator.of(ctx).pop(n),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('रद्द करें'),
        ),
        ElevatedButton(
          onPressed: () {
            final v = int.tryParse(controller.text.trim());
            Navigator.of(ctx).pop(v);
          },
          child: const Text('सेव करें'),
        ),
      ],
    ),
  );
  if (result != null && result > 0) {
    JapStore.instance.setGoal(result);
  }
}
