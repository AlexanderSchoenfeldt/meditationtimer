import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioPlayer? _player;

  Future<void> _ensure() async {
    if (_player != null) return;
    _player = AudioPlayer();
    try {
      await _player!.setAsset('assets/sounds/bell.wav');
    } catch (e) {
      // If the asset can't be loaded (e.g. unsupported platform in tests),
      // leave the player constructed but inert. ringBell() will no-op.
      if (kDebugMode) debugPrint('AudioService: failed to load bell — $e');
    }
  }

  // Plays the bell once from the start. Safe to call on top of itself —
  // the previous ring is restarted rather than overlapping.
  Future<void> ringBell() async {
    try {
      await _ensure();
      await _player?.seek(Duration.zero);
      unawaited(_player?.play());
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService: ringBell error — $e');
    }
  }

  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
