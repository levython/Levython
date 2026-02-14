# OS.AudioControl Quick Reference

## Device Management
```levy
// List all devices
devices <- OS.AudioControl.list_devices("all")          // "all", "playback", "recording"

// Get default device
device_id <- OS.AudioControl.get_default_device("playback")  // "playback" or "recording"

// Set default device
OS.AudioControl.set_default_device(device_id)

// Get device info
info <- OS.AudioControl.get_device_info(device_id)
// Returns: {id, name, type, is_default, channels, sample_rate, format, buffer_size, latency}
```

## Volume Control
```levy
// Get volume (0.0 - 1.0)
volume <- OS.AudioControl.get_volume()                   // Default device
volume <- OS.AudioControl.get_volume(device_id)          // Specific device

// Set volume
OS.AudioControl.set_volume(0.75)                         // 75% volume on default
OS.AudioControl.set_volume(0.5, device_id)               // 50% on specific device

// Mute control
is_muted <- OS.AudioControl.get_mute()
OS.AudioControl.set_mute(true)                           // Mute
OS.AudioControl.set_mute(false)                          // Unmute
```

## Playback
```levy
// Play sound file
OS.AudioControl.play_sound("sound.wav")                  // Full volume
OS.AudioControl.play_sound("sound.wav", 0.8)             // 80% volume
OS.AudioControl.play_sound("sound.wav", 0.5, device_id)  // On specific device

// Generate and play tone
OS.AudioControl.play_tone(440.0, 1.0)                    // 440 Hz, 1 sec, default volume
OS.AudioControl.play_tone(523.25, 0.5, 0.3)              // C5, 0.5 sec, 30% volume

// Stop playback
OS.AudioControl.stop(stream_id)
```

## Stream Management
```levy
// Create stream
config <- {
    "device_id": device_id,      // Optional
    "channels": 2,               // Stereo
    "sample_rate": 44100,        // CD quality
    "buffer_size": 1024          // Frames
}
stream_id <- OS.AudioControl.create_stream(config)

// Write audio data
samples <- [100, 200, 300, ...]  // List of 16-bit samples
bytes_written <- OS.AudioControl.write_stream(stream_id, samples)

// Close stream
OS.AudioControl.close_stream(stream_id)
```

## Recording
```levy
// Record audio
audio_data <- OS.AudioControl.record(5.0)          // 5 seconds
audio_data <- OS.AudioControl.record(3.0, device_id)  // Specific device

// Stop recording
audio_data <- OS.AudioControl.stop_recording(stream_id)
```

## Audio Processing
```levy
// Mix audio signals
signal1 <- [100, 200, 300, 400, 500]
signal2 <- [50, 100, 150, 200, 250]
mixed <- OS.AudioControl.mix_streams(
    [signal1, signal2],          // Audio signals
    [0.7, 0.3]                   // Weights (70%, 30%)
)

// Apply effects
amplified <- OS.AudioControl.apply_effect(audio, "amplify", {"gain": 2.0})
faded_in <- OS.AudioControl.apply_effect(audio, "fade_in", {})
faded_out <- OS.AudioControl.apply_effect(audio, "fade_out", {})
```

## Sample Rate
```levy
// Get sample rate
rate <- OS.AudioControl.get_sample_rate()
rate <- OS.AudioControl.get_sample_rate(device_id)

// Set sample rate
OS.AudioControl.set_sample_rate(44100)                   // CD quality
OS.AudioControl.set_sample_rate(48000, device_id)        // Professional
```

## Common Use Cases

### Simple Notification Sound
```levy
OS.AudioControl.play_sound("notification.wav", 0.5)
```

### Play Musical Note
```levy
// Middle C for 0.5 seconds at 30% volume
OS.AudioControl.play_tone(261.63, 0.5, 0.3)
```

### Volume Fade
```levy
// Gradually increase volume
for i in range(11) {
    volume <- i / 10.0
    OS.AudioControl.set_volume(volume)
    // Add small delay
}
```

### Generate Sine Wave
```levy
samples <- []
frequency <- 440.0    // A4
sample_rate <- 44100.0
duration <- 1.0

num_samples <- int(sample_rate * duration)
for i in range(num_samples) {
    t <- i / sample_rate
    value <- sin(2.0 * 3.14159 * frequency * t) * 16000.0
    samples <- samples + [int(value)]
}
```

### Check Audio Status
```levy
volume <- OS.AudioControl.get_volume()
is_muted <- OS.AudioControl.get_mute()

if is_muted {
    say("Audio is muted")
} else {
    say("Volume: " + str(volume * 100) + "%")
}
```

### List All Devices
```levy
devices <- OS.AudioControl.list_devices("all")
for device in devices {
    marker <- device["is_default"] ? " [DEFAULT]" : ""
    say(device["name"] + marker)
}
```

## Musical Notes (Frequencies in Hz)

| Note | Octave 4 | Octave 5 |
|------|----------|----------|
| C    | 261.63   | 523.25   |
| C#   | 277.18   | 554.37   |
| D    | 293.66   | 587.33   |
| D#   | 311.13   | 622.25   |
| E    | 329.63   | 659.25   |
| F    | 349.23   | 698.46   |
| F#   | 369.99   | 739.99   |
| G    | 392.00   | 783.99   |
| G#   | 415.30   | 830.61   |
| A    | 440.00   | 880.00   |
| A#   | 466.16   | 932.33   |
| B    | 493.88   | 987.77   |

## Sample Rates

| Rate (Hz) | Quality               | Use Case                    |
|-----------|-----------------------|-----------------------------|
| 8000      | Telephone             | Voice, telephony            |
| 11025     | Low                   | Basic audio                 |
| 16000     | Wideband             | VoIP, speech                |
| 22050     | FM radio              | Web audio, podcasts         |
| 44100     | CD quality (standard) | Music, general purpose      |
| 48000     | Professional          | Video, production           |
| 96000     | High-res              | Studio recording            |
| 192000    | Ultra high-res        | Mastering                   |

## Audio Formats

| Format    | Bits | Type          | Use Case              |
|-----------|------|---------------|-----------------------|
| PCM_U8    | 8    | Unsigned      | Basic audio           |
| PCM_S16   | 16   | Signed        | Standard (default)    |
| PCM_S24   | 24   | Signed        | Professional          |
| PCM_S32   | 32   | Signed        | High precision        |
| PCM_F32   | 32   | Float         | Processing, effects   |

## Effect Types

| Effect    | Parameters        | Description               |
|-----------|-------------------|---------------------------|
| amplify   | gain (float)      | Multiply signal by gain   |
| normalize | -                 | Normalize to max level    |
| fade_in   | -                 | Fade in from silence      |
| fade_out  | -                 | Fade out to silence       |
| reverb    | room_size (float) | Add reverberation         |
| echo      | delay, decay      | Add echo effect           |
| lowpass   | cutoff (Hz)       | Filter high frequencies   |
| highpass  | cutoff (Hz)       | Filter low frequencies    |
| bandpass  | low, high (Hz)    | Filter outside range      |

## Error Handling Pattern
```levy
try {
    // Audio operation
    OS.AudioControl.set_volume(0.8)
    say("Success")
} catch error {
    say("Error: " + str(error))
}
```

## Best Practices

✅ **DO:**
- Check device availability before use
- Close streams when done
- Use standard sample rates (44100 Hz)
- Keep volumes in 0.0-1.0 range
- Handle errors with try-catch
- Use appropriate buffer sizes (1024-4096 frames)

❌ **DON'T:**
- Leave streams open indefinitely
- Set extreme volume values
- Ignore error conditions
- Use unsupported sample rates
- Play audio on non-existent devices

## Platform APIs

| Platform | Primary API | Fallback         |
|----------|-------------|------------------|
| Windows  | WASAPI      | WinMM (waveOut)  |
| macOS    | CoreAudio   | AudioUnit        |
| Linux    | ALSA        | PulseAudio/Pipe  |

## Quick Troubleshooting

**No sound:**
```levy
// Check volume and mute
volume <- OS.AudioControl.get_volume()
muted <- OS.AudioControl.get_mute()
say("Volume: " + str(volume) + ", Muted: " + str(muted))

// Check devices
devices <- OS.AudioControl.list_devices("playback")
say("Devices: " + str(len(devices)))
```

**Device not found:**
```levy
// List all devices
devices <- OS.AudioControl.list_devices("all")
for device in devices {
    say(device["id"] + ": " + device["name"])
}
```

**Verify default device:**
```levy
try {
    device_id <- OS.AudioControl.get_default_device("playback")
    info <- OS.AudioControl.get_device_info(device_id)
    say("Default: " + info["name"])
} catch error {
    say("Error: " + str(error))
}
```

---

**For complete documentation, see:** [OS_AUDIOCONTROL_MODULE.md](OS_AUDIOCONTROL_MODULE.md)

**For example code, see:** [examples/31_os_audiocontrol_demo.levy](examples/31_os_audiocontrol_demo.levy)
