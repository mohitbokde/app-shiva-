import 'package:flutter/material.dart';

import '../app_info.dart';
import '../data/daily_content.dart';
import '../data/fav_store.dart';
import '../data/jyotirlinga_data.dart';
import '../data/youtube_service.dart';
import '../theme.dart';
import '../utils/links.dart';
import '../widgets/common.dart';
import '../widgets/yt_section.dart';

/// आज जिस ज्योतिर्लिंग की बारी है (रोज़ बदलता है)।
Jyotirlinga todaysJyotirlinga(DateTime d) {
  return jyotirlingas[dayNumberOf(d) % jyotirlingas.length];
}

class JyotirlingaScreen extends StatelessWidget {
  const JyotirlingaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = todaysJyotirlinga(DateTime.now());
    return AnimatedBuilder(
      animation: FavStore.instance,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const GlowCard(
              child: Text(
                'बारह ज्योतिर्लिंग। हर मंदिर के पेज पर YouTube से उसके ताज़ा दर्शन के वीडियो आते हैं, '
                'जो रोज़ बदलते हैं। हर दिन एक ज्योतिर्लिंग "आज का दर्शन" बनता है।',
                style: TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            for (var i = 0; i < jyotirlingas.length; i++)
              _tile(context, i, jyotirlingas[i], jyotirlingas[i].id == today.id),
          ],
        );
      },
    );
  }

  Widget _tile(BuildContext context, int index, Jyotirlinga j, bool isToday) {
    final fav = FavStore.instance.isJyotirFav(j.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => JyotirlingaDetailScreen(j: j),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isToday ? AppColors.accent : AppColors.accentDark,
              width: isToday ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accentFaint,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: AppColors.accentLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            j.name,
                            style: const TextStyle(
                              color: AppColors.accentLight,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isToday)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'आज का दर्शन',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      j.place,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  fav ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.accent,
                ),
                onPressed: () => FavStore.instance.toggleJyotir(j.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JyotirlingaDetailScreen extends StatelessWidget {
  final Jyotirlinga j;
  const JyotirlingaDetailScreen({super.key, required this.j});

  @override
  Widget build(BuildContext context) {
    final link = j.link;
    return Scaffold(
      appBar: AppBar(
        title: Text(j.name),
        actions: [
          AnimatedBuilder(
            animation: FavStore.instance,
            builder: (context, _) {
              final fav = FavStore.instance.isJyotirFav(j.id);
              return IconButton(
                tooltip: 'पसंदीदा',
                icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
                onPressed: () => FavStore.instance.toggleJyotir(j.id),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  j.name,
                  style: const TextStyle(
                    color: AppColors.accentLight,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        j.place,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  j.info,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 17,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('🕉 महत्व'),
                Text(
                  j.importance,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 17,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          if (link != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final ok = await YoutubeService.openUrl(Uri.parse(link));
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('वेबसाइट नहीं खुल सकी')),
                    );
                  }
                },
                icon: const Icon(Icons.language_rounded),
                label: Text(j.linkLabel),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => openMaps(
                      context,
                      jyotirMapQuery[j.id] ?? '${j.name} ${j.place}',
                    ),
                    icon: const Icon(Icons.directions_rounded, size: 18),
                    label: const Text('रास्ता देखें'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => shareOnWhatsApp(
                      context,
                      '🛕 ${j.name} ज्योतिर्लिंग\n${j.place}\n\n${j.info}${AppInfo.shareFooter}',
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('शेयर'),
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle('📹 आज का दर्शन (YouTube)'),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton.icon(
              onPressed: () =>
                  YoutubeService.openSearch(j.ytQuery, newest: true),
              icon: const Icon(Icons.play_circle_fill_rounded),
              label: const Text('YouTube पर सीधे दर्शन देखें'),
            ),
          ),
          YtSection(
            query: j.ytQuery,
            order: 'date',
            maxResults: 6,
            showFav: false,
          ),
        ],
      ),
    );
  }
}
