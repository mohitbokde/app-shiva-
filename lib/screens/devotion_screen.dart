import 'package:flutter/material.dart';

import '../data/badges.dart';
import '../data/fav_store.dart';
import '../data/jap_store.dart';
import '../data/jyotirlinga_data.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/bar_chart.dart';
import '../widgets/common.dart';
import '../widgets/goal_dialog.dart';
import '../widgets/video_tile.dart';
import 'history_screen.dart';
import 'jyotirlinga_screen.dart';

/// मेरी भक्ति: जाप के आँकड़े, पसंदीदा ज्योतिर्लिंग और भजन।
class DevotionScreen extends StatelessWidget {
  const DevotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([JapStore.instance, FavStore.instance]),
      builder: (context, _) {
        final jap = JapStore.instance;
        final fav = FavStore.instance;
        final now = DateTime.now();

        final week = <BarItem>[];
        for (var i = 6; i >= 0; i--) {
          final d = DateTime(now.year, now.month, now.day - i);
          week.add(BarItem('${d.day}', jap.countOn(d)));
        }

        final favJ = <Jyotirlinga>[
          for (final j in jyotirlingas)
            if (fav.isJyotirFav(j.id)) j,
        ];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _StatTile('आज का जाप', indian(jap.today))),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile('इस महीने का जाप', indian(jap.thisMonth)),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StatTile('इस साल का जाप', indian(jap.thisYear)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile('अब तक का कुल जाप', indian(jap.lifetime)),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StatTile('लगातार जाप के दिन', '${jap.streak}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile('पूरी मालाएँ', indian(jap.malaCount)),
                ),
              ],
            ),
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SectionTitle('🎯 आज का लक्ष्य'),
                      TextButton(
                        onPressed: () => editGoalDialog(context),
                        child: const Text('बदलें'),
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: jap.goalProgress,
                      minHeight: 10,
                      color: AppColors.accent,
                      backgroundColor: AppColors.accentFaint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${indian(jap.today)} / ${indian(BigInt.from(jap.goal))}',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('पिछले 7 दिन की भक्ति'),
                  BarChart(items: week, height: 100, showValues: true),
                ],
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('पूरा इतिहास और कैलेंडर'),
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle('🏅 बैज'),
            GlowCard(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final b in buildBadges(jap)) _BadgeChip(b),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const SectionTitle('पसंदीदा ज्योतिर्लिंग'),
            if (favJ.isEmpty)
              const GlowCard(
                child: Text(
                  'अभी कोई पसंदीदा ज्योतिर्लिंग नहीं है। "दर्शन" में किसी के आगे ♡ दबाएँ।',
                  style: TextStyle(color: AppColors.textSoft, fontSize: 15),
                ),
              )
            else
              for (final j in favJ)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    tileColor: AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.accentDark),
                    ),
                    title: Text(
                      j.name,
                      style: const TextStyle(color: AppColors.accentLight),
                    ),
                    subtitle: Text(
                      j.place,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.accent,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => JyotirlingaDetailScreen(j: j),
                        ),
                      );
                    },
                  ),
                ),
            const SizedBox(height: 12),
            const SectionTitle('पसंदीदा भजन'),
            if (fav.bhajans.isEmpty)
              const GlowCard(
                child: Text(
                  'अभी कोई पसंदीदा भजन नहीं है। "भजन" में किसी भजन के आगे ♡ दबाएँ।',
                  style: TextStyle(color: AppColors.textSoft, fontSize: 15),
                ),
              )
            else
              for (final v in fav.bhajans) VideoTile(video: v),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.accentLight,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final BadgeInfo b;
  const _BadgeChip(this.b);

  @override
  Widget build(BuildContext context) {
    final on = b.unlocked;
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: on ? AppColors.accentFaint : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: on ? AppColors.accent : const Color(0xFF1A2438),
        ),
      ),
      child: Column(
        children: [
          Icon(
            on ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
            color: on ? AppColors.accentLight : const Color(0xFF4A5A75),
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            b.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: on ? AppColors.moon : const Color(0xFF6A7A95),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            b.detail,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: on ? AppColors.textSoft : const Color(0xFF4A5A75),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
