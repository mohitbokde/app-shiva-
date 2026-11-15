import 'package:flutter/material.dart';

import '../data/hindi_date.dart';
import '../data/jap_store.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/bar_chart.dart';
import '../widgets/common.dart';

/// जाप का इतिहास: दैनिक, मासिक, वार्षिक और कैलेंडर।
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('जाप का इतिहास'),
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSoft,
            tabs: [
              Tab(text: 'दैनिक'),
              Tab(text: 'मासिक'),
              Tab(text: 'वार्षिक'),
              Tab(text: 'कैलेंडर'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DailyTab(),
            _MonthlyTab(),
            _YearlyTab(),
            _CalendarTab(),
          ],
        ),
      ),
    );
  }
}

Widget _emptyNote() {
  return const Padding(
    padding: EdgeInsets.all(24),
    child: Text(
      'अभी कोई जाप दर्ज नहीं है। जाप शुरू करते ही यहाँ तारीख के हिसाब से दिखेगा।',
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.textSoft, fontSize: 16, height: 1.5),
    ),
  );
}

// ---------------- दैनिक ----------------

class _DailyTab extends StatelessWidget {
  const _DailyTab();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: JapStore.instance,
      builder: (context, _) {
        final store = JapStore.instance;
        final entries = store.entriesDesc();
        final now = DateTime.now();
        final last30 = <BarItem>[];
        for (var i = 29; i >= 0; i--) {
          final d = DateTime(now.year, now.month, now.day - i);
          last30.add(BarItem('${d.day}', store.countOn(d)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return GlowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('पिछले 30 दिन'),
                    BarChart(items: last30, height: 110),
                    if (entries.isEmpty) _emptyNote(),
                  ],
                ),
              );
            }
            final e = entries[i - 1];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentDark, width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hindiDate(parseKey(e.key)),
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    indian(e.value),
                    style: const TextStyle(
                      color: AppColors.accentLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------- मासिक ----------------

class _MonthlyTab extends StatefulWidget {
  const _MonthlyTab();

  @override
  State<_MonthlyTab> createState() => _MonthlyTabState();
}

class _MonthlyTabState extends State<_MonthlyTab> {
  int _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: JapStore.instance,
      builder: (context, _) {
        final store = JapStore.instance;
        final months = <BigInt>[];
        for (var m = 1; m <= 12; m++) {
          months.add(store.monthTotal(_year, m));
        }
        final chart = <BarItem>[];
        for (var m = 1; m <= 12; m++) {
          chart.add(BarItem('$m', months[m - 1]));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => setState(() => _year--),
                ),
                Text(
                  '$_year',
                  style: const TextStyle(
                    color: AppColors.accentLight,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => setState(() => _year++),
                ),
              ],
            ),
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('महीने के हिसाब से जाप'),
                  BarChart(items: chart, height: 110, showValues: true),
                  const SizedBox(height: 6),
                  Text(
                    'इस साल का कुल: ${indian(store.yearTotal(_year))}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            for (var m = 12; m >= 1; m--)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentDark, width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${hindiMonthName(m)} $_year',
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      indian(months[m - 1]),
                      style: TextStyle(
                        color: months[m - 1] > BigInt.zero
                            ? AppColors.accentLight
                            : AppColors.accentDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------- वार्षिक ----------------

class _YearlyTab extends StatelessWidget {
  const _YearlyTab();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: JapStore.instance,
      builder: (context, _) {
        final totals = JapStore.instance.yearTotals();
        if (totals.isEmpty) return ListView(children: [_emptyNote()]);
        final years = totals.keys.toList()..sort();
        final chart = <BarItem>[
          for (final y in years) BarItem('$y', totals[y] ?? BigInt.zero),
        ];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('साल के हिसाब से जाप'),
                  BarChart(items: chart, height: 110, showValues: true),
                ],
              ),
            ),
            for (final y in years.reversed)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentDark, width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$y',
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      indian(totals[y] ?? BigInt.zero),
                      style: const TextStyle(
                        color: AppColors.accentLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            GlowCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'अब तक का कुल जाप',
                    style: TextStyle(color: AppColors.accent, fontSize: 16),
                  ),
                  Text(
                    indian(JapStore.instance.lifetime),
                    style: const TextStyle(
                      color: AppColors.accentLight,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------- कैलेंडर ----------------

class _CalendarTab extends StatefulWidget {
  const _CalendarTab();

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  DateTime? _selected;

  void _shiftMonth(int delta) {
    setState(() {
      var m = _month + delta;
      var y = _year;
      while (m < 1) {
        m += 12;
        y--;
      }
      while (m > 12) {
        m -= 12;
        y++;
      }
      _month = m;
      _year = y;
      _selected = null;
    });
  }

  void _shiftYear(int delta) {
    setState(() {
      _year += delta;
      _selected = null;
    });
  }

  Widget _dayCell(int day, JapStore store) {
    final d = DateTime(_year, _month, day);
    final count = store.countOn(d);
    final isSel = _selected != null &&
        _selected!.year == d.year &&
        _selected!.month == d.month &&
        _selected!.day == d.day;
    final now = DateTime.now();
    final isToday =
        now.year == d.year && now.month == d.month && now.day == d.day;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _selected = d),
        child: Container(
          decoration: BoxDecoration(
            color: count > BigInt.zero ? AppColors.accentFaint : AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSel
                  ? AppColors.accentLight
                  : (isToday ? AppColors.accent : AppColors.accentDark),
              width: isSel || isToday ? 1.6 : 0.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: const TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (count > BigInt.zero)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    compact(count),
                    style: const TextStyle(
                      color: AppColors.accentLight,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: JapStore.instance,
      builder: (context, _) {
        final store = JapStore.instance;
        final lead = DateTime(_year, _month, 1).weekday - 1;
        final daysInMonth = DateTime(_year, _month + 1, 0).day;

        final cells = <Widget>[];
        for (var i = 0; i < lead; i++) {
          cells.add(const SizedBox());
        }
        for (var d = 1; d <= daysInMonth; d++) {
          cells.add(_dayCell(d, store));
        }
        while (cells.length % 7 != 0) {
          cells.add(const SizedBox());
        }

        final rows = <Widget>[];
        for (var r = 0; r < cells.length; r += 7) {
          rows.add(
            Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 0.85,
                      child: cells[r + c],
                    ),
                  ),
              ],
            ),
          );
        }

        final sel = _selected;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'पिछला साल',
                  icon: const Icon(Icons.keyboard_double_arrow_left_rounded),
                  onPressed: () => _shiftYear(-1),
                ),
                IconButton(
                  tooltip: 'पिछला महीना',
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => _shiftMonth(-1),
                ),
                Expanded(
                  child: Text(
                    '${hindiMonthName(_month)} $_year',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.accentLight,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'अगला महीना',
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => _shiftMonth(1),
                ),
                IconButton(
                  tooltip: 'अगला साल',
                  icon: const Icon(Icons.keyboard_double_arrow_right_rounded),
                  onPressed: () => _shiftYear(1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final w in hindiWeekdayShort)
                  Expanded(
                    child: Center(
                      child: Text(
                        w,
                        style: const TextStyle(
                          color: AppColors.accentDark,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            ...rows,
            const SizedBox(height: 12),
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'इस महीने का कुल जाप: ${indian(store.monthTotal(_year, _month))}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (sel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${hindiDate(sel)}: ${indian(store.countOn(sel))} जाप',
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 15,
                      ),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'किसी तारीख पर दबाएँ, उस दिन का जाप दिखेगा।',
                        style: TextStyle(
                          color: AppColors.accentDark,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
