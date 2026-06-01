#!/usr/bin/env python3
"""Synthesize the meditation bells.

Pure stdlib (no numpy). Produces mono, 44.1 kHz, 16-bit PCM WAVs that emulate
a real struck bell / singing bowl rather than a plain sine:

  * inharmonic partials      -> the metallic, "alive" timbre
  * a short strike transient -> the mallet/clapper attack
  * detuned partial pairs    -> the slow shimmer/warble of real metal
  * per-partial decay        -> bright overtones fade first, the
                                fundamental rings on for the full tail

Both bells share one synthesis so they sound like the same instrument:

  bell.wav     -> short interval bell rung during a sit
  bell_end.wav -> long closing bell rung once when the sit ends

The interval bell is simply the same strike with a shorter tail and quicker
fade, so it is recognisably the same bell, just briefer.

Run from the repo root:  python3 tool/generate_bell.py
"""

import math
import os
import random
import struct
import wave

SAMPLE_RATE = 44100
F0 = 196.0                           # warm fundamental (~G3)
PEAK = 0.86                          # target peak before 16-bit quantization
SEED = 7                             # fixed so the assets are reproducible
SOUNDS_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "sounds")

# Each partial: (frequency multiple of F0, amplitude, decay time constant s,
# beat detune in Hz). Multiples are deliberately inharmonic above the octave
# (2.76, 5.40, ...) the way a real bell's overtones are. The detune creates a
# second, slightly-offset voice per partial so the two slowly beat against each
# other -- the shimmer you hear from struck metal.
PARTIALS = [
    # mult,  amp,   tau,  detune(Hz)
    (0.50,  0.22,  14.0,  0.15),   # sub "hum" tone, very long
    (1.00,  1.00,  11.0,  0.20),   # fundamental
    (2.00,  0.55,   8.0,  0.35),   # octave
    (2.76,  0.48,   6.0,  0.45),   # inharmonic -> bell character
    (3.94,  0.30,   4.2,  0.60),
    (5.40,  0.24,   3.0,  0.80),
    (6.81,  0.16,   2.2,  1.10),
    (8.22,  0.11,   1.6,  1.40),
    (10.6,  0.07,   1.1,  1.90),
    (13.4,  0.04,   0.8,  2.40),   # airy top, dies quickly
]

# Quick attack per partial (ms) so onsets are click-free but still percussive;
# high partials speak fastest, mirroring a real strike.
ATTACK_MS = 4.0

# The two bells. The interval bell uses a shorter tail and a tau scale < 1 so
# its partials decay faster, letting it ease to silence within its 3s window
# instead of being chopped off mid-ring.
#   name, duration(s), fade_out(s), tau_scale
BELLS = [
    ("bell.wav",     7.0,  2.0, 0.55),
    ("bell_end.wav", 30.0, 3.0, 1.00),
]


def render(duration, fade_out, tau_scale):
    n = int(SAMPLE_RATE * duration)
    dt = 1.0 / SAMPLE_RATE
    buf = [0.0] * n

    # --- Sustained inharmonic partials (each as a detuned pair) ---
    for mult, amp, tau, detune in PARTIALS:
        base = F0 * mult
        decay_k = math.exp(-dt / (tau * tau_scale))   # per-sample envelope decay
        attack_samples = max(1, int(SAMPLE_RATE * ATTACK_MS / 1000.0))
        for freq in (base - detune * 0.5, base + detune * 0.5):
            # Complex phasor recurrence avoids a math.sin() call per sample.
            w = 2.0 * math.pi * freq * dt
            rot_re, rot_im = math.cos(w), math.sin(w)
            ph_re, ph_im = 1.0, 0.0
            env = 1.0
            half = amp * 0.5
            for i in range(n):
                atk = i / attack_samples if i < attack_samples else 1.0
                buf[i] += half * env * atk * ph_im
                # advance phasor
                ph_re, ph_im = (
                    ph_re * rot_re - ph_im * rot_im,
                    ph_re * rot_im + ph_im * rot_re,
                )
                env *= decay_k

    # --- Strike transient: a brief filtered-noise burst for the "tong" attack ---
    rnd = random.Random(SEED)
    strike_tau = 0.045
    strike_k = math.exp(-dt / strike_tau)
    lp = 0.0
    env = 0.9
    strike_len = min(n, int(SAMPLE_RATE * 0.25))
    for i in range(strike_len):
        white = rnd.uniform(-1.0, 1.0)
        lp += 0.18 * (white - lp)            # one-pole low-pass -> softer click
        buf[i] += lp * env
        env *= strike_k

    # --- Normalize to target peak ---
    peak = max(abs(s) for s in buf) or 1.0
    g = PEAK / peak
    for i in range(n):
        buf[i] *= g

    # --- Final fade-out (raised-cosine) so the tail eases to silence ---
    fade_n = min(n, int(SAMPLE_RATE * fade_out))
    start = n - fade_n
    for i in range(start, n):
        x = (i - start) / fade_n
        buf[i] *= 0.5 * (1.0 + math.cos(math.pi * x))

    return buf


def write_wav(buf, name):
    frames = bytearray()
    for s in buf:
        v = int(max(-1.0, min(1.0, s)) * 32767.0)
        frames += struct.pack("<h", v)
    path = os.path.normpath(os.path.join(SOUNDS_DIR, name))
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        w.writeframes(bytes(frames))
    return path


if __name__ == "__main__":
    for name, duration, fade_out, tau_scale in BELLS:
        print(f"Rendering {duration:.0f}s {name} @ {SAMPLE_RATE} Hz ...")
        path = write_wav(render(duration, fade_out, tau_scale), name)
        size = os.path.getsize(path)
        print(f"Wrote {path} ({size / 1024:.0f} KB)")
