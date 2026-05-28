import '../domain/session.dart';
import 'dates.dart';

int totalMinutes(List<Session> sessions) =>
    sessions.fold(0, (a, s) => a + s.minutes);

int spanDays(List<Session> sessions, {DateTime? now}) {
  if (sessions.isEmpty) return 0;
  final dates = sessions.map((s) => s.date).toList()..sort();
  final first = parseDayKey(dates.first);
  final today = startOfDay(now ?? DateTime.now());
  final d = daysBetween(first, today) + 1;
  return d < 1 ? 1 : d;
}

int uniquePracticeDays(List<Session> sessions) =>
    sessions.map((s) => s.date).toSet().length;

int longestSession(List<Session> sessions) =>
    sessions.fold(0, (m, s) => s.minutes > m ? s.minutes : m);

class Averages {
  final double perWeek;
  final double perMonth;
  final double perSession;
  final double perPracticeDay;
  final double sessionsPerWeek;
  final double consistency; // 0..1
  final int spanDays;
  final int practiceDays;
  final String? bestDay;
  final String? typicalTime;
  final int longestSession;

  const Averages({
    required this.perWeek,
    required this.perMonth,
    required this.perSession,
    required this.perPracticeDay,
    required this.sessionsPerWeek,
    required this.consistency,
    required this.spanDays,
    required this.practiceDays,
    required this.bestDay,
    required this.typicalTime,
    required this.longestSession,
  });
}

Averages? averages(List<Session> sessions, {DateTime? now}) {
  if (sessions.isEmpty) return null;
  final total = totalMinutes(sessions);
  final span = spanDays(sessions, now: now);
  final weeks = span / 7.0;
  final months = span / 30.437;
  final practice = uniquePracticeDays(sessions);
  return Averages(
    perWeek: total / (weeks < 1 ? 1 : weeks),
    perMonth: total / (months < 1 ? 1 : months),
    perSession: total / sessions.length,
    perPracticeDay: total / practice,
    sessionsPerWeek: sessions.length / (weeks < 1 ? 1 : weeks),
    consistency: practice / span,
    spanDays: span,
    practiceDays: practice,
    bestDay: bestDayOfWeek(sessions),
    typicalTime: typicalTimeOfDay(sessions),
    longestSession: longestSession(sessions),
  );
}

String? bestDayOfWeek(List<Session> sessions) {
  if (sessions.isEmpty) return null;
  // DateTime.weekday: 1=Mon..7=Sun. Indexed 0..6 below.
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final totals = List<int>.filled(7, 0);
  for (final s in sessions) {
    final d = parseDayKey(s.date).weekday - 1;
    totals[d] += s.minutes;
  }
  int maxI = 0;
  for (int i = 1; i < 7; i++) {
    if (totals[i] > totals[maxI]) maxI = i;
  }
  return totals[maxI] == 0 ? null : names[maxI];
}

String? typicalTimeOfDay(List<Session> sessions) {
  if (sessions.isEmpty) return null;
  final buckets = {'Morning': 0, 'Midday': 0, 'Evening': 0, 'Night': 0};
  for (final s in sessions) {
    final h = DateTime.fromMillisecondsSinceEpoch(s.ts).hour;
    if (h >= 5 && h < 12) {
      buckets['Morning'] = buckets['Morning']! + s.minutes;
    } else if (h >= 12 && h < 17) {
      buckets['Midday'] = buckets['Midday']! + s.minutes;
    } else if (h >= 17 && h < 22) {
      buckets['Evening'] = buckets['Evening']! + s.minutes;
    } else {
      buckets['Night'] = buckets['Night']! + s.minutes;
    }
  }
  String? best;
  int bestV = -1;
  buckets.forEach((k, v) {
    if (v > bestV) {
      best = k;
      bestV = v;
    }
  });
  return bestV <= 0 ? null : best;
}

// N most-recent weekly buckets (minutes), oldest first.
List<int> weeklyBuckets(List<Session> sessions,
    {int weeks = 8, DateTime? now}) {
  final today = startOfDay(now ?? DateTime.now());
  final buckets = List<int>.filled(weeks, 0);
  for (final s in sessions) {
    final diff = daysBetween(parseDayKey(s.date), today);
    if (diff < 0) continue;
    final wk = weeks - 1 - (diff ~/ 7);
    if (wk >= 0 && wk < weeks) buckets[wk] += s.minutes;
  }
  return buckets;
}

class DayMark {
  final String date;
  final bool on;
  final String label; // single-letter S/M/T/W/T/F/S
  const DayMark({required this.date, required this.on, required this.label});
}

List<DayMark> lastSevenDays(List<Session> sessions, {DateTime? now}) {
  const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final today = startOfDay(now ?? DateTime.now());
  final days = sessions.map((s) => s.date).toSet();
  final out = <DayMark>[];
  for (int i = 6; i >= 0; i--) {
    final d = dateAdd(today, -i);
    final key = todayKey(d);
    out.add(DayMark(date: key, on: days.contains(key), label: labels[d.weekday - 1]));
  }
  return out;
}
