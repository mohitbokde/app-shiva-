// तारीख और बड़ी संख्याओं को दिखाने के छोटे औज़ार।

/// तारीख को "2026-11-03" जैसे पक्के रूप में बदलता है (रिकॉर्ड की चाबी)।
String dateKey(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

DateTime parseKey(String k) {
  final p = k.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

/// भारतीय तरीके से अंक: 12,34,567
String indian(BigInt n) {
  final s = n.toString();
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

/// छोटी जगह के लिए: 12k, 3L, 2Cr
String compact(BigInt n) {
  if (n < BigInt.from(10000)) return n.toString();
  if (n < BigInt.from(100000)) return '${n ~/ BigInt.from(1000)}k';
  if (n < BigInt.from(10000000)) return '${n ~/ BigInt.from(100000)}L';
  return '${n ~/ BigInt.from(10000000)}Cr';
}
