import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class PendingSession {
  final int duration; // minutes
  final int bell; // interval minutes; 0 = off
  final String? type;

  const PendingSession({
    required this.duration,
    this.bell = 0,
    this.type,
  });
}

final pendingSessionProvider = StateProvider<PendingSession?>((_) => null);
