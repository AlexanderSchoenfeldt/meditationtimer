import 'package:flutter_test/flutter_test.dart';

import 'package:intention/domain/app_state.dart';
import 'package:intention/theme/palette.dart';

/// Guards the sound/vibration preferences: their defaults (audible bell, no
/// vibration) and that they survive a JSON round-trip, including older saved
/// files that predate the fields.
void main() {
  test('defaults: bell sounds, vibration off', () {
    const s = Settings();
    expect(s.sound, isTrue);
    expect(s.vibrate, isFalse);
  });

  test('sound + vibrate survive a JSON round-trip', () {
    const s = Settings(theme: AppTheme.dark, sound: false, vibrate: true);
    final back = Settings.fromJson(s.toJson());
    expect(back.sound, isFalse);
    expect(back.vibrate, isTrue);
    expect(back.theme, AppTheme.dark);
  });

  test('older files without the fields fall back to the defaults', () {
    // A settings blob saved before sound/vibration existed.
    final back = Settings.fromJson({'theme': 'sepia', 'useSerif': false});
    expect(back.sound, isTrue);
    expect(back.vibrate, isFalse);
    expect(back.theme, AppTheme.sepia);
    expect(back.useSerif, isFalse);
  });
}
