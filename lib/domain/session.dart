import 'package:flutter/foundation.dart';

@immutable
class Session {
  final String date; // YYYY-MM-DD
  final int minutes;
  final int ts; // unix millis
  final String? type;
  final bool imported;
  final bool summary;

  const Session({
    required this.date,
    required this.minutes,
    required this.ts,
    this.type,
    this.imported = false,
    this.summary = false,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'minutes': minutes,
        'ts': ts,
        if (type != null) 'type': type,
        if (imported) 'imported': true,
        if (summary) 'summary': true,
      };

  factory Session.fromJson(Map<String, dynamic> j) => Session(
        date: j['date'] as String,
        minutes: (j['minutes'] as num).toInt(),
        ts: j['ts'] is num
            ? (j['ts'] as num).toInt()
            : DateTime.parse('${j['date']}T08:00:00').millisecondsSinceEpoch,
        type: j['type'] as String?,
        imported: j['imported'] == true,
        summary: j['summary'] == true,
      );
}
