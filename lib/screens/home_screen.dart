import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_info.dart';
import '../data/daily_content.dart';
import '../data/hindi_date.dart';
import '../data/jap_store.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../utils/links.dart';
import '../widgets/common.dart';
import '../widgets/hero_header.dart';
import '../data/youtube_service.dart';
import '../widgets/yt_section.dart';
import 'jyotirlinga_screen.dart';
import 'dhyan_screen.dart';
import 'katha_screen.dart';
import 'puja_screen.dart';
import 'paath_screen.dart';

class HomeScreen extends StatefulWidget {
  /// नीचे की पट्टी का कोई टैब खोलने के लिए (0 होम, 1 जाप, 2 भजन, 3 दर्शन, 4 भक्ति)
  final void Function(int index) onGoTab;
  const HomeScreen({super.key, required this.onGoTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  DateTime _today = DateTime.now();
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnight();
  }

  // आधी रात को तारीख, मंत्र, कथा और आज का ज्योतिर्लिंग अपने-आप बदलें
  void _scheduleMidnight() {
    _midnight?.cancel();
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(next.difference(now) + const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _today = DateTime.now());
      _scheduleMidnight();
    });
  }

  // ऐप वापस खुलने पर भी तारीख जाँचें
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _today = DateTime.now());
      _scheduleMidnight();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnight?.cancel();
    super.dispose();
  }

  void _copyMantra(Mantra m) {
    Clipboard.setData(
      ClipboardData(text: '${m.sanskrit}\n\nअर्थ: ${m.meaning}'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('मंत्र कॉपी हो गया')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mantra = mantraFor(_today);
    final katha = kathaFor(_today);
    final jyotir = todaysJyotirlinga(_today);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HeroHeader(dateText: hindiDate(_today)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PujaScreen()),
              );
            },
            icon: const Text('🪔', style: TextStyle(fontSize: 20)),
            label: const Text('ऑनलाइन पूजा करें'),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _QuickTile(Icons.self_improvement_rounded, 'जाप', () => widget.onGoTab(1)),
            _QuickTile(Icons.auto_stories_rounded, 'पाठ', () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaathListScreen()),
              );
            }),
            _QuickTile(Icons.spa_rounded, 'ध्यान', () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DhyanScreen()),
              );
            }),
            _QuickTile(Icons.music_note_rounded, 'भजन', () => widget.onGoTab(2)),
            _QuickTile(Icons.temple_hindu_rounded, 'दर्शन', () => widget.onGoTab(3)),
          ],
        ),
        const SizedBox(height: 8),

        // आज का ज्योतिर्लिंग
        GlowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('🛕 आज का ज्योतिर्लिंग दर्शन'),
              Text(
                jyotir.name,
                style: const TextStyle(
                  color: AppColors.accentLight,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                jyotir.place,
                style: const TextStyle(color: AppColors.accent, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                jyotir.info,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: AppColors.textSoft,
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JyotirlingaDetailScreen(j: jyotir),
                      ),
                    );
                  },
                  child: const Text('दर्शन करें'),
                ),
              ),
            ],
          ),
        ),

        // नाम जाप
        GlowCard(
          child: AnimatedBuilder(
            animation: JapStore.instance,
            builder: (context, _) {
              final jap = JapStore.instance;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('📿 आज का नाम जाप'),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      indian(jap.today),
                      style: const TextStyle(
                        color: AppColors.accentLight,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'अब तक कुल: ${indian(jap.lifetime)}   •   लगातार ${jap.streak} दिन',
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => widget.onGoTab(1),
                      child: const Text('जाप शुरू करें'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // आज का मंत्र
        GlowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('🔱 आज का मंत्र'),
              Text(
                mantra.title,
                style: const TextStyle(color: AppColors.accent, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  mantra.sanskrit,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.6,
                    color: AppColors.accentLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 28, color: AppColors.accentDark),
              const Text(
                'अर्थ',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                mantra.meaning,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: AppColors.textSoft,
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _copyMantra(mantra),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('कॉपी'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => shareOnWhatsApp(
                        context,
                        '${mantra.sanskrit}\n\nअर्थ: ${mantra.meaning}${AppInfo.shareFooter}',
                      ),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('WhatsApp'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // आज की शिव कथा
        GlowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('📖 आज की शिव कथा'),
              Text(
                katha.title,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                katha.story,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: AppColors.textSoft,
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => KathaScreen(katha: katha),
                      ),
                    );
                  },
                  child: const Text('पूरी कथा पढ़ें'),
                ),
              ),
            ],
          ),
        ),

        // आज के नए भजन
        const SectionTitle('🎶 आज के नए भजन'),
        const YtSection(
          query: 'शिव भजन',
          order: 'date',
          lastDays: 30,
          maxResults: 15,
          limit: 3,
          showMore: false,
        ),
        Center(
          child: ElevatedButton.icon(
            onPressed: () =>
                YoutubeService.openSearch('शिव भजन', newest: true),
            icon: const Icon(Icons.play_circle_fill_rounded),
            label: const Text('YouTube पर नए भजन सीधे खोलें'),
          ),
        ),
        Center(
          child: OutlinedButton(
            onPressed: () => widget.onGoTab(2),
            child: const Text('सभी भजन देखें'),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'हर दिन रात 12 बजे नया मंत्र, नई कथा और नया दर्शन आता है।',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.accentDark, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickTile(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentFaint),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.accent, size: 26),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
