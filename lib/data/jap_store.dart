import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/format.dart';

class JapMantra {
  final String id;
  final String name;
  final String text;
  const JapMantra(this.id, this.name, this.text);
}

const List<JapMantra> japMantras = [
  JapMantra('om_namah', 'ॐ नमः शिवाय', 'ॐ नमः शिवाय'),
  JapMantra(
    'mrityunjay',
    'महामृत्युंजय मंत्र',
    'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्।\n'
        'उर्वारुकमिव बन्धनान्मृत्योर्मुक्षीय मामृतात्॥',
  ),
  JapMantra('shiv', 'शिव मंत्र', 'ॐ नमो भगवते रुद्राय'),
];

final BigInt _malaSize = BigInt.from(108);

/// एक टैप के बाद क्या हुआ: माला पूरी हुई? आज का लक्ष्य पूरा हुआ?
class TapResult {
  final bool malaDone;
  final bool goalReached;
  const TapResult(this.malaDone, this.goalReached);
}

/// नाम जाप का पूरा हिसाब।
/// हर तारीख की गिनती अलग सेव होती है (BigInt, इसलिए कोई सीमा नहीं)।
/// आज, महीना, साल और कुल, सब इन्हीं तारीख वाले रिकॉर्ड से निकाले जाते हैं।
/// कुछ भी अपने-आप मिटता या रीसेट नहीं होता।
class JapStore extends ChangeNotifier {
  JapStore._();
  static final JapStore instance = JapStore._();

  final Map<String, BigInt> _days = {};
  BigInt _lifetime = BigInt.zero;

  String selectedId = 'om_namah';
  String customMantra = '';
  bool vibrate = true;
  int goal = 108; // रोज़ का लक्ष्य

  Timer? _saveTimer;
  Timer? _midnightTimer;
  SharedPreferences? _prefs;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _prefs = p;
    final raw = p.getString('jap_days');
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        m.forEach((k, v) {
          _days[k] = BigInt.parse(v.toString());
        });
      } catch (_) {
        // रिकॉर्ड बिगड़ा हो तो पुराना टेक्स्ट बैकअप में रख लेते हैं।
        await p.setString('jap_days_corrupt_backup', raw);
        _days.clear();
      }
    }
    _lifetime = _days.values.fold<BigInt>(BigInt.zero, (a, b) => a + b);
    selectedId = p.getString('jap_selected') ?? 'om_namah';
    customMantra = p.getString('jap_custom') ?? '';
    vibrate = p.getBool('jap_vibrate') ?? true;
    goal = p.getInt('jap_goal') ?? 108;
    _scheduleMidnight();
    notifyListeners();
  }

  // ---------- मंत्र चुनना ----------

  String get currentMantraName {
    if (selectedId == 'custom') return 'अपना मंत्र';
    return japMantras
        .firstWhere((m) => m.id == selectedId, orElse: () => japMantras.first)
        .name;
  }

  String get currentMantraText {
    if (selectedId == 'custom') {
      return customMantra.isEmpty ? 'अपना मंत्र लिखें' : customMantra;
    }
    return japMantras
        .firstWhere((m) => m.id == selectedId, orElse: () => japMantras.first)
        .text;
  }

  void select(String id) {
    selectedId = id;
    notifyListeners();
    _prefs?.setString('jap_selected', id);
  }

  void setCustom(String text) {
    customMantra = text;
    selectedId = 'custom';
    notifyListeners();
    _prefs?.setString('jap_custom', text);
    _prefs?.setString('jap_selected', 'custom');
  }

  void setVibrate(bool v) {
    vibrate = v;
    notifyListeners();
    _prefs?.setBool('jap_vibrate', v);
  }

  void setGoal(int g) {
    goal = g.clamp(1, 100000000).toInt();
    notifyListeners();
    _prefs?.setInt('jap_goal', goal);
  }

  // ---------- गिनती ----------

  /// हर टैप पर ठीक +1। बताता है कि माला (108) या आज का लक्ष्य पूरा हुआ या नहीं।
  TapResult tap() {
    final key = dateKey(DateTime.now());
    final todayCount = (_days[key] ?? BigInt.zero) + BigInt.one;
    _days[key] = todayCount;
    _lifetime += BigInt.one;
    final done = (_lifetime % _malaSize) == BigInt.zero;
    final goalHit = todayCount == BigInt.from(goal);
    if (vibrate) {
      if (done) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
    notifyListeners();
    _scheduleSave();
    return TapResult(done, goalHit);
  }

  BigInt get lifetime => _lifetime;

  bool get goalDoneToday => today >= BigInt.from(goal);

  /// 0.0 से 1.0 तक: आज का लक्ष्य कितना पूरा हुआ
  double get goalProgress {
    final g = BigInt.from(goal);
    if (today >= g) return 1.0;
    return (today * BigInt.from(1000) ~/ g).toInt() / 1000.0;
  }

  BigInt countOn(DateTime d) => _days[dateKey(d)] ?? BigInt.zero;

  BigInt get today => countOn(DateTime.now());

  BigInt get malaCount => _lifetime ~/ _malaSize;

  /// मौजूदा माला में कितने मनके हुए (0 से 108)।
  int get malaPosition {
    final r = (_lifetime % _malaSize).toInt();
    if (r == 0 && _lifetime > BigInt.zero) return 108;
    return r;
  }

  BigInt _sumPrefix(String prefix) {
    var s = BigInt.zero;
    _days.forEach((k, v) {
      if (k.startsWith(prefix)) s += v;
    });
    return s;
  }

  BigInt monthTotal(int year, int month) {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    return _sumPrefix('$y-$m-');
  }

  BigInt yearTotal(int year) {
    return _sumPrefix('${year.toString().padLeft(4, '0')}-');
  }

  BigInt get thisMonth {
    final n = DateTime.now();
    return monthTotal(n.year, n.month);
  }

  BigInt get thisYear => yearTotal(DateTime.now().year);

  /// लगातार कितने दिन जाप हुआ। आज अभी शुरू न हुआ हो तो कल तक की गिनती।
  int get streak {
    final n = DateTime.now();
    var d = DateTime(n.year, n.month, n.day);
    if (countOn(d) == BigInt.zero) {
      d = DateTime(d.year, d.month, d.day - 1);
    }
    var count = 0;
    while (countOn(d) > BigInt.zero) {
      count++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return count;
  }

  /// अब तक का सबसे लंबा लगातार जाप का सिलसिला (दिनों में)।
  int get longestStreak {
    final keys = _days.entries
        .where((e) => e.value > BigInt.zero)
        .map((e) => e.key)
        .toList()
      ..sort();
    var best = 0;
    var run = 0;
    DateTime? prev;
    for (final k in keys) {
      final p = k.split('-');
      final d = DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
      if (prev != null && d.difference(prev).inDays == 1) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  /// जिन दिनों जाप हुआ, नए से पुराने क्रम में।
  List<MapEntry<String, BigInt>> entriesDesc() {
    final list = _days.entries.where((e) => e.value > BigInt.zero).toList();
    list.sort((a, b) => b.key.compareTo(a.key));
    return list;
  }

  /// साल -> उस साल का कुल जाप
  Map<int, BigInt> yearTotals() {
    final out = <int, BigInt>{};
    _days.forEach((k, v) {
      if (v > BigInt.zero) {
        final y = int.parse(k.substring(0, 4));
        out[y] = (out[y] ?? BigInt.zero) + v;
      }
    });
    return out;
  }

  // ---------- सेव और आधी रात ----------

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), flush);
  }

  /// तुरंत सेव करें (ऐप बंद या पीछे जाते समय भी यही चलता है)।
  Future<void> flush() async {
    _saveTimer?.cancel();
    final p = _prefs ?? await SharedPreferences.getInstance();
    final m = <String, String>{};
    _days.forEach((k, v) {
      m[k] = v.toString();
    });
    await p.setString('jap_days', jsonEncode(m));
  }

  void _scheduleMidnight() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer =
        Timer(next.difference(now) + const Duration(seconds: 1), () {
      notifyListeners();
      _scheduleMidnight();
    });
  }

  /// ऐप वापस खुलने पर तारीख के हिसाब से स्क्रीन ताज़ा करें।
  void refresh() {
    _scheduleMidnight();
    notifyListeners();
  }
}
