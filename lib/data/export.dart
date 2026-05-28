import 'dart:convert';

import '../domain/app_state.dart';
import '../domain/session.dart';
import 'dates.dart';
import 'stats.dart';

String exportText(AppState state, {DateTime? now}) {
  final stamp = (now ?? DateTime.now()).toUtc().toIso8601String();
  final head = [
    '# Intention — a record of your practice',
    '# This file lives only on your device. Keep it private.',
    '# Exported $stamp',
    '#',
    '# ${state.sessions.length} sits · ${totalMinutes(state.sessions)} minutes total',
    '',
  ].join('\n');
  return '$head${const JsonEncoder.withIndent('  ').convert(state.toJson())}\n';
}

Map<String, dynamic> importText(String text) {
  final lines = text.split('\n');
  int i = 0;
  while (i < lines.length &&
      (lines[i].startsWith('#') || lines[i].trim().isEmpty)) {
    i++;
  }
  final json = lines.sublist(i).join('\n');
  final decoded = jsonDecode(json);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Expected a JSON object at root.');
  }
  return decoded;
}

class ImportException implements Exception {
  final String message;
  const ImportException(this.message);
  @override
  String toString() => message;
}

// Apply an imported file to the existing state.
// - Full backup (has onboarded + settings + sessions array) → replace state.
// - Partial import (sessions and/or summary) → merge.
AppState applyImport(AppState state, Map<String, dynamic> parsed,
    {DateTime? now}) {
  final isFullBackup = parsed.containsKey('onboarded') &&
      parsed['settings'] is Map &&
      parsed['sessions'] is List;

  if (isFullBackup) {
    return AppState.fromJson(parsed);
  }

  final rawSessions = parsed['sessions'];
  final hasSessions = rawSessions is List && rawSessions.isNotEmpty;
  final rawSummary = parsed['summary'];
  final hasSummary = rawSummary is Map &&
      (num.tryParse('${rawSummary['days']}') ?? 0) > 0;

  if (!hasSessions && !hasSummary) {
    throw const ImportException(
        'Add at least one sit, or set summary.days > 0.');
  }

  final imported = <Session>[];

  if (hasSessions) {
    for (final raw in rawSessions) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final date = m['date'];
      final minutes = num.tryParse('${m['minutes']}') ?? 0;
      if (date is! String || minutes <= 0) continue;
      imported.add(Session(
        date: date,
        minutes: minutes.toInt(),
        ts: m['ts'] is num
            ? (m['ts'] as num).toInt()
            : DateTime.parse('${date}T08:00:00').millisecondsSinceEpoch,
        type: m['type'] as String?,
        imported: true,
      ));
    }
  }

  if (hasSummary) {
    final summary = Map<String, dynamic>.from(rawSummary);
    final days = (num.tryParse('${summary['days']}') ?? 0).toInt();
    final totalMin = (num.tryParse('${summary['totalMinutes']}') ?? 0).toInt();
    final defaultedTotal = totalMin > 0 ? totalMin : days * 15;
    final perDay = (defaultedTotal / days).round().clamp(1, 1 << 30);
    final today = startOfDay(now ?? DateTime.now());
    final used = {
      ...state.sessions.map((s) => s.date),
      ...imported.map((s) => s.date),
    };
    for (int i = 0; i < days; i++) {
      final d = dateAdd(today, -i);
      final k = todayKey(d);
      if (used.contains(k)) continue;
      imported.add(Session(
        date: k,
        minutes: perDay,
        ts: d.millisecondsSinceEpoch + 8 * 3600 * 1000,
        imported: true,
        summary: true,
      ));
      used.add(k);
    }
  }

  final merged = [...state.sessions, ...imported]
    ..sort((a, b) => a.ts.compareTo(b.ts));

  // Merge any practice-type names brought in by imported sessions.
  final mergedTypes = {...state.types};
  for (final s in imported) {
    if (s.type != null && s.type!.isNotEmpty) mergedTypes.add(s.type!);
  }

  return state.copyWith(
    sessions: merged,
    types: mergedTypes.toList()..sort(),
  );
}
