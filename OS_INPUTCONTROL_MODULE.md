# OS.InputControl Module - API Reference

The **OS.InputControl** module provides comprehensive control over system input devices including keyboard, mouse, and touch interfaces. It enables low-level input capture, automation, blocking, remapping, and monitoring through platform-specific APIs.

## Table of Contents

1. [Overview](#overview)
2. [Platform Support](#platform-support)
3. [API Reference](#api-reference)
   - [Keyboard Functions](#keyboard-functions)
   - [Mouse Functions](#mouse-functions)
   - [Touch Functions](#touch-functions)
   - [Utility Functions](#utility-functions)
4. [Constants](#constants)
5. [Data Structures](#data-structures)
6. [Usage Examples](#usage-examples)
7. [Security & Permissions](#security--permissions)
8. [Best Practices](#best-practices)

---

## Overview

The OS.InputControl module interfaces with operating system input subsystems to provide:

- **Input Capture**: Monitor keyboard, mouse, and touch events
- **Input Automation**: Programmatically send keystrokes, mouse movements, and clicks
- **Input Blocking**: Prevent specific keys or mouse buttons from reaching applications
- **Key Remapping**: Redirect key presses to different keys  
- **State Queries**: Check mouse position and keyboard state
- **Touch Control**: Simulate touch events on touch-enabled devices

### Key Features

✅ Cross-platform support (Windows, Linux, macOS)  
✅ Low-level driver integration  
✅ Thread-safe operations  
✅ Capture & playback capabilities  
✅ Fine-grained input filtering  
✅ Real-time position tracking  

---

## Platform Support

| Platform | Technologies | Features |
|----------|-------------|----------|
| **Windows** | SendInput, SetWindowsHookEx, GetAsyncKeyState | Full support for all features |
| **macOS** | CGEvent APIs, IOKit HID | Full support for all features |
| **Linux** | X11/Xlib, XTest, /dev/input | Full support for all features |

### Platform-Specific Notes

**Windows:**
- Requires appropriate privileges for low-level hooks
- UAC may block some operations
- Works with SendInput and Windows Hook APIs

**macOS:**
- Requires accessibility permissions
- Must grant input monitoring access
- Uses Core Graphics and IOKit

**Linux:**
- Requires X11 server (Wayland support limited)
- May need root for /dev/input access
- Uses XTest extension for automation

---

## API Reference

### Keyboard Functions

#### `os.InputControl.keyboard_capture()`

Starts capturing keyboard input events.

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
result <- os.InputControl.keyboard_capture()
if result {
    say("Keyboard capture started")
}
```

---

#### `os.InputControl.keyboard_release()`

Stops capturing keyboard input events.

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
os.InputControl.keyboard_release()
```

---

#### `os.InputControl.keyboard_send(virtual_key, is_pressed)`

Sends a keyboard event (key press or release).

**Parameters:**
- `virtual_key` (int): Virtual key code (platform-specific)
- `is_pressed` (bool): `yes` for key down, `no` for key up

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
# Press 'A' key (virtual key 65)
os.InputControl.keyboard_send(65, yes)
os.sleep_ms(50)
os.InputControl.keyboard_send(65, no)
```

**Common Virtual Key Codes:**
- 8: Backspace
- 9: Tab
- 13: Enter
- 16: Shift
- 17: Ctrl
- 18: Alt
- 27: Escape
- 32: Space
- 65-90: A-Z keys
- 112-123: F1-F12

---

#### `os.InputControl.keyboard_send_text(text)`

Types a text string by simulating keyboard events.

**Parameters:**
- `text` (string): Text to type

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
os.InputControl.keyboard_send_text("Hello, World!")
```

---

#### `os.InputControl.keyboard_block(virtual_key)`

Blocks a specific key from reaching applications.

**Parameters:**
- `virtual_key` (int): Virtual key code to block

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
# Block Escape key
os.InputControl.keyboard_block(27)
```

---

#### `os.InputControl.keyboard_unblock(virtual_key)`

Unblocks a previously blocked key.

**Parameters:**
- `virtual_key` (int): Virtual key code to unblock

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
os.InputControl.keyboard_unblock(27)
```

---

#### `os.InputControl.keyboard_remap(from_key, to_key)`

Remaps one key to another. Set `to_key` to 0 to remove remapping.

**Parameters:**
- `from_key` (int): Source virtual key code
- `to_key` (int): Target virtual key code (0 to remove remap)

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
# Remap Caps Lock to Ctrl
os.InputControl.keyboard_remap(20, 17)

# Remove remapping
os.InputControl.keyboard_remap(20, 0)
```

---

#### `os.InputControl.keyboard_get_state()`

Gets the current state of all keyboard keys.

**Returns:** `map` - Key-value pairs where keys are virtual key codes and values are `yes` (pressed) or `no` (not pressed)

**Example:**
```levy
state <- os.InputControl.keyboard_get_state()
# Check if 'A' key is pressed
if state[65] {
    say("A key is pressed")
}
```

---

### Mouse Functions

#### `os.InputControl.mouse_capture()`

Starts capturing mouse input events.

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
os.InputControl.mouse_capture()
```

---

#### `os.InputControl.mouse_release()`

Stops capturing mouse input events.

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
os.InputControl.mouse_release()
```

---

#### `os.InputControl.mouse_move(x, y)`

Moves the mouse cursor to absolute screen coordinates.

**Parameters:**
- `x` (int): Target X coordinate
- `y` (int): Target Y coordinate

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
# Move to center of 1920x1080 screen
os.InputControl.mouse_move(960, 540)
```

---

#### `os.InputControl.mouse_click(button, is_pressed)`

Sends a mouse button event (press or release).

**Parameters:**
- `button` (int): Mouse button constant (MOUSE_LEFT, MOUSE_RIGHT, MOUSE_MIDDLE)
- `is_pressed` (bool): `yes` for button down, `no` for button up

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
# Left click
os.InputControl.mouse_click(os.InputControl.MOUSE_LEFT, yes)
os.sleep_ms(50)
os.InputControl.mouse_click(os.InputControl.MOUSE_LEFT, no)
```

---

#### `os.InputControl.mouse_scroll(dx, dy)`

Scrolls the mouse wheel.

**Parameters:**
- `dx` (int): Horizontal scroll amount (positive = right, negative = left)
- `dy` (int): Vertical scroll amount (positive = up, negative = down)

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
# Scroll up 3 units
os.InputControl.mouse_scroll(0, 3)

# Scroll down 2 units
os.InputControl.mouse_scroll(0, -2)
```

---

#### `os.InputControl.mouse_block(button)`

Blocks a specific mouse button from reaching applications.

**Parameters:**
- `button` (int): Mouse button constant

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
os.InputControl.mouse_block(os.InputControl.MOUSE_RIGHT)
```

---

#### `os.InputControl.mouse_unblock(button)`

Unblocks a previously blocked mouse button.

**Parameters:**
- `button` (int): Mouse button constant

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
os.InputControl.mouse_unblock(os.InputControl.MOUSE_RIGHT)
```

---

#### `os.InputControl.get_mouse_pos()`

Gets the current mouse cursor position.

**Returns:** `map` - Dictionary with keys `x` and `y`

**Example:**
```levy
pos <- os.InputControl.get_mouse_pos()
say("Mouse at: " + str(pos["x"]) + ", " + str(pos["y"]))
```

---

#### `os.InputControl.set_mouse_pos(x, y)`

Sets the mouse cursor position (alias for `mouse_move`).

**Parameters:**
- `x` (int): Target X coordinate
- `y` (int): Target Y coordinate

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
os.InputControl.set_mouse_pos(100, 200)
```

---

### Touch Functions

#### `os.InputControl.touch_capture()`

Starts capturing touch input events.

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
os.InputControl.touch_capture()
```

---

#### `os.InputControl.touch_release()`

Stops capturing touch input events.

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
os.InputControl.touch_release()
```

---

#### `os.InputControl.touch_send(x, y, pressure)`

Sends a touch event at specified coordinates.

**Parameters:**
- `x` (int): Touch X coordinate
- `y` (int): Touch Y coordinate
- `pressure` (int): Touch pressure (0-100)

**Returns:** `bool` - `yes` on success, `no` on failure

**Example:**
```levy
# Touch at (400, 300) with 80% pressure
os.InputControl.touch_send(400, 300, 80)
```

**Note:** Requires touch-enabled hardware and driver support.

---

### Utility Functions

#### `os.InputControl.clear_buffer()`

Clears all captured input event buffers.

**Returns:** `bool` - Always returns `yes`

**Example:**
```levy
os.InputControl.clear_buffer()
```

---

#### `os.InputControl.is_capturing()`

Checks which input devices are currently being captured.

**Returns:** `map` - Dictionary with boolean values for `keyboard`, `mouse`, and `touch`

**Example:**
```levy
status <- os.InputControl.is_capturing()
if status["keyboard"] {
    say("Keyboard is being captured")
}
if status["mouse"] {
    say("Mouse is being captured")
}
```

---

## Constants

### Mouse Button Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `os.InputControl.MOUSE_LEFT` | 0 | Left mouse button |
| `os.InputControl.MOUSE_RIGHT` | 1 | Right mouse button |
| `os.InputControl.MOUSE_MIDDLE` | 2 | Middle mouse button |

**Example:**
```levy
os.InputControl.mouse_click(os.InputControl.MOUSE_LEFT, yes)
```

---

## Data Structures

### Position Map

Returned by `get_mouse_pos()`:

```levy
{
    "x": <int>,  # X coordinate
    "y": <int>   # Y coordinate
}
```

### Capture Status Map

Returned by `is_capturing()`:

```levy
{
    "keyboard": <bool>,  # yes if keyboard is captured
    "mouse": <bool>,      # yes if mouse is captured
    "touch": <bool>       # yes if touch is captured
}
```

### Keyboard State Map

Returned by `keyboard_get_state()`:

```levy
{
    <virtual_key_code>: <bool>,  # yes if key is pressed
    ...
}
```

---

## Usage Examples

### Example 1: Mouse Automation

```levy
import os

# Move mouse in a circle
radius <- 100
center_x <- 500
center_y <- 500
steps <- 36

i <- 0
while i < steps {
    angle <- (i * 2.0 * 3.14159) / steps
    x <- center_x + int(radius * cos(angle))
    y <- center_y + int(radius * sin(angle))
    os.InputControl.mouse_move(x, y)
    os.sleep_ms(50)
    i <- i + 1
}
```

### Example 2: Automated Text Entry

```levy
import os

# Type a message
os.InputControl.keyboard_send_text("Hello from Levython!")

# Press Enter
os.InputControl.keyboard_send(13, yes)
os.sleep_ms(50)
os.InputControl.keyboard_send(13, no)
```

### Example 3: Input Filtering (Kiosk Mode)

```levy
import os

# Block potentially harmful keys
dangerous_keys <- [27, 91, 92, 115]  # Esc, Win, Win, F4

for key in dangerous_keys {
    os.InputControl.keyboard_block(key)
}

say("Kiosk mode active - dangerous keys blocked")

# Later: unblock
for key in dangerous_keys {
    os.InputControl.keyboard_unblock(key)
}
```

### Example 4: Custom Keyboard Layout

```levy
import os

# Remap keys for custom layout (Dvorak-style)
remaps <- [
    [65, 81],  # A -> Q
    [83, 79],  # S -> O
    [68, 69],  # D -> E
    [70, 85],  # F -> U
]

os.InputControl.keyboard_capture()

for remap in remaps {
    os.InputControl.keyboard_remap(remap[0], remap[1])
}

say("Custom keyboard layout active")
```

### Example 5: Mouse Position Tracking

```levy
import os

os.InputControl.mouse_capture()

# Track mouse for 10 seconds
start_time <- os.clock_ms()
last_x <- -1
last_y <- -1

while os.clock_ms() - start_time < 10000 {
    pos <- os.InputControl.get_mouse_pos()
    if pos["x"] != last_x or pos["y"] != last_y {
        say("Mouse at: " + str(pos["x"]) + ", " + str(pos["y"]))
        last_x <- pos["x"]
        last_y <- pos["y"]
    }
    os.sleep_ms(100)
}

os.InputControl.mouse_release()
```

---

## Security & Permissions

### Required Permissions

**Windows:**
- Administrator rights may be required for system-wide hooks
- Some antivirus software may flag input control as suspicious

**macOS:**
- Accessibility permissions required (System Preferences → Security & Privacy → Privacy → Accessibility)
- Input monitoring permissions required (System Preferences → Security & Privacy → Privacy → Input Monitoring)

**Linux:**
- X11 display access required
- Root/sudo may be needed for /dev/input access
- User must be in `input` group for device access

### Security Considerations

⚠️ **This module provides powerful system-level access. Use responsibly:**

- Input capture can record sensitive data (passwords, etc.)
- Input blocking can lock users out of their system
- Automated input can be used maliciously
- Always release captures when done
- Inform users when input is being monitored
- Handle permissions errors gracefully
- Test in isolated environments first

---

## Best Practices

### 1. Always Clean Up

```levy
# Start capture
os.InputControl.keyboard_capture()
os.InputControl.mouse_capture()

# ... do work ...

# Always release, even if errors occur
os.InputControl.keyboard_release()
os.InputControl.mouse_release()
os.InputControl.clear_buffer()
```

### 2. Use Delays for Natural Input

```levy
# Too fast - may be detected as synthetic
os.InputControl.keyboard_send(65, yes)
os.InputControl.keyboard_send(65, no)

# Better - add realistic delays
os.InputControl.keyboard_send(65, yes)
os.sleep_ms(50)
os.InputControl.keyboard_send(65, no)
os.sleep_ms(100)
```

### 3. Handle Platform Differences

```levy
platform <- os.platform()
if platform == "Windows" {
    # Windows-specific key codes
    alt_key <- 18
} else if platform == "Darwin" {
    # macOS-specific handling
    alt_key <- 58  # Option key
} else {
    # Linux
    alt_key <- 18
}
```

### 4. Check Capture Status

```levy
status <- os.InputControl.is_capturing()
if not status["keyboard"] {
    os.InputControl.keyboard_capture()
}
```

### 5. Minimize Blocked Keys

```levy
# Block only what's necessary
os.InputControl.keyboard_block(27)  # Block Esc only

# Remember to unblock
os.InputControl.keyboard_unblock(27)
```

---

## Troubleshooting

### Issue: Functions Return `no` (false)

**Possible causes:**
- Insufficient permissions
- Platform not supported
- Hardware not available (e.g., touch on non-touch device)
- Another application has exclusive input access

**Solutions:**
- Run with elevated privileges
- Check platform compatibility
- Verify hardware capabilities
- Close conflicting applications

### Issue: Input Events Not Captured

**Possible causes:**
- Capture not started
- Security software blocking
- Wayland session on Linux (use X11)

**Solutions:**
- Call appropriate `*_capture()` function
- Whitelist application in security software
- Use X11 session instead of Wayland

### Issue: Remapping Not Working

**Possible causes:**
- Capture not active
- Incorrect virtual key codes
- Platform-specific key code differences

**Solutions:**
- Start capture before remapping
- Verify key codes for your platform
- Test with simple key remappings first

---

## See Also

- [OS.Hook Module](OS_HOOK_MODULE.md) - System-level hooking APIs
- [OS Module](OS_MODULE.md) - General OS interaction functions  
- [Examples](../examples/) - Complete example programs
- [Build Documentation](BUILD.md) - Building Levython from source

---

**Module:** OS.InputControl  
**Version:** 1.0  
**Updated:** 2024  
**License:** MIT
