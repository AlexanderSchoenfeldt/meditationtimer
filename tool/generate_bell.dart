// Generates assets/sounds/bell.wav — a synthetic singing-bowl-like tone.
// Run with: dart run tool/generate_bell.dart
//
// Three sine layers (fundamental + octave + subharmonic) with separate
// exponential decays. Short attack so it doesn't click. 16-bit PCM mono
// WAV, ~3 s long.

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const _sampleRate = 44100;
const _duration = 3.0; // seconds
const _fundamental = 528.0; // Hz

void main() {
  final samples = (_duration * _sampleRate).round();
  final pcm = Int16List(samples);

  for (int i = 0; i < samples; i++) {
    final t = i / _sampleRate;

    // exponential decays per partial
    final envFundamental = math.exp(-t * 1.4);
    final envOctave = math.exp(-t * 2.5);
    final envSub = math.exp(-t * 1.0);

    // short linear attack so the start doesn't click
    final attack = (t < 0.01) ? (t / 0.01) : 1.0;

    final fundamental = math.sin(2 * math.pi * _fundamental * t);
    final octave = math.sin(2 * math.pi * _fundamental * 2 * t);
    final sub = math.sin(2 * math.pi * _fundamental * 0.5 * t);

    final mix = (fundamental * 0.55 * envFundamental +
            octave * 0.25 * envOctave +
            sub * 0.20 * envSub) *
        attack *
        0.85;

    pcm[i] = (mix.clamp(-1.0, 1.0) * 32767).round();
  }

  final wav = _wrapWav(pcm, _sampleRate);
  final out = File('assets/sounds/bell.wav');
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync(wav);
  stdout.writeln('Wrote ${out.path} (${wav.length} bytes, '
      '${_duration.toStringAsFixed(1)} s, $_sampleRate Hz mono PCM)');
}

Uint8List _wrapWav(Int16List pcm, int sampleRate) {
  final dataBytes = pcm.buffer.asUint8List();
  final dataSize = dataBytes.length;
  final byteRate = sampleRate * 2;
  final header = ByteData(44)
    ..setUint8(0, 'R'.codeUnitAt(0))
    ..setUint8(1, 'I'.codeUnitAt(0))
    ..setUint8(2, 'F'.codeUnitAt(0))
    ..setUint8(3, 'F'.codeUnitAt(0))
    ..setUint32(4, 36 + dataSize, Endian.little)
    ..setUint8(8, 'W'.codeUnitAt(0))
    ..setUint8(9, 'A'.codeUnitAt(0))
    ..setUint8(10, 'V'.codeUnitAt(0))
    ..setUint8(11, 'E'.codeUnitAt(0))
    ..setUint8(12, 'f'.codeUnitAt(0))
    ..setUint8(13, 'm'.codeUnitAt(0))
    ..setUint8(14, 't'.codeUnitAt(0))
    ..setUint8(15, ' '.codeUnitAt(0))
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, 1, Endian.little) // mono
    ..setUint32(24, sampleRate, Endian.little)
    ..setUint32(28, byteRate, Endian.little)
    ..setUint16(32, 2, Endian.little) // block align
    ..setUint16(34, 16, Endian.little) // bits per sample
    ..setUint8(36, 'd'.codeUnitAt(0))
    ..setUint8(37, 'a'.codeUnitAt(0))
    ..setUint8(38, 't'.codeUnitAt(0))
    ..setUint8(39, 'a'.codeUnitAt(0))
    ..setUint32(40, dataSize, Endian.little);

  final out = Uint8List(44 + dataSize);
  out.setRange(0, 44, header.buffer.asUint8List());
  out.setRange(44, 44 + dataSize, dataBytes);
  return out;
}
