import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'youtube_service.dart';

/// पसंदीदा ज्योतिर्लिंग और पसंदीदा भजन (फ़ोन में सेव रहते हैं)।
class FavStore extends ChangeNotifier {
  FavStore._();
  static final FavStore instance = FavStore._();

  final Set<String> _jyotir = {};
  final List<VideoItem> _bhajans = [];
  SharedPreferences? _prefs;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _prefs = p;
    _jyotir.addAll(p.getStringList('fav_jyotir') ?? <String>[]);
    final raw = p.getString('fav_bhajans');
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final e in list) {
          _bhajans.add(VideoItem.fromJson(e as Map<String, dynamic>));
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  Set<String> get jyotirIds => Set.unmodifiable(_jyotir);
  List<VideoItem> get bhajans => List.unmodifiable(_bhajans);

  bool isJyotirFav(String id) => _jyotir.contains(id);

  void toggleJyotir(String id) {
    if (!_jyotir.remove(id)) _jyotir.add(id);
    notifyListeners();
    _prefs?.setStringList('fav_jyotir', _jyotir.toList());
  }

  bool isBhajanFav(String videoId) => _bhajans.any((v) => v.id == videoId);

  void toggleBhajan(VideoItem v) {
    final before = _bhajans.length;
    _bhajans.removeWhere((x) => x.id == v.id);
    if (_bhajans.length == before) _bhajans.insert(0, v);
    notifyListeners();
    _prefs?.setString(
      'fav_bhajans',
      jsonEncode(_bhajans.map((x) => x.toJson()).toList()),
    );
  }
}
