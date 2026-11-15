import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/format.dart';

/// YouTube की चाबी (API key) बिल्ड के समय GitHub Secret से आती है।
const String _apiKey = String.fromEnvironment('YOUTUBE_API_KEY');

class VideoItem {
  final String id;
  final String title;
  final String channel;
  final String thumb;
  const VideoItem({
    required this.id,
    required this.title,
    required this.channel,
    required this.thumb,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'channel': channel,
        'thumb': thumb,
      };

  factory VideoItem.fromJson(Map<String, dynamic> j) => VideoItem(
        id: j['id'] as String,
        title: (j['title'] as String?) ?? '',
        channel: (j['channel'] as String?) ?? '',
        thumb: (j['thumb'] as String?) ?? '',
      );
}

class YtResult {
  final List<VideoItem> items;
  final bool fromCache;
  final String? cacheDate;
  final String? error;
  const YtResult(
    this.items, {
    this.fromCache = false,
    this.cacheDate,
    this.error,
  });
}

class YoutubeService {
  static bool get hasKey => _apiKey.isNotEmpty;

  static final Map<String, Future<YtResult>> _inflight = {};

  /// YouTube पर खोज। नतीजा दिन भर के लिए फ़ोन में सेव रहता है,
  /// यानी दिन में एक बार ही असली खोज होती है और नेट न हो तो पुरानी सूची दिखती है।
  static Future<YtResult> search(
    String q, {
    String order = 'relevance',
    int maxResults = 15,
    int? lastDays,
    bool force = false,
  }) {
    final key = 'ytc|$order|$maxResults|${lastDays ?? 0}|$q';
    if (!force && _inflight.containsKey(key)) {
      return _inflight[key]!;
    }
    final f = _doSearch(key, q, order, maxResults, lastDays, force);
    _inflight[key] = f;
    f.whenComplete(() => _inflight.remove(key));
    return f;
  }

  static Future<YtResult> _doSearch(
    String key,
    String q,
    String order,
    int maxResults,
    int? lastDays,
    bool force,
  ) async {
    List<VideoItem>? cached;
    String? cachedDate;
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw != null) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        cachedDate = m['date'] as String?;
        cached = (m['items'] as List<dynamic>)
            .map((e) => VideoItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      cached = null;
    }

    final today = dateKey(DateTime.now());
    if (!force && cached != null && cachedDate == today) {
      return YtResult(cached, fromCache: true, cacheDate: cachedDate);
    }

    if (!hasKey) {
      if (cached != null) {
        return YtResult(cached, fromCache: true, cacheDate: cachedDate);
      }
      return const YtResult([], error: 'NO_KEY');
    }

    try {
      final params = <String, String>{
        'part': 'snippet',
        'type': 'video',
        'maxResults': '$maxResults',
        'q': q,
        'order': order,
        'regionCode': 'IN',
        'relevanceLanguage': 'hi',
        'safeSearch': 'strict',
        'key': _apiKey,
      };
      if (lastDays != null) {
        final d = DateTime.now().toUtc().subtract(Duration(days: lastDays));
        params['publishedAfter'] =
            DateTime.utc(d.year, d.month, d.day).toIso8601String();
      }
      final uri = Uri.https('www.googleapis.com', '/youtube/v3/search', params);
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      if (res.statusCode != 200) {
        final err = body['error'];
        var msg = 'YouTube error ${res.statusCode}';
        if (err is Map<String, dynamic> && err['message'] != null) {
          msg = err['message'].toString();
        }
        throw Exception(msg);
      }

      final items = <VideoItem>[];
      final list = (body['items'] as List<dynamic>?) ?? <dynamic>[];
      for (final e in list) {
        final m = e as Map<String, dynamic>;
        final idMap = m['id'] as Map<String, dynamic>?;
        final vid = idMap?['videoId'] as String?;
        final sn = m['snippet'] as Map<String, dynamic>?;
        if (vid == null || sn == null) continue;
        final thumbs = sn['thumbnails'] as Map<String, dynamic>?;
        final t = (thumbs?['medium'] ?? thumbs?['default']) as Map<String, dynamic>?;
        items.add(VideoItem(
          id: vid,
          title: _clean(sn['title']?.toString() ?? ''),
          channel: _clean(sn['channelTitle']?.toString() ?? ''),
          thumb: t?['url']?.toString() ?? '',
        ));
      }

      if (prefs != null) {
        await prefs.setString(
          key,
          jsonEncode({
            'date': today,
            'items': items.map((v) => v.toJson()).toList(),
          }),
        );
      }
      return YtResult(items);
    } catch (e) {
      if (cached != null) {
        return YtResult(
          cached,
          fromCache: true,
          cacheDate: cachedDate,
          error: e.toString(),
        );
      }
      return YtResult(const [], error: e.toString());
    }
  }

  static String _clean(String s) {
    return s
        .replaceAll('&amp;', '&')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }

  static Future<bool> openUrl(Uri u) async {
    try {
      return await launchUrl(u, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openVideo(String id) {
    return openUrl(Uri.https('www.youtube.com', '/watch', {'v': id}));
  }

  /// सीधे YouTube की खोज खोलता है (API key के बिना भी काम करता है)।
  static Future<bool> openSearch(String q, {bool newest = false}) {
    final params = <String, String>{'search_query': q};
    if (newest) params['sp'] = 'CAI=';
    return openUrl(Uri.https('www.youtube.com', '/results', params));
  }
}
