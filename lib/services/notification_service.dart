import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const _channelId = 'intention.timer';
  static const _notificationId = 1;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensure() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      // Android 13+: ask for POST_NOTIFICATIONS. Older Androids ignore it.
      await android?.requestNotificationsPermission();
      _initialized = true;
    } catch (e) {
      if (kDebugMode) debugPrint('Notification init failed: $e');
    }
  }

  // Schedule a single "sit complete" notification. The TZDateTime is built
  // from the desired UNIX moment so we don't need a separate local-zone
  // lookup — Android renders it in the user's local time.
  Future<void> scheduleSitComplete(DateTime endsAt) async {
    await _ensure();
    if (!_initialized) return;
    try {
      await _plugin.cancel(_notificationId);
      final ms = endsAt.millisecondsSinceEpoch;
      if (ms <= DateTime.now().millisecondsSinceEpoch) return;
      final scheduled = tz.TZDateTime.fromMillisecondsSinceEpoch(tz.UTC, ms);
      await _plugin.zonedSchedule(
        _notificationId,
        'Sit complete',
        'Your practice is done.',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Sit completion',
            channelDescription:
                'A single chime when your meditation timer finishes.',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('scheduleSitComplete failed: $e');
    }
  }

  Future<void> cancel() async {
    try {
      await _plugin.cancel(_notificationId);
    } catch (_) {}
  }
}

final notificationServiceProvider =
    Provider<NotificationService>((_) => NotificationService());
