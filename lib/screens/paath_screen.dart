import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_info.dart';
import '../data/paath_data.dart';
import '../theme.dart';
import '../utils/links.dart';
import '../widgets/common.dart';

/// आरती, चालीसा और स्तोत्र की सूची।
class PaathListScreen extends StatelessWidget {
  const PaathListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('आरती और पाठ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final p in paathList)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PaathReaderScreen(paath: p),
                    ),
                  );
                },
                child: GlowCard(
                  margin: EdgeInsets.zero,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_stories_rounded,
                        color: AppColors.accent,
                        size: 30,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              style: const TextStyle(
                                color: AppColors.moon,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              p.subtitle,
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

class PaathReaderScreen extends StatefulWidget {
  final Paath paath;
  const PaathReaderScreen({super.key, required this.paath});

  @override
  State<PaathReaderScreen> createState() => _PaathReaderScreenState();
}

class _PaathReaderScreenState extends State<PaathReaderScreen> {
  double _size = 20;

  void _change(double d) {
    setState(() {
      _size = (_size + d).clamp(15.0, 36.0).toDouble();
    });
  }

  String get _fullText => '${widget.paath.title}\n\n${widget.paath.text}';

  @override
  Widget build(BuildContext context) {
    final p = widget.paath;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.title),
        actions: [
          IconButton(
            tooltip: 'अक्षर छोटे करें',
            icon: const Icon(Icons.text_decrease_rounded),
            onPressed: () => _change(-2),
          ),
          IconButton(
            tooltip: 'अक्षर बड़े करें',
            icon: const Icon(Icons.text_increase_rounded),
            onPressed: () => _change(2),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlowCard(
            child: Text(
              p.note,
              style: const TextStyle(
                color: AppColors.accentLight,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          GlowCard(
            child: Center(
              child: Text(
                p.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.moon,
                  fontSize: _size,
                  height: 1.9,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _fullText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('पाठ कॉपी हो गया')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('कॉपी'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => shareOnWhatsApp(
                    context,
                    '$_fullText${AppInfo.shareFooter}',
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('WhatsApp'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
