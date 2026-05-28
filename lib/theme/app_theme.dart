import 'package:flutter/material.dart';
import 'palette.dart';

const String _sans = 'SourceSansPro';
const String _serif = 'serif';

const _serifNumeral = TextStyle(
  fontFamily: _serif,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.5,
  fontFeatures: [FontFeature.tabularFigures(), FontFeature.liningFigures()],
);

ThemeData buildTheme(Palette p) {
  final base = ThemeData(
    brightness: p.brightness,
    useMaterial3: false,
    scaffoldBackgroundColor: p.bg,
    canvasColor: p.bg,
    fontFamily: _sans,
    colorScheme: ColorScheme(
      brightness: p.brightness,
      primary: p.gold,
      onPrimary: p.goldOn,
      secondary: p.goldDeep,
      onSecondary: p.goldOn,
      surface: p.bgElev,
      onSurface: p.ink,
      error: const Color(0xFFB0432A),
      onError: Colors.white,
    ),
    textTheme: TextTheme(
      displayLarge: _serifNumeral.copyWith(fontSize: 132, color: p.ink, fontWeight: FontWeight.w300),
      displayMedium: _serifNumeral.copyWith(fontSize: 88, color: p.ink),
      displaySmall: _serifNumeral.copyWith(fontSize: 56, color: p.ink, fontWeight: FontWeight.w300),
      headlineLarge: _serifNumeral.copyWith(fontSize: 40, color: p.ink, fontWeight: FontWeight.w300),
      headlineMedium: _serifNumeral.copyWith(fontSize: 32, color: p.ink),
      headlineSmall: _serifNumeral.copyWith(fontSize: 22, color: p.ink),
      titleLarge: TextStyle(fontFamily: _sans, fontSize: 16, fontWeight: FontWeight.w500, color: p.ink),
      titleMedium: TextStyle(fontFamily: _sans, fontSize: 15, fontWeight: FontWeight.w500, color: p.ink),
      bodyLarge: TextStyle(fontFamily: _sans, fontSize: 16, color: p.ink, height: 1.5),
      bodyMedium: TextStyle(fontFamily: _sans, fontSize: 14, color: p.ink2, height: 1.45),
      bodySmall: TextStyle(fontFamily: _sans, fontSize: 13, color: p.ink2),
      labelLarge: TextStyle(fontFamily: _sans, fontSize: 15, fontWeight: FontWeight.w500, color: p.ink),
      labelMedium: TextStyle(fontFamily: _sans, fontSize: 12, color: p.ink3, letterSpacing: 2.5),
      labelSmall: TextStyle(fontFamily: _sans, fontSize: 11, color: p.ink3, letterSpacing: 1.8),
    ),
    dividerColor: p.lineSoft,
    iconTheme: IconThemeData(color: p.ink2, size: 22),
    extensions: [PaletteExtension(p)],
  );
  return base;
}

// Wordmark used as logo / home title — letter-spaced serif caps
class Wordmark extends StatelessWidget {
  final String text;
  const Wordmark({super.key, this.text = 'INTENTION'});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: _serif,
        fontSize: 14,
        letterSpacing: 4.5,
        color: context.palette.ink3,
      ),
    );
  }
}
