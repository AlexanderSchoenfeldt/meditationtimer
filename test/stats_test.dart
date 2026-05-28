import 'package:flutter_test/flutter_test.dart';
import 'package:intention/data/dates.dart';
import 'package:intention/data/stats.dart';
import 'package:intention/domain/session.dart';

Session sit(DateTime d, {int minutes = 15, int? hour}) {
  final ts = DateTime(d.year, d.month, d.day, hour ?? 8).millisecondsSinceEpoch;
  return Session(date: todayKey(d), minutes: minutes, ts: ts);
}

void main() {
  final today = DateTime(2026, 5, 28); // Thursday
  DateTime back(int n) => dateAdd(today, -n);

  test('totalMinutes sums correctly', () {
    expect(totalMinutes([sit(today, minutes: 10), sit(back(1), minutes: 20)]), 30);
  });

  test('weeklyBuckets puts today in the last bucket', () {
    final s = [sit(today, minutes: 30)];
    final b = weeklyBuckets(s, weeks: 4, now: today);
    expect(b.length, 4);
    expect(b.last, 30);
    expect(b.take(3).every((v) => v == 0), true);
  });

  test('weeklyBuckets correctly groups 8 weeks back', () {
    final s = [
      sit(back(0), minutes: 10),
      sit(back(6), minutes: 5),
      sit(back(7), minutes: 5),
      sit(back(20), minutes: 7),
    ];
    final b = weeklyBuckets(s, weeks: 4, now: today);
    expect(b[3], 15); // today + day-6 = same week (last 7 days)
    expect(b[2], 5); // day-7 = previous week
    expect(b[1], 7); // day-20 is two weeks before that
    expect(b[0], 0);
  });

  test('lastSevenDays builds 7 entries and marks practice days', () {
    final s = [sit(today), sit(back(2))];
    final days = lastSevenDays(s, now: today);
    expect(days.length, 7);
    expect(days.last.on, true); // today
    expect(days[4].on, true); // 2 days ago (index 4 = today-2)
    expect(days.first.on, false); // 6 days ago
  });

  test('bestDayOfWeek picks the highest-minutes weekday', () {
    // today is Thursday. Put more minutes on Sunday (back 4 days).
    final s = [
      sit(today, minutes: 10), // Thu
      sit(back(4), minutes: 60), // Sun
      sit(back(11), minutes: 30), // Sun (prev week)
    ];
    expect(bestDayOfWeek(s), 'Sun');
  });

  test('typicalTimeOfDay buckets by hour', () {
    final s = [
      sit(today, hour: 6, minutes: 30), // Morning
      sit(back(1), hour: 19, minutes: 10), // Evening
      sit(back(2), hour: 7, minutes: 20), // Morning
    ];
    expect(typicalTimeOfDay(s), 'Morning');
  });

  test('averages handles small datasets without divide-by-zero', () {
    final a = averages([sit(today, minutes: 20)], now: today);
    expect(a, isNotNull);
    expect(a!.perSession, 20);
    expect(a.practiceDays, 1);
    expect(a.longestSession, 20);
  });
}
