import 'package:flutter/material.dart';

import '../data/youtube_service.dart';
import '../theme.dart';
import 'common.dart';
import 'video_tile.dart';

/// YouTube से वीडियो की सूची लाकर दिखाता है।
/// लोड होते समय घूमता गोला, गलती पर साफ़ संदेश, और नेट न हो तो पुरानी सेव सूची।
class YtSection extends StatefulWidget {
  final String query;
  final String order;
  final int? lastDays;
  final int maxResults;
  final int? limit;
  final bool showFav;
  final bool showMore;
  final bool forceRefresh;
  const YtSection({
    super.key,
    required this.query,
    this.order = 'relevance',
    this.lastDays,
    this.maxResults = 15,
    this.limit,
    this.showFav = true,
    this.showMore = true,
    this.forceRefresh = false,
  });

  @override
  State<YtSection> createState() => _YtSectionState();
}

class _YtSectionState extends State<YtSection> {
  late Future<YtResult> _future;

  @override
  void initState() {
    super.initState();
    _future = YoutubeService.search(
      widget.query,
      order: widget.order,
      maxResults: widget.maxResults,
      lastDays: widget.lastDays,
      force: widget.forceRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<YtResult>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(28),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        final r = snap.data ?? const YtResult([], error: 'अज्ञात गलती');
        final children = <Widget>[];

        if (r.error == 'NO_KEY') {
          children.add(
            const GlowCard(
              child: Text(
                'YouTube की सूची यहीं दिखाने के लिए एक बार YouTube की चाबी (API key) जोड़नी होगी। '
                'तब तक नीचे के बटन से सीधे YouTube पर देख सकते हैं।',
                style: TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          );
        } else if (r.items.isEmpty) {
          children.add(
            GlowCard(
              child: Text(
                r.error != null
                    ? 'YouTube से जानकारी नहीं मिल सकी। इंटरनेट जाँचकर दोबारा कोशिश करें।'
                    : 'कोई वीडियो नहीं मिला।',
                style: const TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 15,
                ),
              ),
            ),
          );
        } else {
          if (r.error != null && r.fromCache) {
            children.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'ताज़ा सूची नहीं मिली। ${r.cacheDate ?? ''} की सेव की हुई सूची दिख रही है।',
                  style: const TextStyle(
                    color: AppColors.accentDark,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }
          final lim = widget.limit;
          final shown = lim == null ? r.items : r.items.take(lim).toList();
          for (final v in shown) {
            children.add(VideoTile(video: v, showFav: widget.showFav));
          }
        }

        if (widget.showMore) {
          children.add(
            Center(
              child: OutlinedButton.icon(
                onPressed: () => YoutubeService.openSearch(
                  widget.query,
                  newest: widget.order == 'date',
                ),
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('YouTube पर और देखें'),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }
}
