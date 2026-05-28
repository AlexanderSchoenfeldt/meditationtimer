import 'package:flutter_test/flutter_test.dart';
import 'package:intention/data/dates.dart';
import 'package:intention/data/streak.dart';
import 'package:intention/domain/session.dart';

Session sit(DateTime d, {int minutes = 15}) => Session(
      date: todayKey(d),
      minutes: minutes,
      ts: d.millisecondsSinceEpoch,
    );

void main() {
  // Fixed reference "today" so tests don't drift with the wall clock.
  final today = DateTime(2026, 5, 28);
  DateTime back(int n) => dateAdd(today, -n);

  group('computeStreak', () {
    test('empty sessions', () {
      final r = computeStreak(const [], now: today);
      expect(r.streak, 0);
      expect(r.doneToday, false);
      expect(r.lastDate, isNull);
    });

    test('done today only', () {
      final r = computeStreak([sit(today)], now: today);
      expect(r.streak, 1);
      expect(r.doneToday, true);
    });

    test('done yesterday only', () {
      final r = computeStreak([sit(back(1))], now: today);
      expect(r.streak, 1);
      expect(r.doneToday, false);
    });

    test('three consecutive ending today', () {
      final r = computeStreak(
        [sit(back(2)), sit(back(1)), sit(today)],
        now: today,
      );
      expect(r.streak, 3);
      expect(r.doneToday, true);
    });

    test('three consecutive ending yesterday — still continues', () {
      final r = computeStreak(
        [sit(back(3)), sit(back(2)), sit(back(1))],
        now: today,
      );
      expect(r.streak, 3);
      expect(r.doneToday, false);
    });

    test('gap of 2 days breaks the streak', () {
      final r = computeStreak(
        [sit(back(4)), sit(back(3)), sit(back(2))],
        now: today,
      );
      expect(r.streak, 0);
    });

    test('multiple sits on the same day count once', () {
      final r = computeStreak(
        [sit(today), sit(today, minutes: 5), sit(back(1))],
        now: today,
      );
      expect(r.streak, 2);
    });
  });

  group('longestStreak', () {
    test('empty', () => expect(longestStreak(const []), 0));

    test('single day', () => expect(longestStreak([sit(today)]), 1));

    test('5 in a row with a 1-day break, then 3', () {
      final s = [
        sit(back(20)),
        sit(back(19)),
        sit(back(18)),
        sit(back(17)),
        sit(back(16)),
        // gap
        sit(back(10)),
        sit(back(9)),
        sit(back(8)),
      ];
      expect(longestStreak(s), 5);
    });

    test('duplicates on same day do not inflate', () {
      final s = [
        sit(back(2)),
        sit(back(2), minutes: 5),
        sit(back(1)),
        sit(today),
      ];
      expect(longestStreak(s), 3);
    });
  });
}
