import 'package:flutter_test/flutter_test.dart';
import 'package:intention/data/dates.dart';
import 'package:intention/data/export.dart';
import 'package:intention/domain/app_state.dart';
import 'package:intention/domain/preset.dart';
import 'package:intention/domain/session.dart';

void main() {
  final today = DateTime(2026, 5, 28);

  AppState makeState() => AppState(
        onboarded: true,
        sessions: [
          Session(
            date: todayKey(dateAdd(today, -1)),
            minutes: 15,
            ts: dateAdd(today, -1).millisecondsSinceEpoch,
            type: 'Breathing',
          ),
          Session(
            date: todayKey(today),
            minutes: 20,
            ts: today.millisecondsSinceEpoch,
          ),
        ],
        presets: const [
          Preset(id: 'p1', name: '15 min', duration: 15, bell: 0),
        ],
        types: const ['Breathing'],
      );

  group('importText', () {
    test('skips leading # comments and blank lines', () {
      const text = '''
# Intention export
# generated at some point
#

{"sessions": [{"date": "2026-01-01", "minutes": 10}]}
''';
      final parsed = importText(text);
      expect(parsed['sessions'], isA<List>());
    });

    test('throws on non-object JSON', () {
      expect(() => importText('[1, 2, 3]'), throwsFormatException);
    });
  });

  group('exportText / importText roundtrip', () {
    test('full backup preserves state', () {
      final s = makeState();
      final text = exportText(s, now: today);
      final parsed = importText(text);
      final restored = applyImport(AppState.empty, parsed);
      expect(restored.onboarded, true);
      expect(restored.sessions.length, 2);
      expect(restored.presets.length, 1);
      expect(restored.types, ['Breathing']);
      expect(restored.sessions.first.type, 'Breathing');
    });
  });

  group('applyImport partial', () {
    test('merges in plain session list', () {
      final base = AppState(
        sessions: [
          Session(
            date: todayKey(dateAdd(today, -10)),
            minutes: 5,
            ts: dateAdd(today, -10).millisecondsSinceEpoch,
          ),
        ],
      );
      final parsed = {
        'sessions': [
          {'date': '2026-05-27', 'minutes': 20, 'type': 'Yoga'},
        ],
      };
      final out = applyImport(base, parsed);
      expect(out.sessions.length, 2);
      expect(out.types, contains('Yoga'));
    });

    test('summary block expands into a continuous streak ending today', () {
      final out = applyImport(
        AppState.empty,
        {
          'summary': {'days': 30, 'totalMinutes': 600},
        },
        now: today,
      );
      expect(out.sessions.length, 30);
      expect(out.sessions.last.date, todayKey(today));
      expect(out.sessions.last.minutes, 20); // 600 / 30
    });

    test('summary skips dates that already have a session', () {
      final base = AppState(
        sessions: [
          Session(
            date: todayKey(today),
            minutes: 99,
            ts: today.millisecondsSinceEpoch,
          ),
        ],
      );
      final out = applyImport(
        base,
        {
          'summary': {'days': 5, 'totalMinutes': 100},
        },
        now: today,
      );
      // 5 days requested but today already has a sit → 4 new + 1 existing = 5 total
      expect(out.sessions.length, 5);
      final todays =
          out.sessions.where((s) => s.date == todayKey(today)).toList();
      expect(todays.length, 1);
      expect(todays.first.minutes, 99); // original untouched
    });

    test('empty parsed throws', () {
      expect(() => applyImport(AppState.empty, {}), throwsA(isA<ImportException>()));
    });

    test('summary without totalMinutes defaults to 15min/day', () {
      final out = applyImport(
        AppState.empty,
        {'summary': {'days': 7}},
        now: today,
      );
      expect(out.sessions.length, 7);
      expect(out.sessions.last.minutes, 15);
    });
  });
}
