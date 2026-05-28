// Date helpers. All "day keys" are local-time YYYY-MM-DD strings.

String todayKey([DateTime? d]) {
  final x = d ?? DateTime.now();
  final y = x.year.toString().padLeft(4, '0');
  final m = x.month.toString().padLeft(2, '0');
  final day = x.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime dateAdd(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

DateTime parseDayKey(String key) {
  return DateTime(
    int.parse(key.substring(0, 4)),
    int.parse(key.substring(5, 7)),
    int.parse(key.substring(8, 10)),
  );
}

// Whole days between two dates, DST-safe. Negative if `to` is before `from`.
int daysBetween(DateTime from, DateTime to) {
  final f = DateTime.utc(from.year, from.month, from.day);
  final t = DateTime.utc(to.year, to.month, to.day);
  return t.difference(f).inDays;
}

int gapDays(String? lastDate, {DateTime? now}) {
  if (lastDate == null) return 1 << 30;
  return daysBetween(parseDayKey(lastDate), startOfDay(now ?? DateTime.now()));
}
