import 'package:flutter/material.dart';

enum AppTheme { light, dark, sepia }

@immutable
class Palette {
  final Color bg;
  final Color bgElev;
  final Color bgSunk;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color line;
  final Color lineSoft;
  final Color gold;
  final Color goldDeep;
  final Color goldSoft;
  final Color goldOn;
  final Brightness brightness;

  const Palette({
    required this.bg,
    required this.bgElev,
    required this.bgSunk,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.lineSoft,
    required this.gold,
    required this.goldDeep,
    required this.goldSoft,
    required this.goldOn,
    required this.brightness,
  });

  // Light — warm off-white, soft ink
  static const light = Palette(
    bg: Color(0xFFFAFAF7),
    bgElev: Color(0xFFFEFEFE),
    bgSunk: Color(0xFFF4F3EF),
    ink: Color(0xFF252320),
    ink2: Color(0xFF6E6963),
    ink3: Color(0xFF9E9A95),
    line: Color(0xFFD9D6D1),
    lineSoft: Color(0xFFE9E7E3),
    gold: Color(0xFFC9A66B),
    goldDeep: Color(0xFF9D7838),
    goldSoft: Color(0xFFF4ECD9),
    goldOn: Color(0xFF3C2E1E),
    brightness: Brightness.light,
  );

  static const dark = Palette(
    bg: Color(0xFF1A1D24),
    bgElev: Color(0xFF222630),
    bgSunk: Color(0xFF161920),
    ink: Color(0xFFEEEFF1),
    ink2: Color(0xFFA8AAB0),
    ink3: Color(0xFF74767D),
    line: Color(0xFF3D414B),
    lineSoft: Color(0xFF2E323C),
    gold: Color(0xFFCFA866),
    goldDeep: Color(0xFFA57E3B),
    goldSoft: Color(0xFF4A3D2A),
    goldOn: Color(0xFF1F1810),
    brightness: Brightness.dark,
  );

  static const sepia = Palette(
    bg: Color(0xFFEEE2CC),
    bgElev: Color(0xFFF4ECD9),
    bgSunk: Color(0xFFE8DBC2),
    ink: Color(0xFF3C2D1E),
    ink2: Color(0xFF76583C),
    ink3: Color(0xFF9C7F63),
    line: Color(0xFFCDB69A),
    lineSoft: Color(0xFFDCC9AE),
    gold: Color(0xFFB07C40),
    goldDeep: Color(0xFF8F5C26),
    goldSoft: Color(0xFFE4C99C),
    goldOn: Color(0xFF2D1F12),
    brightness: Brightness.light,
  );

  static Palette of(AppTheme mode) => switch (mode) {
        AppTheme.light => light,
        AppTheme.dark => dark,
        AppTheme.sepia => sepia,
      };
}

extension PaletteX on BuildContext {
  Palette get palette => Theme.of(this).extension<PaletteExtension>()!.palette;
}

class PaletteExtension extends ThemeExtension<PaletteExtension> {
  final Palette palette;
  const PaletteExtension(this.palette);

  @override
  PaletteExtension copyWith({Palette? palette}) =>
      PaletteExtension(palette ?? this.palette);

  @override
  PaletteExtension lerp(ThemeExtension<PaletteExtension>? other, double t) =>
      this;
}
