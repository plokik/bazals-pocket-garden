"""One original, review-only ambient/downtempo proposal. Never modifies game audio.

Dependencies: numpy, scipy, soundfile, imageio-ffmpeg, pyloudnorm.
All instruments are synthesized here; no recordings, samples or online services.
The loop uses circular note tails and circular convolution, without an end fade.
"""
from pathlib import Path
import hashlib
import json
import math
import subprocess

import imageio_ffmpeg
import numpy as np
import pyloudnorm as pyln
import soundfile as sf
from scipy.signal import butter, sosfilt, resample_poly

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "docs/audio-proposals/20261028-modern-calm"
SR = 48000
BPM = 72
BEAT = 60 / BPM
BAR = 4 * BEAT
N = round(32 * BAR * SR)
RNG = np.random.default_rng(28102026)
TAU = 2 * np.pi
EVENTS = []


def freq(midi):
    return 440 * 2 ** ((midi - 69) / 12)


def lowpass(x, hz, order=2):
    return sosfilt(butter(order, hz, fs=SR, output="sos"), x).astype(np.float32)


def tail_fade(x, seconds=.12):
    length = min(len(x), round(seconds * SR))
    x[-length:] *= np.linspace(1, 0, length, dtype=np.float32) ** 2
    return x.astype(np.float32)


def piano(midi, hold, velocity=.7):
    """Soft electric keys: warm tine fundamental, short FM attack, damped tail."""
    t = np.arange(round((hold + 1.9) * SR), dtype=np.float32) / SR
    f = freq(midi)
    phase = TAU * f * t
    decay = 2.9 * (220 / f) ** .18
    tone = np.sin(phase + (.11 + velocity * .14) * np.exp(-t * 7) * np.sin(phase * 3.001))
    tone += .22 * np.sin(phase * 2.001) * np.exp(-t * 1.8)
    tone += .065 * np.sin(phase * 3.999) * np.exp(-t * 4.6)
    tone += .025 * np.sin(phase * 7.012) * np.exp(-t * 16)
    env = (1 - np.exp(-t * 160)) * np.exp(-t / decay)
    env *= np.exp(-np.maximum(t - hold, 0) * 2.4)
    return tail_fade(lowpass(tone * env * velocity, 4300))


def pad(midi, hold, phase_seed):
    t = np.arange(round((hold + 3.3) * SR), dtype=np.float32) / SR
    f = freq(midi)
    env = (1 - np.exp(-t / 1.3)) * np.exp(-np.maximum(t - hold, 0) / .83)
    tone = np.zeros((len(t), 2), np.float32)
    for side in range(2):
        for ratio, level, shift in [(1, .68, -2.2), (1, .32, 2.7), (2, .095, 1.2), (3, .024, -1.0)]:
            cents = shift * (1 if side else -.8)
            phase = TAU * f * ratio * 2 ** (cents / 1200) * t + phase_seed + side * .18
            tone[:, side] += level * np.sin(phase + .055 * np.sin(TAU * .16 * t))
        tone[:, side] = lowpass(tone[:, side], 1800) * env
    return np.stack([tail_fade(tone[:, side], .4) for side in range(2)], axis=1)


def bass(midi, hold):
    t = np.arange(round((hold + .6) * SR), dtype=np.float32) / SR
    phase = TAU * freq(midi) * t
    x = np.sin(phase) + .19 * np.sin(2 * phase) + .045 * np.sin(3 * phase)
    env = (1 - np.exp(-t * 32)) * np.exp(-t * .38) * np.exp(-np.maximum(t - hold, 0) * 8)
    return tail_fade(x * env)


def percussion(kind):
    if kind == "kick":
        t = np.arange(round(.42 * SR), dtype=np.float32) / SR
        phase = TAU * (48 * t + 33 * .022 * (1 - np.exp(-t / .022)))
        x = np.sin(phase) * (1 - np.exp(-t * 700)) * np.exp(-t * 15)
    elif kind == "rim":
        t = np.arange(round(.12 * SR), dtype=np.float32) / SR
        x = sum(g * np.sin(TAU * f * t) * np.exp(-t * decay)
                for f, g, decay in [(510, .6, 66), (860, .19, 80), (1260, .06, 100)])
        x *= 1 - np.exp(-t * 1100)
        x += lowpass(RNG.normal(0, .12, len(t)), 2800) * np.exp(-t * 90)
    else:
        t = np.arange(round(.105 * SR), dtype=np.float32) / SR
        raw = RNG.normal(0, .4, len(t))
        x = sosfilt(butter(2, [2300, 6500], btype="bandpass", fs=SR, output="sos"), raw)
        x *= (1 - np.exp(-t * 600)) * np.exp(-t * 54)
    return tail_fade(x, .04)


def put(bus, x, when, gain=1, pan=0, tag="", midi=None):
    offset = round(when * SR) % N
    if x.ndim == 1:
        x = x[:, None] * np.array([math.sqrt((1 - pan) / 2), math.sqrt((1 + pan) / 2)])
    x = np.asarray(x * gain, dtype=np.float32)
    first = min(len(x), N - offset)
    bus[offset:offset + first] += x[:first]
    if first < len(x):
        bus[:len(x) - first] += x[first:]
    if tag:
        EVENTS.append(dict(instrument=tag, midi=midi, seconds=round(when % (N / SR), 4)))


def circular_reverb(bus, seconds=3.4):
    """Diffuse stereo room; fixed random impulse and circular FFT convolution."""
    length = round(seconds * SR)
    t = np.arange(length, dtype=np.float32) / SR
    ir = np.zeros((length, 2), np.float32)
    for side in range(2):
        noise = lowpass(RNG.normal(0, 1, length), 3700)
        env = np.maximum(0, 1 - np.exp(-(t - .035) * 22)) * np.exp(-t * 2.3)
        ir[:, side] = noise * env
        ir[:, side] /= np.sqrt(np.sum(ir[:, side] ** 2))
    for delay, strength in [(.047, .15), (.079, .10), (.131, .07)]:
        ir[round(delay * SR), 0] += strength
        ir[round((delay + .009) * SR), 1] += strength
    wet = np.zeros_like(bus)
    for side in range(2):
        source = .78 * bus[:, side] + .22 * bus[:, 1 - side]
        wet[:, side] = np.fft.irfft(np.fft.rfft(source) * np.fft.rfft(ir[:, side], n=N), n=N)
    return wet


def score():
    keys, air, low, rhythm = [np.zeros((N, 2), np.float32) for _ in range(4)]
    # Four related two-bar colors, voiced smoothly and kept clear of the bass.
    harmony = [
        (38, [57, 61, 64, 66]),  # Dmaj9
        (35, [57, 61, 62, 66]),  # Bm9
        (31, [54, 57, 59, 62]),  # Gmaj9
        (33, [55, 59, 62, 66]),  # A13sus
    ]
    melody = {
        1: [(1.5, 73, .8), (3.0, 69, 1.5)],
        3: [(1.0, 66, 1.4)],
        5: [(1.5, 69, .65), (2.5, 71, 1.1)],
        7: [(1.0, 69, 1.8)],
        8: [(2.5, 73, 1.0)],
        9: [(1.0, 76, 1.2), (3.0, 73, .8)],
        11: [(0.5, 74, 1.25), (2.5, 73, 1.1)],
        13: [(1.0, 71, 1.4), (3.0, 69, .8)],
        15: [(1.0, 66, 2.2)],
        17: [(1.5, 73, 1.0), (3.0, 69, 1.4)],
        19: [(1.0, 66, 1.5)],
        21: [(1.5, 69, .75), (3.0, 71, 1.1)],
        23: [(.5, 69, 1.2), (2.5, 66, 1.3)],
        25: [(1.0, 73, 1.8)],
        27: [(1.5, 69, 1.8)],
        29: [(1.0, 71, 1.0), (2.5, 69, 1.3)],
    }
    for bar in range(32):
        start = bar * BAR
        root, chord = harmony[(bar // 2) % 4]
        section = bar // 8
        if bar % 2 == 0:
            for i, midi in enumerate(chord):
                put(keys, piano(midi, 3.4, .62 + RNG.uniform(-.04, .04)),
                    start + .025 + i * .022, .105, (i - 1.5) * .17, "electric_piano", midi)
            for midi in chord[:3]:
                put(air, pad(midi, 2 * BAR - .3, RNG.uniform(0, TAU)),
                    start - .35, .019, tag="warm_pad", midi=midi)
        else:
            # One light, offbeat chord answer, with space between phrases.
            for i, midi in enumerate(chord[1:]):
                put(keys, piano(midi, 1.8, .49), start + 1.5 * BEAT + i * .026,
                    .060 if section != 3 else .043, (i - 1) * .18, "piano_answer", midi)
        put(low, bass(root, BEAT * 2.3), start + .035, .105, tag="round_bass", midi=root)
        if bar % 2 == 1 and section != 3:
            put(low, bass(root + 12, BEAT * .75), start + BEAT * 3.3, .042,
                tag="bass_answer", midi=root + 12)
        for beat, midi, length in melody.get(bar, []):
            put(keys, piano(midi, BEAT * length, .55),
                start + beat * BEAT + RNG.uniform(-.016, .016),
                .090, .12, "melody", midi)
        # Quiet half-time groove. Opening and last phrase breathe without it.
        if 4 <= bar < 28:
            density = .72 if bar < 8 or bar >= 24 else 1.0
            put(rhythm, percussion("kick"), start + .012, .083 * density, tag="soft_kick")
            if bar % 2 == 1:
                put(rhythm, percussion("kick"), start + 3.25 * BEAT, .043 * density, tag="soft_kick")
            put(rhythm, percussion("rim"), start + 2.035 * BEAT, .038 * density, .17, "soft_rim")
            for beat in [.55, 1.55, 2.55, 3.55]:
                put(rhythm, percussion("shaker"), start + beat * BEAT + RNG.uniform(-.012, .012),
                    .021 * density * RNG.uniform(.75, 1.0), -.3 if beat < 2 else .28, "brush")
    print("Score rendered; adding the stereo room.", flush=True)
    reverb_source = keys + air * .45 + rhythm * .11
    wet = circular_reverb(reverb_source)
    # Reverb gain is measured against its source rather than random IR energy.
    wet *= .27 * np.sqrt(np.mean(reverb_source ** 2)) / max(1e-9, np.sqrt(np.mean(wet ** 2)))
    mix = keys + air + low + rhythm + wet
    # Circular high-pass removes subsonic energy without a startup transient.
    bins = np.fft.rfftfreq(N, 1 / SR)
    hp = (bins / np.maximum(bins, 25)) ** 2
    for side in range(2):
        mix[:, side] = np.fft.irfft(np.fft.rfft(mix[:, side]) * hp, n=N)
    mix -= mix.mean(axis=0)
    meter = pyln.Meter(SR)
    measured = meter.integrated_loudness(mix)
    mix *= 10 ** ((-23.0 - measured) / 20)
    assert np.max(np.abs(mix)) < .85, "Unexpected mix peak; rebalance before exporting."
    return mix.astype(np.float32)


def encode(x, path, codec_args):
    subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), "-v", "error", "-y",
                    "-f", "f32le", "-ar", str(SR), "-ac", "2", "-i", "pipe:0",
                    *codec_args, str(path)], input=x.tobytes(), check=True)


def inspect(x, rate):
    rms = float(np.sqrt(np.mean(x ** 2)))
    correlation = float(np.corrcoef(x[:, 0], x[:, 1])[0, 1])
    true_peak = float(np.max(np.abs(resample_poly(x, 4, 1, axis=0))))
    return dict(seconds=round(len(x) / rate, 6), sample_rate=rate, channels=x.shape[1],
                sample_peak_dbfs=round(20 * math.log10(float(np.max(np.abs(x)))), 3),
                true_peak_dbtp=round(20 * math.log10(true_peak), 3),
                integrated_lufs=round(float(pyln.Meter(rate).integrated_loudness(x)), 3),
                rms_dbfs=round(20 * math.log10(rms), 3),
                dc_offset=float(np.max(np.abs(x.mean(axis=0)))),
                stereo_correlation=round(correlation, 5),
                loop_boundary_jump=float(np.max(np.abs(x[0] - x[-1]))),
                finite=bool(np.isfinite(x).all()))


def main():
    source_paths = sorted((ROOT / "assets/audio/garden_v1").rglob("*"))
    original = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                for p in source_paths if p.is_file() and not p.name.endswith(".import")}
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / ".gdignore").write_text("", encoding="utf-8")
    loop = score()
    sf.write(OUT / "klidna-zahrada-loop.flac", loop, SR, subtype="PCM_24")
    encode(loop, OUT / "klidna-zahrada-loop.ogg", ["-c:a", "libvorbis", "-q:a", "6"])
    preview = loop.copy() * 10 ** (4 / 20)
    preview[:SR] *= np.linspace(0, 1, SR, dtype=np.float32)[:, None] ** .7
    preview[-SR * 4:] *= np.linspace(1, 0, SR * 4, dtype=np.float32)[:, None] ** 1.4
    encode(preview, OUT / "klidna-zahrada-poslech.mp3", ["-c:a", "libmp3lame", "-b:a", "256k"])
    # Decode both delivery formats, then validate the bytes the user receives.
    decoded, rate = sf.read(OUT / "klidna-zahrada-loop.ogg", dtype="float32", always_2d=True)
    loop_metrics = inspect(decoded, rate)
    assert rate == SR and decoded.shape == loop.shape
    assert loop_metrics["finite"] and loop_metrics["true_peak_dbtp"] < -1
    assert abs(loop_metrics["integrated_lufs"] + 23) < .2
    assert loop_metrics["dc_offset"] < .001 and loop_metrics["loop_boundary_jump"] < .005
    assert loop_metrics["stereo_correlation"] > .2
    decoded_preview, preview_rate = sf.read(OUT / "klidna-zahrada-poslech.mp3", dtype="float32", always_2d=True)
    preview_metrics = inspect(decoded_preview, preview_rate)
    assert preview_rate == SR and decoded_preview.shape == loop.shape
    assert preview_metrics["finite"] and preview_metrics["true_peak_dbtp"] < -1
    # Confirm that all current game audio remains byte-for-byte unchanged.
    assert all(hashlib.sha256((ROOT / p).read_bytes()).hexdigest() == digest for p, digest in original.items())
    files = {p.name: dict(bytes=p.stat().st_size, sha256=hashlib.sha256(p.read_bytes()).hexdigest())
             for p in OUT.iterdir() if p.suffix in [".mp3", ".ogg", ".flac"]}
    report = dict(status="REVIEW_ONLY", user_approval="PENDING", integrated_into_game=False,
                  title="Klidná zahrada", style="Warm ambient / soft downtempo, instrumental",
                  bpm=BPM, bars=32, key="D major / B minor", seed=28102026,
                  provenance="Original offline score and synthesized instruments. No sampled recordings or generated-service assets.",
                  loop=loop_metrics, listening_preview=preview_metrics,
                  current_game_audio_unchanged=True, checked_original_audio_files=len(original),
                  automated_audio_checks="PASSED", subjective_listening_approval="PENDING", files=files)
    (OUT / "verification.json").write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    (OUT / "score-events.json").write_text(json.dumps(EVENTS, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
