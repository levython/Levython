# OS.AudioControl Implementation Summary

## Overview

The OS.AudioControl module provides comprehensive audio device management and playback capabilities for the Levython programming language. This document describes the technical implementation details, platform-specific APIs used, and architectural decisions.

## Architecture

### Module Structure

```
OS.AudioControl/
├── Data Structures (levython.cpp:7040-7540)
│   ├── AudioDeviceInfo - Device information
│   ├── AudioStreamConfig - Stream configuration
│   ├── AudioStream - Active audio stream
│   ├── AudioControlState - Global audio state
│   └── Enums (AudioDeviceType, AudioFormat, AudioEffect)
│
├── Function Declarations (levython.cpp:3218-3245)
│   └── 24 builtin function prototypes
│
├── Implementation (levython.cpp:13760-14830)
│   ├── Device Management (6 functions)
│   ├── Volume Control (4 functions)
│   ├── Playback (3 functions)
│   ├── Stream Management (3 functions)
│   ├── Recording (2 functions)
│   ├── Processing (2 functions)
│   └── Configuration (2 functions)
│
└── Builtin Registration (levython.cpp:5864-5886, 15121-15173)
    ├── Builtin dispatcher entries
    └── Module initialization in create_os_module()
```

## Platform-Specific Implementation

### Windows (WASAPI/WinMM)

#### Headers Required
```cpp
#include <mmsystem.h>           // waveOut/waveIn APIs
#include <mmdeviceapi.h>        // IMMDeviceEnumerator
#include <endpointvolume.h>     // IAudioEndpointVolume
#include <audioclient.h>        // IAudioClient
#include <functiondiscoverykeys_devpkey.h>  // Device properties
```

#### Key APIs Used

**Device Enumeration:**
- `IMMDeviceEnumerator::EnumAudioEndpoints()` - List audio endpoints
- `IMMDevice::GetId()` - Get device identifier
- `IMMDevice::OpenPropertyStore()` - Get device properties
- `IMMDeviceEnumerator::GetDefaultAudioEndpoint()` - Get default device

**Volume Control:**
- `IAudioEndpointVolume::GetMasterVolumeLevelScalar()` - Get volume
- `IAudioEndpointVolume::SetMasterVolumeLevelScalar()` - Set volume
- `IAudioEndpointVolume::GetMute()` / `SetMute()` - Mute control

**Playback:**
- `waveOutOpen()` / `waveOutClose()` - Open/close output device
- `waveOutPrepareHeader()` / `waveOutWrite()` - Write audio data
- `PlaySound()` - Simple file playback

**Initialization:**
```cpp
// COM initialization for WASAPI
CoInitializeEx(nullptr, COINIT_MULTITHREADED);
CoCreateInstance(__uuidof(MMDeviceEnumerator), ...);
```

### macOS (CoreAudio)

#### Headers Required
```cpp
#include <CoreAudio/CoreAudio.h>      // Core audio functionality
#include <AudioToolbox/AudioToolbox.h> // Audio file I/O
#include <AudioUnit/AudioUnit.h>       // Audio processing units
```

#### Key APIs Used

**Device Enumeration:**
- `AudioObjectGetPropertyData()` - Get audio device list
- `kAudioHardwarePropertyDevices` - Device query
- `kAudioDevicePropertyDeviceNameCFString` - Get device name
- `kAudioHardwarePropertyDefaultOutputDevice` - Default device

**Volume Control:**
- `kAudioDevicePropertyVolumeScalar` - Volume property
- `kAudioDevicePropertyMute` - Mute property
- `AudioObjectSetPropertyData()` - Set properties

**Playback:**
- `AudioComponent` / `AudioUnit` - Audio processing
- `AudioOutputUnitStart()` / `AudioOutputUnitStop()` - Control playback
- `system("afplay ...")` - Simple file playback

**Sample Rate:**
- `kAudioDevicePropertyNominalSampleRate` - Get/set sample rate

### Linux (ALSA)

#### Headers Required
```cpp
#include <alsa/asoundlib.h>  // ALSA audio library
```

#### Key APIs Used

**Device Enumeration:**
- `snd_device_name_hint()` - Get device hints
- `snd_device_name_get_hint()` - Get device properties

**Volume Control:**
- `snd_mixer_open()` - Open mixer
- `snd_mixer_selem_get_playback_volume()` - Get volume
- `snd_mixer_selem_set_playback_volume_all()` - Set volume
- `snd_mixer_selem_get_playback_switch()` - Get mute state
- `snd_mixer_selem_set_playback_switch_all()` - Set mute

**Playback:**
- `snd_pcm_open()` - Open PCM device
- `snd_pcm_set_params()` - Configure PCM parameters
- `snd_pcm_writei()` - Write audio frames
- `system("aplay ...")` - Simple WAV playback

**Recording:**
- `snd_pcm_open(SND_PCM_STREAM_CAPTURE)` - Open capture device
- `snd_pcm_readi()` - Read audio frames

## Data Structures

### AudioDeviceInfo
```cpp
struct AudioDeviceInfo {
    std::string id;              // Unique identifier
    std::string name;            // Human-readable name
    AudioDeviceType type;        // PLAYBACK/RECORDING/LOOPBACK
    bool is_default;             // Is default device
    uint32_t channels;           // Number of channels (1=mono, 2=stereo)
    uint32_t sample_rate;        // Hz (44100, 48000, etc.)
    AudioFormat format;          // Sample format (PCM_S16, etc.)
    uint32_t buffer_size;        // Frames per buffer
    double latency;              // Milliseconds
    void* native_handle;         // Platform-specific handle
};
```

### AudioStream
```cpp
struct AudioStream {
    uint32_t stream_id;          // Unique stream ID
    AudioStreamConfig config;    // Stream configuration
    bool is_playing;             // Playback state
    bool is_recording;           // Recording state
    std::vector<uint8_t> buffer; // Audio buffer
    size_t buffer_position;      // Current position
    void* native_stream;         // Platform handle
    std::mutex mutex;            // Thread safety
    
    // Platform-specific handles
    #ifdef _WIN32
    HWAVEOUT wave_out;
    HWAVEIN wave_in;
    WAVEHDR wave_header;
    #elif __APPLE__
    AudioUnit audio_unit;
    AudioStreamBasicDescription stream_format;
    #elif __linux__
    snd_pcm_t* pcm_handle;
    snd_pcm_hw_params_t* hw_params;
    #endif
};
```

### AudioControlState (Singleton)
```cpp
struct AudioControlState {
    std::map<std::string, AudioDeviceInfo> devices;
    std::map<uint32_t, std::shared_ptr<AudioStream>> streams;
    uint32_t next_stream_id;
    std::string default_playback_device;
    std::string default_recording_device;
    std::mutex mutex;
    
    #ifdef _WIN32
    IMMDeviceEnumerator* device_enumerator;
    bool com_initialized;
    #endif
};
```

## Key Implementation Details

### Thread Safety

All audio state is protected by mutexes:
- `AudioControlState::mutex` - Protects device and stream maps
- `AudioStream::mutex` - Protects individual stream state

### Resource Management

**Automatic Cleanup:**
- AudioStream destructor closes platform handles
- AudioControlState destructor releases all resources
- COM cleanup on Windows (CoUninitialize)
- ALSA cleanup on Linux (snd_pcm_close, snd_mixer_close)

**Stream Lifecycle:**
```
create_stream() → write_stream() → [playback] → close_stream()
                                               ↓
                                    stop_playback() (optional)
```

### Audio Sample Format

Default format: **PCM_S16** (16-bit signed integer)
- Sample values: -32768 to 32767
- 0 = silence
- Stereo: interleaved samples [L, R, L, R, ...]

### Tone Generation

Sine wave generation formula:
```cpp
sample = amplitude * sin(2π * frequency * time)
```

Implementation:
```cpp
for (uint32_t i = 0; i < num_samples; ++i) {
    double t = static_cast<double>(i) / sample_rate;
    double value = volume * 32767.0 * std::sin(2.0 * M_PI * frequency * t);
    samples[i] = static_cast<int16_t>(value);
}
```

### Audio Mixing

Simple weighted sum algorithm:
```cpp
mixed[i] = signal1[i] * weight1 + signal2[i] * weight2 + ...
```

Prevents clipping by normalizing weights to sum ≤ 1.0

### Effects Processing

**Amplify:**
```cpp
output[i] = input[i] * gain
```

**Fade In:**
```cpp
output[i] = input[i] * (i / fade_length)
```

**Fade Out:**
```cpp
output[i] = input[i] * (1.0 - ((i - fade_start) / fade_length))
```

## Error Handling

All functions use C++ exceptions for error reporting:
```cpp
throw std::runtime_error("Error message")
```

Exceptions are caught at the Levython VM level and converted to Levython errors.

Common errors:
- Device not found
- Invalid device ID
- Stream not found
- Unsupported format
- Platform API failure

## Performance Considerations

### Buffer Sizes
- Small buffers (256-512): Low latency, high CPU
- Medium buffers (1024-2048): Balanced (default)
- Large buffers (4096+): High latency, low CPU

### Sample Rates
- Higher sample rates = more data to process
- 44100 Hz is optimal for most applications
- 48000 Hz for professional audio/video

### Platform Performance

| Platform | Latency | CPU Usage | Notes |
|----------|---------|-----------|-------|
| Windows (WASAPI) | 5-10ms | Low | Best on Windows 10+ |
| Windows (WinMM) | 20-50ms | Medium | Legacy, more compatible |
| macOS (CoreAudio) | 3-5ms | Low | Excellent performance |
| Linux (ALSA) | 5-15ms | Medium | Depends on config |

## Compilation Requirements

### Windows
```makefile
LIBS += -lwinmm -lole32
```

### macOS
```makefile
FRAMEWORKS += -framework CoreAudio -framework AudioToolbox -framework AudioUnit
```

### Linux
```makefile
LIBS += -lasound
PACKAGES += alsa
```

## Testing Checklist

- [ ] Device enumeration works
- [ ] Default device identification
- [ ] Volume get/set operations
- [ ] Mute get/set operations
- [ ] Tone generation and playback
- [ ] File playback (if file exists)
- [ ] Stream creation and writing
- [ ] Stream closing and cleanup
- [ ] Audio mixing produces correct output
- [ ] Effects apply correctly
- [ ] Thread safety (concurrent access)
- [ ] Resource cleanup (no leaks)
- [ ] Error handling (invalid inputs)
- [ ] Cross-platform compatibility

## Known Limitations

### Windows
- Volume control requires Windows Vista+
- Some operations need administrator privileges
- COM initialization required (handled automatically)

### macOS
- Sample rate changes may require device restart
- Some devices don't support all sample rates
- Requires macOS 10.7+

### Linux
- ALSA configuration varies by distribution
- PulseAudio adds complexity
- Default device name may differ ("default", "hw:0", etc.)

### General
- Recording implementation is placeholder (needs full implementation)
- Advanced effects (reverb, echo) are simplified
- Exclusive mode not fully implemented
- Loopback device support is basic

## Future Enhancements

1. **Full Recording Support**
   - Implement complete recording pipeline
   - Add input device monitoring
   - Real-time recording with callbacks

2. **Advanced Effects**
   - Complete reverb implementation
   - Echo with configurable delay/decay
   - Parametric EQ
   - Compressor/limiter

3. **Format Support**
   - MP3 encoding/decoding
   - AAC support
   - FLAC support
   - Automatic format conversion

4. **Callback-Based Streaming**
   - Real-time audio callbacks
   - Lower latency
   - Better for interactive applications

5. **WASAPI Exclusive Mode**
   - Bypass audio mixing on Windows
   - Lower latency
   - Bit-perfect output

6. **PulseAudio/PipeWire Support**
   - Native Linux support
   - Better integration with modern Linux
   - Network audio support

## Integration with Levython

### Value System Integration

Audio data is represented as Levython lists:
```levy
samples <- [100, 200, 300, ...]  // List of integers
```

Device information as maps:
```levy
device <- {
    "id": "device_123",
    "name": "Speakers",
    "channels": 2,
    "sample_rate": 44100
}
```

### Builtin Function Registration

Functions are registered in `create_os_module()`:
```cpp
Value audiocontrol_module(ObjectType::MAP);
add_audiocontrol_builtin("list_devices", "os_audiocontrol_list_devices", {"type"});
// ... more functions ...
os_module.data.map["AudioControl"] = audiocontrol_module;
```

### Builtin Dispatcher

The VM dispatcher routes calls:
```cpp
if (name == "os_audiocontrol_list_devices") 
    return os_bindings::builtin_os_audiocontrol_list_devices(args);
```

## Documentation References

- [OS_AUDIOCONTROL_MODULE.md](OS_AUDIOCONTROL_MODULE.md) - Complete API documentation
- [OS_AUDIOCONTROL_QUICKREF.md](OS_AUDIOCONTROL_QUICKREF.md) - Quick reference guide
- [examples/31_os_audiocontrol_demo.levy](examples/31_os_audiocontrol_demo.levy) - Usage examples

## Credits

Implementation based on:
- WASAPI: Microsoft Windows Audio Session API
- CoreAudio: Apple Core Audio framework
- ALSA: Advanced Linux Sound Architecture

Levython OS.AudioControl module
Copyright (c) 2024 Levython Authors
Licensed under MIT License
