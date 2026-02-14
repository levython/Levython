# OS.InputControl Quick Reference

Fast reference for the OS.InputControl module in Levython.

---

## Import

```levy
import os
```

---

## Keyboard Functions

```levy
# Capture/Release
os.InputControl.keyboard_capture()        # -> bool
os.InputControl.keyboard_release()        # -> bool

# Send Events
os.InputControl.keyboard_send(vk, pressed) # vk=int, pressed=bool -> bool
os.InputControl.keyboard_send_text(text)   # text=string -> bool

# Blocking
os.InputControl.keyboard_block(vk)        # vk=int -> bool
os.InputControl.keyboard_unblock(vk)      # vk=int -> bool

# Remapping
os.InputControl.keyboard_remap(from, to)  # from=int, to=int (0=remove) -> bool

# State
os.InputControl.keyboard_get_state()      # -> map{vk: bool}
```

**Common Virtual Keys:**
- 8=Backspace, 9=Tab, 13=Enter, 27=Esc, 32=Space
- 16=Shift, 17=Ctrl, 18=Alt
- 65-90=A-Z, 48-57=0-9
- 112-123=F1-F12

---

## Mouse Functions

```levy
# Capture/Release
os.InputControl.mouse_capture()           # -> bool
os.InputControl.mouse_release()           # -> bool

# Movement
os.InputControl.mouse_move(x, y)          # x=int, y=int -> bool
os.InputControl.set_mouse_pos(x, y)       # alias for mouse_move

# Position
pos <- os.InputControl.get_mouse_pos()    # -> map{"x": int, "y": int}

# Clicks
os.InputControl.mouse_click(btn, pressed) # btn=0/1/2, pressed=bool -> bool

# Scrolling
os.InputControl.mouse_scroll(dx, dy)      # dx=int, dy=int -> bool

# Blocking
os.InputControl.mouse_block(button)       # button=0/1/2 -> bool
os.InputControl.mouse_unblock(button)     # button=0/1/2 -> bool
```

**Mouse Button Constants:**
```levy
os.InputControl.MOUSE_LEFT    # 0
os.InputControl.MOUSE_RIGHT   # 1
os.InputControl.MOUSE_MIDDLE  # 2
```

---

## Touch Functions

```levy
# Capture/Release
os.InputControl.touch_capture()           # -> bool
os.InputControl.touch_release()           # -> bool

# Send Touch
os.InputControl.touch_send(x, y, pressure) # x=int, y=int, pressure=0-100 -> bool
```

---

## Utility Functions

```levy
# Clear Buffers
os.InputControl.clear_buffer()            # -> bool

# Check Status
status <- os.InputControl.is_capturing()  # -> map{"keyboard": bool, "mouse": bool, "touch": bool}
```

---

## Quick Examples

### Mouse Automation
```levy
# Move and click
os.InputControl.mouse_move(100, 200)
os.InputControl.mouse_click(os.InputControl.MOUSE_LEFT, yes)
os.sleep_ms(50)
os.InputControl.mouse_click(os.InputControl.MOUSE_LEFT, no)
```

### Type Text
```levy
os.InputControl.type_text("Hello, World!")
```

### Block Keys
```levy
os.InputControl.keyboard_block(27)  # Block Esc
# ... later ...
os.InputControl.keyboard_unblock(27)
```

### Remap Keys
```levy
os.InputControl.keyboard_remap(20, 17)  # Caps Lock -> Ctrl
# Remove: keyboard_remap(20, 0)
```

### Get Mouse Position
```levy
pos <- os.InputControl.get_mouse_pos()
x <- pos["x"]
y <- pos["y"]
```

### Check Capture Status
```levy
status <- os.InputControl.is_capturing()
if status["keyboard"] {
    say("Keyboard is being captured")
}
```

---

## Best Practices

✅ **DO:**
- Always release captures when done
- Add delays between events (50-100ms)
- Check is_capturing() before operations
- Clear buffers periodically
- Handle platform differences

❌ **DON'T:**
- Forget to release captures
- Send events too rapidly
- Block critical system keys
- Ignore return values
- Assume synchronous behavior

---

## Common Patterns

### Safe Capture
```levy
os.InputControl.keyboard_capture()
# ... do work ...
os.InputControl.keyboard_release()
os.InputControl.clear_buffer()
```

### Natural Typing
```levy
text <- "Hello"
for char in text {
    os.InputControl.keyboard_send_text(char)
    os.sleep_ms(80 + random(40))  # 80-120ms delay
}
```

### Mouse Tracking
```levy
os.InputControl.mouse_capture()
last_pos <- os.InputControl.get_mouse_pos()

while tracking {
    pos <- os.InputControl.get_mouse_pos()
    if pos["x"] != last_pos["x"] or pos["y"] != last_pos["y"] {
        handle_move(pos)
        last_pos <- pos
    }
    os.sleep_ms(16)  # ~60 FPS
}

os.InputControl.mouse_release()
```

---

## Platform Support

| Feature | Windows | macOS | Linux |
|---------|---------|-------|-------|
| Keyboard | ✅ | ✅ | ✅ |
| Mouse | ✅ | ✅ | ✅ |
| Touch | ✅ (Win8+) | ⚠️ (Limited) | ⚠️ (Limited) |
| Capture | ✅ | ✅ | ✅ (X11) |
| Blocking | ✅ | ✅ | ✅ |
| Remapping | ✅ | ✅ | ✅ |

---

## Required Permissions

**Windows:** Admin (for hooks) or Standard (for SendInput)  
**macOS:** Accessibility + Input Monitoring  
**Linux:** X11 access (auto), root for /dev/input

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Functions return `no` | Check permissions |
| Events not captured | Call *_capture() first |
| Remapping not working | Start capture before remap |
| Mouse jumps erratically | Check coordinate scaling |
| Touch not working | Verify hardware support |

---

## See More

- Full API: [OS_INPUTCONTROL_MODULE.md](OS_INPUTCONTROL_MODULE.md)
- Implementation: [OS_INPUTCONTROL_IMPLEMENTATION.md](OS_INPUTCONTROL_IMPLEMENTATION.md)
- Examples: [examples/29_os_inputcontrol_demo.levy](examples/29_os_inputcontrol_demo.levy)

---

**Quick Ref Version:** 1.0  
**Last Updated:** 2024
