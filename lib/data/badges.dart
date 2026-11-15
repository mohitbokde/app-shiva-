import 'jap_store.dart';

class BadgeInfo {
  final String title;
  final String detail;
  final bool unlocked;
  const BadgeInfo(this.title, this.detail, this.unlocked);
}

/// जाप के आधार पर मिलने वाले बैज (सब फ़ोन में रखे रिकॉर्ड से निकलते हैं)।
List<BadgeInfo> buildBadges(JapStore s) {
  final life = s.lifetime;
  final best = s.longestStreak;

  BadgeInfo total(String title, int n, String label) {
    return BadgeInfo(title, '$label जाप', life >= BigInt.from(n));
  }

  BadgeInfo streak(String title, int days) {
    return BadgeInfo(title, '$days दिन लगातार', best >= days);
  }

  return [
    BadgeInfo('आज का लक्ष्य', 'रोज़ का लक्ष्य पूरा', s.goalDoneToday),
    total('पहली माला', 108, '108'),
    total('एक हज़ार', 1008, '1,008'),
    total('दस हज़ार', 10008, '10,008'),
    total('एक लाख', 100008, '1,00,008'),
    total('दस लाख', 1000008, '10,00,008'),
    streak('तीन दिन', 3),
    streak('एक सप्ताह', 7),
    streak('इक्कीस दिन', 21),
    streak('चालीस दिन', 40),
    streak('एक सौ आठ दिन', 108),
  ];
}
