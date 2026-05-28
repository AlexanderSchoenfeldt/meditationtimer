import 'package:flutter/foundation.dart';

@immutable
class Preset {
  final String id;
  final String name;
  final int duration; // minutes
  final int bell; // interval minutes, 0 = off
  final String? type;

  const Preset({
    required this.id,
    required this.name,
    required this.duration,
    required this.bell,
    this.type,
  });

  Preset copyWith({String? name, int? duration, int? bell, String? type}) =>
      Preset(
        id: id,
        name: name ?? this.name,
        duration: duration ?? this.duration,
        bell: bell ?? this.bell,
        type: type ?? this.type,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'duration': duration,
        'bell': bell,
        if (type != null) 'type': type,
      };

  factory Preset.fromJson(Map<String, dynamic> j) => Preset(
        id: j['id'] as String,
        name: j['name'] as String,
        duration: (j['duration'] as num).toInt(),
        bell: (j['bell'] as num? ?? 0).toInt(),
        type: j['type'] as String?,
      );

  bool matches({required int duration, required int bell, String? type}) =>
      this.duration == duration && this.bell == bell && this.type == type;
}
