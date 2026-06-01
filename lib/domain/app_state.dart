import 'package:flutter/foundation.dart';

import '../theme/palette.dart';
import 'preset.dart';
import 'session.dart';

@immutable
class LastUsed {
  final int duration;
  final int bell;
  final String? type;

  const LastUsed({this.duration = 15, this.bell = 0, this.type});

  Map<String, dynamic> toJson() => {
        'duration': duration,
        'bell': bell,
        if (type != null) 'type': type,
      };

  factory LastUsed.fromJson(Map<String, dynamic> j) => LastUsed(
        duration: (j['duration'] as num? ?? 15).toInt(),
        bell: (j['bell'] as num? ?? 0).toInt(),
        type: j['type'] as String?,
      );
}

@immutable
class Settings {
  final AppTheme theme;
  final bool useSerif;
  final bool sound; // ring the bell aloud; off = a silent sit
  final bool vibrate; // pulse the device at each bell, audible or not

  const Settings({
    this.theme = AppTheme.light,
    this.useSerif = true,
    this.sound = true,
    this.vibrate = false,
  });

  Settings copyWith({
    AppTheme? theme,
    bool? useSerif,
    bool? sound,
    bool? vibrate,
  }) =>
      Settings(
        theme: theme ?? this.theme,
        useSerif: useSerif ?? this.useSerif,
        sound: sound ?? this.sound,
        vibrate: vibrate ?? this.vibrate,
      );

  Map<String, dynamic> toJson() => {
        'theme': theme.name,
        'useSerif': useSerif,
        'sound': sound,
        'vibrate': vibrate,
      };

  factory Settings.fromJson(Map<String, dynamic> j) => Settings(
        theme: AppTheme.values.firstWhere(
          (t) => t.name == j['theme'],
          orElse: () => AppTheme.light,
        ),
        useSerif: j['useSerif'] as bool? ?? true,
        sound: j['sound'] as bool? ?? true,
        vibrate: j['vibrate'] as bool? ?? false,
      );
}

@immutable
class AppState {
  final bool onboarded;
  final List<Session> sessions;
  final List<Preset> presets;
  final List<String> types; // user-defined practice type names
  final LastUsed lastUsed;
  final Settings settings;
  final String? streakDismissedFor; // YYYY-MM-DD

  const AppState({
    this.onboarded = false,
    this.sessions = const [],
    this.presets = const [],
    this.types = const [],
    this.lastUsed = const LastUsed(),
    this.settings = const Settings(),
    this.streakDismissedFor,
  });

  AppState copyWith({
    bool? onboarded,
    List<Session>? sessions,
    List<Preset>? presets,
    List<String>? types,
    LastUsed? lastUsed,
    Settings? settings,
    String? streakDismissedFor,
    bool clearStreakDismissed = false,
  }) =>
      AppState(
        onboarded: onboarded ?? this.onboarded,
        sessions: sessions ?? this.sessions,
        presets: presets ?? this.presets,
        types: types ?? this.types,
        lastUsed: lastUsed ?? this.lastUsed,
        settings: settings ?? this.settings,
        streakDismissedFor: clearStreakDismissed
            ? null
            : (streakDismissedFor ?? this.streakDismissedFor),
      );

  Map<String, dynamic> toJson() => {
        'onboarded': onboarded,
        'sessions': sessions.map((s) => s.toJson()).toList(),
        'presets': presets.map((p) => p.toJson()).toList(),
        'types': types,
        'lastUsed': lastUsed.toJson(),
        'settings': settings.toJson(),
        if (streakDismissedFor != null)
          'streakDismissedFor': streakDismissedFor,
      };

  factory AppState.fromJson(Map<String, dynamic> j) => AppState(
        onboarded: j['onboarded'] as bool? ?? false,
        sessions: (j['sessions'] as List? ?? const [])
            .map((e) => Session.fromJson(e as Map<String, dynamic>))
            .toList(),
        presets: (j['presets'] as List? ?? const [])
            .map((e) => Preset.fromJson(e as Map<String, dynamic>))
            .toList(),
        types: (j['types'] as List? ?? const [])
            .map((e) => e as String)
            .toList(),
        lastUsed: j['lastUsed'] is Map
            ? LastUsed.fromJson(j['lastUsed'] as Map<String, dynamic>)
            : const LastUsed(),
        settings: j['settings'] is Map
            ? Settings.fromJson(j['settings'] as Map<String, dynamic>)
            : const Settings(),
        streakDismissedFor: j['streakDismissedFor'] as String?,
      );

  static const empty = AppState();
}
