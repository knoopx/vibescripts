import sys
import os
import subprocess
import tempfile
import numpy as np
import scipy.signal
import soundfile as sf

if len(sys.argv) != 2:
    print("Usage: drum-practice <input_mp3>")
    sys.exit(1)

input_mp3 = os.path.abspath(sys.argv[1])
name = os.path.splitext(os.path.basename(input_mp3))[0]
outdir = f"/tmp/htdemucs/{name}"

# 1. Split stems with Demucs
if not os.path.isdir(outdir):
    print("Splitting stems with Demucs...")
    subprocess.run(["demucs", "--mp3", "-o", "/tmp", input_mp3], check=True)
else:
    print("Stems already exist, skipping Demucs.")

drums_mp3 = os.path.join(outdir, "drums.mp3")
if not os.path.isfile(drums_mp3):
    print(f"ERROR: Drum stem {drums_mp3} does not exist!")
    sys.exit(2)

# 2. Analyze drum stem and extract top frequencies (FFT)
print("Analyzing drum stem to find most prominent frequencies...")
with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as drum_wav:
    drum_wav_path = drum_wav.name
subprocess.run(
    [
        "ffmpeg",
        "-hide_banner",
        "-y",
        "-i",
        drums_mp3,
        "-ac",
        "1",
        "-ar",
        "44100",
        drum_wav_path,
    ],
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL,
)

data, samplerate = sf.read(drum_wav_path)
if data.ndim > 1:
    data = np.mean(data, axis=1)
segment = data[: samplerate * 10] if len(data) > samplerate * 10 else data
windowed = segment * np.hanning(len(segment))
fft = np.abs(np.fft.rfft(windowed))
freqs = np.fft.rfftfreq(len(windowed), 1 / samplerate)
valid = freqs > 20
fft = fft[valid]
freqs = freqs[valid]
peaks, _ = scipy.signal.find_peaks(fft, height=np.max(fft) * 0.1)
peak_freqs = freqs[peaks]
peak_amps = fft[peaks]
if len(peak_freqs) == 0:
    freq_peaks = [60, 120, 240, 480]
else:
    order = np.argsort(peak_amps)[::-1]
    freq_peaks = [int(round(f)) for f in peak_freqs[order][:4]]
print(f"Top drum frequencies detected: {freq_peaks}")
os.remove(drum_wav_path)

# 3. EQ non-drum stems
for stem in ["bass", "vocals", "other"]:
    infile = os.path.join(outdir, f"{stem}.mp3")
    outfile = os.path.join(outdir, f"{stem}_eq.mp3")
    if not os.path.isfile(outfile):
        eq_args = "".join([f",equalizer=f={f}:t=h:width=100:g=-6" for f in freq_peaks])
        eq_args = eq_args.lstrip(",")
        subprocess.run(
            ["ffmpeg", "-y", "-i", infile, "-af", eq_args, outfile], check=True
        )


# 4. Mix non-drum stems, boost drums, lower rest (for drum practice)
with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as tmpmix:
    tmpmix_path = tmpmix.name
ffmpeg_cmd = [
    "ffmpeg",
    "-hide_banner",
    "-loglevel",
    "error",
    "-i",
    os.path.join(outdir, "bass_eq.mp3"),
    "-i",
    os.path.join(outdir, "vocals_eq.mp3"),
    "-i",
    os.path.join(outdir, "other_eq.mp3"),
    "-i",
    drums_mp3,
    "-filter_complex",
    "[0][1][2]amix=inputs=3:normalize=0[rest]; "
    "[rest]volume=-3dB[restq]; "
    "[3]volume=3dB[drumq]; "
    "[restq][drumq]amix=inputs=2:normalize=0,volume=2dB",
    "-y",
    tmpmix_path,
]
subprocess.run(ffmpeg_cmd, check=True)

# 5. Open with default player
print("Opening result with default player...")
subprocess.Popen(["xdg-open", tmpmix_path])
