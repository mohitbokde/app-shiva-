import 'package:flutter/material.dart';

import '../data/fav_store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/video_tile.dart';
import '../widgets/yt_section.dart';

/// शिव भजन: नए, लोकप्रिय, खोज और पसंदीदा।
class BhajanScreen extends StatefulWidget {
  const BhajanScreen({super.key});

  @override
  State<BhajanScreen> createState() => _BhajanScreenState();
}

class _BhajanScreenState extends State<BhajanScreen> {
  final TextEditingController _search = TextEditingController();
  int _mode = 0; // 0 नए, 1 लोकप्रिय, 2 पसंदीदा
  String _query = '';
  int _tick = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _doSearch(String text) {
    FocusScope.of(context).unfocus();
    setState(() {
      _query = text.trim();
      _tick++;
    });
  }

  Widget _modeChip(String label, int m) {
    final selected = _mode == m && _query.isEmpty;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.accentFaint,
      backgroundColor: AppColors.card,
      labelStyle: TextStyle(
        color: selected ? AppColors.accentLight : AppColors.textSoft,
      ),
      side: const BorderSide(color: AppColors.accentDark),
      onSelected: (_) {
        _search.clear();
        setState(() {
          _mode = m;
          _query = '';
        });
      },
    );
  }

  Widget _body() {
    if (_query.isNotEmpty) {
      return YtSection(
        key: ValueKey('s|$_query|$_tick'),
        query: _query,
        maxResults: 15,
        forceRefresh: _tick > 0,
      );
    }
    if (_mode == 2) {
      return AnimatedBuilder(
        animation: FavStore.instance,
        builder: (context, _) {
          final favs = FavStore.instance.bhajans;
          if (favs.isEmpty) {
            return const GlowCard(
              child: Text(
                'अभी कोई पसंदीदा भजन नहीं है। किसी भजन के आगे ♡ दबाकर यहाँ जोड़ें।',
                style: TextStyle(color: AppColors.textSoft, fontSize: 15),
              ),
            );
          }
          return Column(
            children: [for (final v in favs) VideoTile(video: v)],
          );
        },
      );
    }
    if (_mode == 1) {
      return YtSection(
        key: ValueKey('p|$_tick'),
        query: 'शिव भजन',
        order: 'viewCount',
        lastDays: 365,
        maxResults: 15,
        forceRefresh: _tick > 0,
      );
    }
    return YtSection(
      key: ValueKey('n|$_tick'),
      query: 'शिव भजन',
      order: 'date',
      lastDays: 30,
      maxResults: 15,
      forceRefresh: _tick > 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _search,
          textInputAction: TextInputAction.search,
          onSubmitted: _doSearch,
          style: const TextStyle(color: AppColors.textSoft),
          decoration: InputDecoration(
            hintText: 'भजन खोजें (जैसे: भोलेनाथ)',
            hintStyle: const TextStyle(color: AppColors.accentDark),
            prefixIcon: const Icon(Icons.search, color: AppColors.accent),
            suffixIcon: IconButton(
              tooltip: 'ताज़ा करें',
              icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
              onPressed: () => setState(() => _tick++),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.accentDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _modeChip('नए भजन', 0),
            _modeChip('लोकप्रिय', 1),
            _modeChip('पसंदीदा', 2),
          ],
        ),
        if (_query.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'खोज: $_query',
              style: const TextStyle(color: AppColors.accentDark, fontSize: 13),
            ),
          ),
        const SizedBox(height: 14),
        _body(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'नए भजन की सूची हर दिन YouTube से अपने-आप नई आती है।',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.accentDark, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
