const List<String> _weekdays = [
  'सोमवार',
  'मंगलवार',
  'बुधवार',
  'गुरुवार',
  'शुक्रवार',
  'शनिवार',
  'रविवार',
];

const List<String> _months = [
  'जनवरी',
  'फ़रवरी',
  'मार्च',
  'अप्रैल',
  'मई',
  'जून',
  'जुलाई',
  'अगस्त',
  'सितंबर',
  'अक्टूबर',
  'नवंबर',
  'दिसंबर',
];

/// जैसे: सोमवार, 2 नवंबर 2026
String hindiDate(DateTime d) {
  return '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';
}

String hindiMonth(int month) => _months[month - 1];

/// सोमवार से शुरू होने वाले छोटे नाम
const List<String> hindiWeekShort = ['सो', 'मं', 'बु', 'गु', 'शु', 'श', 'र'];

String hindiMonthName(int month) => _months[month - 1];

/// सोमवार से शुरू
const List<String> hindiWeekdayShort = [
  'सोम',
  'मंगल',
  'बुध',
  'गुरु',
  'शुक्र',
  'शनि',
  'रवि',
];
