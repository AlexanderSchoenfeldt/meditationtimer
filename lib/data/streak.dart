import '../domain/session.dart';
import 'dates.dart';

class StreakInfo {
  final int streak;
  final bool doneToday;
  final String? lastDate;
  const StreakInfo(
      {required this.streak, required this.doneToday, this.lastDate});
}

String? lastSessionDate(List<Session> sessions) {
  if (sessions.isEmpty) return null;
  String latest = sessions.first.date;
  for (final s in sessions) {
    if (s.date.compareTo(latest) > 0) latest = s.date;
  }
  return latest;
}

// Consecutive days ending at today, or yesterday if today not done.
StreakInfo computeStreak(List<Session> sessions, {DateTime? now}) {
  final today = startOfDay(now ?? DateTime.now());
  final todayK = todayKey(today);
  final yKey = todayKey(dateAdd(today, -1));
  final days = sessions.map((s) => s.date).toSet();
  final last = lastSessionDate(sessions);

  DateTime cursor;
  if (days.contains(todayK)) {
    cursor = today;
  } else if (days.contains(yKey)) {
    cursor = dateAdd(today, -1);
  } else {
    return StreakInfo(streak: 0, doneToday: false, lastDate: last);
  }

  int streak = 0;
  while (days.contains(todayKey(cursor))) {
    streak++;
    cursor = dateAdd(cursor, -1);
  }
  return StreakInfo(
      streak: streak, doneToday: days.contains(todayK), lastDate: last);
}

int longestStreak(List<Session> sessions) {
  if (sessions.isEmpty) return 0;
  final days = sessions.map((s) => s.date).toSet().toList()..sort();
  int best = 1, cur = 1;
  for (int i = 1; i < days.length; i++) {
    final diff = daysBetween(parseDayKey(days[i - 1]), parseDayKey(days[i]));
    if (diff == 1) {
      cur++;
      if (cur > best) best = cur;
    } else {
      cur = 1;
    }
  }
  return best;
}
