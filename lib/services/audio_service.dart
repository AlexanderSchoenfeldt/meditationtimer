import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  // Two distinct sounds, kept on separate players so an interval bell and the
  // closing bell never fight over one player's position:
  //   bell.wav     — short (~3s) bell rung at each interval during a sit.
  //   bell_end.wav — long (~30s) realistic bell rung once when the sit ends.
  AudioPlayer? _interval;
  AudioPlayer? _ending;

  Future<AudioPlayer?> _ensure(AudioPlayer? player, String asset) async {
    if (player != null) return player;
    player = AudioPlayer();
    try {
      await player.setAsset(asset);
    } catch (e) {
      // If the asset can't be loaded (e.g. unsupported platform in tests),
      // leave the player constructed but inert — playback below no-ops.
      if (kDebugMode) debugPrint('AudioService: failed to load $asset — $e');
    }
    return player;
  }

  Future<void> _play(AudioPlayer? player) async {
    try {
      await player?.seek(Duration.zero);
      unawaited(player?.play());
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService: playback error — $e');
    }
  }

  // Short interval bell, rung repeatedly during a sit. Safe to call on top of
  // itself — the previous ring is restarted rather than overlapping.
  Future<void> ringBell() async {
    _interval = await _ensure(_interval, 'assets/sounds/bell.wav');
    await _play(_interval);
  }

  // Long, realistic closing bell, rung once when a sit ends.
  Future<void> ringEndingBell() async {
    _ending = await _ensure(_ending, 'assets/sounds/bell_end.wav');
    await _play(_ending);
  }

  Future<void> dispose() async {
    await _interval?.dispose();
    await _ending?.dispose();
    _interval = null;
    _ending = null;
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
