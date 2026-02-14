# OS.AudioControl Module Documentation

## Overview

The **OS.AudioControl** module provides comprehensive audio device management, playback control, volume manipulation, and audio stream processing capabilities for the Levython programming language. It supports Windows (WASAPI/WinMM), macOS (CoreAudio), and Linux (ALSA) with a unified cross-platform API.

## Features

- 🎵 **Device Enumeration** - List and query audio devices
- 🔊 **Volume Control** - Get/set volume levels and mute status
- 🎶 **Audio Playback** - Play sound files and generate tones
- 📡 **Stream Management** - Create and manage audio streams
- 🎙️ **Recording** - Capture audio from input devices
- 🎚️ **Audio Mixing** - Mix multiple audio signals with weights
- ✨ **Effects Processing** - Apply audio effects (amplify, fade, filters)
- ⚙️ **Device Configuration** - Control sample rates and formats

## Platform Support

| Platform | Audio API | Features |
|----------|-----------|----------|
| **Windows** | WASAPI, WinMM, Multimedia APIs | Full support for device enumeration, volume control, playback, recording |
| **macOS** | CoreAudio, AudioUnit, AudioToolbox | Native CoreAudio integration with low latency |
| **Linux** | ALSA (Advanced Linux Sound Architecture) | Complete ALSA support with mixer control |

## API Reference

### Device Management

#### `OS.AudioControl.list_devices(type="all")`
List all available audio devices.

**Parameters:**
- `type` (string, optional): Filter by device type
  - `"all"` - All devices (default)
  - `"playback"` - Output devices only
  - `"recording"` - Input devices only

**Returns:** List of device information maps

**Example:**
```levy
devices <- OS.AudioControl.list_devices("playback")
for device in devices {
    say(device["name"] + " - " + device["id"])
}
```

#### `OS.AudioControl.get_default_device(type="playback")`
Get the default audio device ID.

**Parameters:**
- `type` (string, optional): Device type
  - `"playback"` - Default output device (default)
  - `"recording"` - Default input device

**Returns:** String - Device ID

**Example:**
```levy
default_device <- OS.AudioControl.get_default_device("playback")
say("Default device: " + default_device)
```

#### `OS.AudioControl.set_default_device(device_id)`
Set the system default audio device.

**Parameters:**
- `device_id` (string): Device identifier

**Returns:** Boolean - Success status

**Example:**
```levy
success <- OS.AudioControl.set_default_device("device_123")
if success {
    say("Default device changed successfully")
}
```

#### `OS.AudioControl.get_device_info(device_id)`
Get detailed information about a specific device.

**Parameters:**
- `device_id` (string): Device identifier

**Returns:** Map with device properties:
- `id` - Device identifier
- `name` - Device name
- `type` - Device type (playback/recording)
- `is_default` - Whether this is the default device
- `channels` - Number of audio channels
- `sample_rate` - Sample rate in Hz
- `format` - Audio format (pcm_s16, pcm_f32, etc.)
- `buffer_size` - Buffer size in frames
- `latency` - Latency in milliseconds

**Example:**
```levy
info <- OS.AudioControl.get_device_info("device_123")
say("Device: " + info["name"])
say("Channels: " + str(info["channels"]))
say("Sample Rate: " + str(info["sample_rate"]) + " Hz")
```

### Volume Control

#### `OS.AudioControl.get_volume(device_id=default)`
Get the current volume level.

**Parameters:**
- `device_id` (string, optional): Device ID (defaults to default playback device)

**Returns:** Float - Volume level (0.0 = silent, 1.0 = maximum)

**Example:**
```levy
volume <- OS.AudioControl.get_volume()
say("Current volume: " + str(volume * 100) + "%")
```

#### `OS.AudioControl.set_volume(volume, device_id=default)`
Set the volume level.

**Parameters:**
- `volume` (float): Volume level (0.0 to 1.0)
- `device_id` (string, optional): Device ID (defaults to default playback device)

**Returns:** Boolean - Success status

**Example:**
```levy
// Set volume to 75%
OS.AudioControl.set_volume(0.75)

// Set volume on specific device
OS.AudioControl.set_volume(0.5, "device_123")
```

#### `OS.AudioControl.get_mute(device_id=default)`
Get the mute status.

**Parameters:**
- `device_id` (string, optional): Device ID

**Returns:** Boolean - True if muted, false otherwise

**Example:**
```levy
is_muted <- OS.AudioControl.get_mute()
if is_muted {
    say("Audio is muted")
}
```

#### `OS.AudioControl.set_mute(muted, device_id=default)`
Set the mute status.

**Parameters:**
- `muted` (boolean): Mute status (true to mute, false to unmute)
- `device_id` (string, optional): Device ID

**Returns:** Boolean - Success status

**Example:**
```levy
// Mute audio
OS.AudioControl.set_mute(true)

// Unmute audio
OS.AudioControl.set_mute(false)
```

### Audio Playback

#### `OS.AudioControl.play_sound(file_path, volume=1.0, device_id=default)`
Play an audio file.

**Parameters:**
- `file_path` (string): Path to audio file (WAV, MP3, etc.)
- `volume` (float, optional): Playback volume (0.0 to 1.0, default 1.0)
- `device_id` (string, optional): Target device ID

**Returns:** Boolean - Success status

**Supported Formats:**
- Windows: WAV, MP3, WMA
- macOS: WAV, MP3, AAC, ALAC, FLAC
- Linux: WAV (via aplay)

**Example:**
```levy
// Play sound at full volume
OS.AudioControl.play_sound("notification.wav")

// Play at 50% volume
OS.AudioControl.play_sound("alert.wav", 0.5)
```

#### `OS.AudioControl.play_tone(frequency, duration, volume=0.5)`
Generate and play a sine wave tone.

**Parameters:**
- `frequency` (float): Tone frequency in Hz (e.g., 440.0 for A4)
- `duration` (float): Duration in seconds
- `volume` (float, optional): Volume level (0.0 to 1.0, default 0.5)

**Returns:** Boolean - Success status

**Example:**
```levy
// Play middle A (440 Hz) for 1 second
OS.AudioControl.play_tone(440.0, 1.0, 0.5)

// Play a C major chord
OS.AudioControl.play_tone(261.63, 0.5, 0.3)  // C4
OS.AudioControl.play_tone(329.63, 0.5, 0.3)  // E4
OS.AudioControl.play_tone(392.00, 0.5, 0.3)  // G4
```

#### `OS.AudioControl.stop_playback(stream_id)`
Stop playback on a specific stream.

**Parameters:**
- `stream_id` (integer): Stream identifier

**Returns:** Boolean - Success status

**Example:**
```levy
stream_id <- OS.AudioControl.create_stream(config)
// ... start playback ...
OS.AudioControl.stop_playback(stream_id)
```

### Stream Management

#### `OS.AudioControl.create_stream(config)`
Create a new audio stream.

**Parameters:**
- `config` (map): Stream configuration
  - `device_id` (string, optional): Target device
  - `channels` (integer, optional): Number of channels (default: 2)
  - `sample_rate` (integer, optional): Sample rate in Hz (default: 44100)
  - `buffer_size` (integer, optional): Buffer size in frames (default: 1024)

**Returns:** Integer - Stream ID

**Example:**
```levy
config <- {
    "channels": 2,
    "sample_rate": 44100,
    "buffer_size": 1024
}
stream_id <- OS.AudioControl.create_stream(config)
```

#### `OS.AudioControl.write_stream(stream_id, audio_data)`
Write audio data to a stream.

**Parameters:**
- `stream_id` (integer): Stream identifier
- `audio_data` (list): List of audio samples (16-bit integers)

**Returns:** Integer - Number of bytes written

**Example:**
```levy
// Generate sine wave
samples <- []
for i in range(4410) {  // 0.1 seconds at 44.1kHz
    t <- i / 44100.0
    value <- sin(2.0 * 3.14159 * 440.0 * t) * 16000.0
    samples <- samples + [int(value)]
}

bytes_written <- OS.AudioControl.write_stream(stream_id, samples)
```

#### `OS.AudioControl.close_stream(stream_id)`
Close an audio stream and release resources.

**Parameters:**
- `stream_id` (integer): Stream identifier

**Returns:** Boolean - Success status

**Example:**
```levy
OS.AudioControl.close_stream(stream_id)
```

### Recording

#### `OS.AudioControl.record_audio(duration, device_id=default)`
Record audio from an input device.

**Parameters:**
- `duration` (float): Recording duration in seconds
- `device_id` (string, optional): Input device ID

**Returns:** List - Audio samples (16-bit integers)

**Example:**
```levy
// Record 5 seconds of audio
audio_data <- OS.AudioControl.record_audio(5.0)
say("Recorded " + str(len(audio_data)) + " samples")
```

#### `OS.AudioControl.stop_recording(stream_id)`
Stop an ongoing recording.

**Parameters:**
- `stream_id` (integer): Recording stream identifier

**Returns:** List - Recorded audio samples

**Example:**
```levy
// Start recording in background
stream_id <- OS.AudioControl.create_stream({"type": "recording"})
// ... later ...
audio_data <- OS.AudioControl.stop_recording(stream_id)
```

### Audio Processing

#### `OS.AudioControl.mix_audio(audio_data_list, weights)`
Mix multiple audio signals with specified weights.

**Parameters:**
- `audio_data_list` (list): List of audio sample lists
- `weights` (list): Mixing weights for each signal (floats)

**Returns:** List - Mixed audio samples

**Example:**
```levy
signal1 <- [100, 200, 300, 400, 500]
signal2 <- [50, 100, 150, 200, 250]
signal3 <- [25, 50, 75, 100, 125]

// Mix with 50%, 30%, 20% weights
mixed <- OS.AudioControl.mix_audio(
    [signal1, signal2, signal3],
    [0.5, 0.3, 0.2]
)
```

#### `OS.AudioControl.apply_effect(audio_data, effect_type, params={})`
Apply an audio effect to audio data.

**Parameters:**
- `audio_data` (list): Audio samples
- `effect_type` (string): Effect type
  - `"amplify"` - Amplify signal (param: `gain`)
  - `"normalize"` - Normalize levels
  - `"fade_in"` - Fade in effect
  - `"fade_out"` - Fade out effect
  - `"reverb"` - Reverb effect
  - `"echo"` - Echo effect
  - `"lowpass"` - Low-pass filter
  - `"highpass"` - High-pass filter
- `params` (map, optional): Effect-specific parameters

**Returns:** List - Processed audio samples

**Example:**
```levy
audio <- [100, 200, 300, 400, 500]

// Amplify by 2x
amplified <- OS.AudioControl.apply_effect(audio, "amplify", {"gain": 2.0})

// Apply fade in
faded_in <- OS.AudioControl.apply_effect(audio, "fade_in", {})

// Apply fade out
faded_out <- OS.AudioControl.apply_effect(audio, "fade_out", {})
```

### Device Configuration

#### `OS.AudioControl.get_sample_rate(device_id=default)`
Get the current sample rate of a device.

**Parameters:**
- `device_id` (string, optional): Device ID

**Returns:** Integer - Sample rate in Hz

**Example:**
```levy
rate <- OS.AudioControl.get_sample_rate()
say("Sample rate: " + str(rate) + " Hz")
```

#### `OS.AudioControl.set_sample_rate(sample_rate, device_id=default)`
Set the sample rate for a device (requires device reinitialization).

**Parameters:**
- `sample_rate` (integer): Sample rate in Hz
- `device_id` (string, optional): Device ID

**Returns:** Boolean - Success status

**Common Sample Rates:**
- 8000 Hz - Telephone quality
- 11025 Hz - Low quality
- 16000 Hz - Wideband audio
- 22050 Hz - Half of CD quality
- 44100 Hz - CD quality (default)
- 48000 Hz - Professional audio
- 96000 Hz - High-resolution audio
- 192000 Hz - Ultra high-resolution

**Example:**
```levy
// Set to CD quality
OS.AudioControl.set_sample_rate(44100)

// Set to professional audio
OS.AudioControl.set_sample_rate(48000)
```

## Complete Examples

### Example 1: Simple Volume Control
```levy
// Get current volume
volume <- OS.AudioControl.get_volume()
say("Current volume: " + str(volume * 100) + "%")

// Set to 75%
OS.AudioControl.set_volume(0.75)
say("Volume set to 75%")

// Mute
OS.AudioControl.set_mute(true)
say("Audio muted")
```

### Example 2: Play Musical Scale
```levy
notes <- {
    "C": 261.63,
    "D": 293.66,
    "E": 329.63,
    "F": 349.23,
    "G": 392.00,
    "A": 440.00,
    "B": 493.88,
    "C2": 523.25
}

for note_name in ["C", "D", "E", "F", "G", "A", "B", "C2"] {
    frequency <- notes[note_name]
    say("Playing " + note_name + "...")
    OS.AudioControl.play_tone(frequency, 0.5, 0.3)
}
```

### Example 3: Audio Stream with Sine Wave
```levy
// Create stream
config <- {
    "channels": 2,
    "sample_rate": 44100,
    "buffer_size": 1024
}
stream_id <- OS.AudioControl.create_stream(config)

// Generate stereo sine wave (1 second)
samples <- []
frequency <- 440.0
sample_rate <- 44100.0

for i in range(44100) {
    t <- i / sample_rate
    left <- sin(2.0 * 3.14159 * frequency * t) * 16000.0
    right <- sin(2.0 * 3.14159 * frequency * 1.5 * t) * 16000.0
    samples <- samples + [int(left), int(right)]
}

// Write and play
OS.AudioControl.write_stream(stream_id, samples)

// Clean up
OS.AudioControl.close_stream(stream_id)
```

### Example 4: Audio Mixing and Effects
```levy
// Create three audio signals
bass <- []
mid <- []
treble <- []

for i in range(1000) {
    t <- i / 44100.0
    bass <- bass + [int(sin(2.0 * 3.14159 * 100.0 * t) * 5000.0)]
    mid <- mid + [int(sin(2.0 * 3.14159 * 440.0 * t) * 8000.0)]
    treble <- treble + [int(sin(2.0 * 3.14159 * 1760.0 * t) * 3000.0)]
}

// Mix with different weights
mixed <- OS.AudioControl.mix_audio([bass, mid, treble], [0.4, 0.4, 0.2])

// Apply fade in
faded <- OS.AudioControl.apply_effect(mixed, "fade_in", {})

// Apply amplification
amplified <- OS.AudioControl.apply_effect(faded, "amplify", {"gain": 1.5})

say("Mixed and processed " + str(len(amplified)) + " samples")
```

### Example 5: Device Information Display
```levy
devices <- OS.AudioControl.list_devices("all")

say("Available Audio Devices:")
say("=" * 60)

for device in devices {
    say("\nDevice: " + device["name"])
    say("  ID: " + device["id"])
    say("  Type: " + device["type"])
    say("  Default: " + str(device["is_default"]))
    say("  Channels: " + str(device["channels"]))
    say("  Sample Rate: " + str(device["sample_rate"]) + " Hz")
    say("  Format: " + device["format"])
    say("  Latency: " + str(device["latency"]) + " ms")
}
```

## Error Handling

All OS.AudioControl functions may throw errors. Use try-catch blocks for robust error handling:

```levy
try {
    OS.AudioControl.set_volume(0.8)
    say("Volume set successfully")
} catch error {
    say("Error setting volume: " + str(error))
}
```

## Best Practices

1. **Check Device Availability**: Always enumerate devices before accessing them
2. **Handle Errors**: Wrap audio calls in try-catch blocks
3. **Resource Management**: Close streams when done to free resources
4. **Volume Ranges**: Keep volumes between 0.0 and 1.0 for best results
5. **Sample Rate**: Use 44100 Hz for compatibility across platforms
6. **Buffer Size**: Use 1024 frames for low-latency applications

## Platform-Specific Notes

### Windows
- Requires Windows Vista or later for WASAPI
- Some operations may require administrator privileges
- COM is automatically initialized/cleaned up

### macOS
- Requires macOS 10.7 or later
- CoreAudio provides lowest latency
- Sample rate changes may require audio device restart

### Linux
- Requires ALSA library (`libasound2`)
- PulseAudio/PipeWire are supported through ALSA
- Default device is typically "default" or "hw:0"

## Troubleshooting

**No devices found:**
- Check audio drivers are installed
- Verify permissions (may need admin/root)
- Check that audio service is running

**Playback issues:**
- Verify file format is supported
- Check volume is not muted
- Ensure device is not in exclusive mode

**Latency problems:**
- Reduce buffer size (tradeoff: more CPU usage)
- Use exclusive mode if supported
- Close other audio applications

## License

OS.AudioControl module is part of Levython, licensed under MIT License.
Copyright (c) 2024 Levython Authors.
