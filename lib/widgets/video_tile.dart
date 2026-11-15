import 'package:flutter/material.dart';

import '../data/fav_store.dart';
import '../data/youtube_service.dart';
import '../theme.dart';

/// एक YouTube वीडियो की पंक्ति: फ़ोटो, शीर्षक, चैनल। दबाने पर असली वीडियो खुलता है।
class VideoTile extends StatelessWidget {
  final VideoItem video;
  final bool showFav;
  const VideoTile({super.key, required this.video, this.showFav = true});

  Widget _placeholder() {
    return Container(
      color: AppColors.card,
      alignment: Alignment.center,
      child: const Icon(Icons.play_circle_outline, color: AppColors.accent),
    );
  }

  Future<void> _open(BuildContext context) async {
    final ok = await YoutubeService.openVideo(video.id);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('YouTube नहीं खुल सका')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _open(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accentDark, width: 0.8),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 120,
                  height: 68,
                  child: video.thumb.isEmpty
                      ? _placeholder()
                      : Image.network(
                          video.thumb,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _placeholder(),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.channel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.accentDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (showFav)
                AnimatedBuilder(
                  animation: FavStore.instance,
                  builder: (context, _) {
                    final fav = FavStore.instance.isBhajanFav(video.id);
                    return IconButton(
                      icon: Icon(
                        fav ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.accent,
                      ),
                      onPressed: () => FavStore.instance.toggleBhajan(video),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
