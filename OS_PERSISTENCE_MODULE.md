# OS.PersistenceHandler Module Documentation

## Overview

The **OS.PersistenceHandler** module provides comprehensive cross-platform capabilities for managing system persistence features in Levython. This module enables scripts to configure auto-start entries, install and manage system services, and schedule tasks to run across reboots or user sessions.

**Platform Support**: Windows, Linux, macOS (limited)

---

## Module Access

```levython
var os = import("os");
var persist = os.PersistenceHandler;
```

---

## Functions

### Auto-Start Management

#### `add_autostart(name, command, location?)`

Add a program to auto-start on system boot or user login.

**Parameters**:
- `name` (string): Name of the autostart entry
- `command` (string): Full command or path to executable
- `location` (string, optional): `"USER"` or `"SYSTEM"` (default: `"USER"`)

**Returns**: `bool` - `true` if successful

**Platform Implementation**:
- **Windows**: Registry key in `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` (USER) or `HKLM\Software\Microsoft\Windows\CurrentVersion\Run` (SYSTEM)
- **Linux**: `.desktop` file in `~/.config/autostart` (USER) or `/etc/xdg/autostart` (SYSTEM)

**Permissions**:
- USER: No special permissions required
- SYSTEM: Administrator/root privileges required

**Examples**:
```levython
// Add user-level autostart (no admin required)
persist.add_autostart(
    "MyApp",
    "C:\\Program Files\\MyApp\\app.exe",
    "USER"
);

// Add system-level autostart (requires admin)
persist.add_autostart(
    "SystemMonitor",
    "/usr/bin/monitor.sh",
    "SYSTEM"
);

// Auto-start Levython script
var script_path = os.abspath("my_script.levy");
var levython_path = os.which("levython");
persist.add_autostart(
    "MyLevyScript",
    levython_path + " " + script_path,
    "USER"
);
```

---

#### `remove_autostart(name, location?)`

Remove a program from auto-start.

**Parameters**:
- `name` (string): Name of the autostart entry to remove
- `location` (string, optional): `"USER"` or `"SYSTEM"` (default: `"USER"`)

**Returns**: `bool` - `true` if entry was found and removed

**Examples**:
```levython
// Remove user-level autostart
var removed = persist.remove_autostart("MyApp", "USER");
if (removed) {
    print("Autostart entry removed");
} else {
    print("Entry not found");
}

// Remove system-level autostart (requires admin)
persist.remove_autostart("SystemMonitor", "SYSTEM");
```

---

#### `list_autostart(location?)`

List all autostart entries for the specified location.

**Parameters**:
- `location` (string, optional): `"USER"` or `"SYSTEM"` (default: `"USER"`)

**Returns**: `list` - List of maps with entry information

**Entry Structure**:
```levython
{
    "name": "MyApp",
    "command": "C:\\Program Files\\MyApp\\app.exe",
    "location": "USER",
    "enabled": true
}
```

**Examples**:
```levython
// List user autostart entries
var user_entries = persist.list_autostart("USER");

print("User autostart entries: " + user_entries.length);
for (var entry in user_entries) {
    print("  " + entry["name"] + ": " + entry["command"]);
}

// List system autostart entries (may require admin)
var system_entries = persist.list_autostart("SYSTEM");
```

---

### Service Management

#### `install_service(name, display_name, description, command, auto_start?)`

Install a program as a system service (Windows Service or systemd service).

**Parameters**:
- `name` (string): Service name (no spaces, lowercase recommended for Linux)
- `display_name` (string): Human-readable display name
- `description` (string): Service description
- `command` (string): Full path to executable or script
- `auto_start` (bool, optional): Start automatically on boot (default: `false`)

**Returns**: `bool` - `true` if service was installed successfully

**Platform Implementation**:
- **Windows**: Creates Windows Service via Service Control Manager
- **Linux**: Creates systemd unit file in `/etc/systemd/system/`

**Permissions**: Administrator/root privileges required

**Service Configuration**:
- **Windows**: SERVICE_WIN32_OWN_PROCESS, SERVICE_ERROR_NORMAL
- **Linux**: Type=simple, Restart=on-failure, RestartSec=5s

**Examples**:
```levython
// Install service with manual start
var success = persist.install_service(
    "myapp-service",
    "My Application Service",
    "Background service for My Application",
    "C:\\Program Files\\MyApp\\service.exe",
    false  // Manual start
);

if (success) {
    print("Service installed successfully");
}

// Install auto-starting service (Linux)
persist.install_service(
    "levymon",
    "Levython Monitor",
    "System monitoring service written in Levython",
    "/usr/local/bin/levython /opt/myapp/monitor.levy",
    true  // Auto-start on boot
);
```

**Notes**:
- Service executable must be a valid Windows/Linux service (respond to SCM/systemd signals)
- For Levython scripts, consider wrapping in a proper service executable
- Windows services require specific entry points (ServiceMain function)

---

#### `uninstall_service(name)`

Remove a system service.

**Parameters**:
- `name` (string): Service name

**Returns**: `bool` - `true` if service was removed

**Permissions**: Administrator/root privileges required

**Examples**:
```levython
// Uninstall service
var removed = persist.uninstall_service("myapp-service");

if (removed) {
    print("Service uninstalled");
} else {
    print("Service not found or removal failed");
}
```

**Notes**:
- Service is stopped before removal (if running)
- Linux: Also runs `systemctl disable` to remove auto-start

---

#### `start_service(name)`

Start a system service.

**Parameters**:
- `name` (string): Service name

**Returns**: `bool` - `true` if service started successfully

**Permissions**: Administrator/root privileges typically required

**Examples**:
```levython
// Start service
try {
    persist.start_service("myapp-service");
    print("Service started");
} catch (e) {
    print("Failed to start service: " + e);
}
```

**Notes**:
- Returns `true` if service is already running
- May throw exception if service doesn't exist or start fails

---

#### `stop_service(name)`

Stop a running system service.

**Parameters**:
- `name` (string): Service name

**Returns**: `bool` - `true` if service stopped successfully

**Permissions**: Administrator/root privileges typically required

**Examples**:
```levython
// Stop service
if (persist.stop_service("myapp-service")) {
    print("Service stopped");
} else {
    print("Failed to stop service");
}
```

---

#### `restart_service(name)`

Restart a system service (stop then start).

**Parameters**:
- `name` (string): Service name

**Returns**: `bool` - `true` if service restarted successfully

**Permissions**: Administrator/root privileges typically required

**Platform Implementation**:
- **Windows**: Explicit stop + start with 1 second delay
- **Linux**: Uses `systemctl restart` command

**Examples**:
```levython
// Restart service to apply configuration changes
var restarted = persist.restart_service("myapp-service");

if (restarted) {
    print("Service restarted successfully");
}
```

---

#### `get_service_status(name)`

Get the current status of a system service.

**Parameters**:
- `name` (string): Service name

**Returns**: `map` - Service status information

**Status Structure**:
```levython
{
    "name": "myapp-service",
    "status": "RUNNING",  // STOPPED, STARTING, RUNNING, STOPPING, PAUSED, UNKNOWN
    "pid": 12345,         // Process ID (Windows only)
    "error": "..."        // Error message if status query failed
}
```

**Examples**:
```levython
// Check service status
var status = persist.get_service_status("myapp-service");

print("Service: " + status["name"]);
print("Status: " + status["status"]);

if (status["pid"]) {
    print("PID: " + status["pid"]);
}

if (status["error"]) {
    print("Error: " + status["error"]);
}

// Wait for service to start
function wait_for_service(name, timeout_seconds) {
    var start_time = os.time();
    
    while (os.time() - start_time < timeout_seconds) {
        var status = persist.get_service_status(name);
        
        if (status["status"] == "RUNNING") {
            return true;
        }
        
        os.sleep(0.5);
    }
    
    return false;
}

persist.start_service("myapp-service");

if (wait_for_service("myapp-service", 30)) {
    print("Service is now running");
} else {
    print("Service failed to start within timeout");
}
```

---

### Scheduled Task Management

#### `add_scheduled_task(name, command, schedule, schedule_time?)`

Add a scheduled task to run periodically or on specific events.

**Parameters**:
- `name` (string): Task name
- `command` (string): Command or script to execute
- `schedule` (string): Schedule type
  - `"ONCE"` - Run once (Windows only)
  - `"DAILY"` - Run every day
  - `"WEEKLY"` - Run weekly
  - `"MONTHLY"` - Run monthly (Windows only)
  - `"ON_BOOT"` - Run on system boot
  - `"ON_LOGON"` - Run on user logon
  - `"ON_IDLE"` - Run when system is idle (Windows only)
- `schedule_time` (string, optional): Time in HH:MM format (default: "00:00")

**Returns**: `bool` - `true` if task was scheduled successfully

**Platform Implementation**:
- **Windows**: Uses Task Scheduler (`schtasks` command)
- **Linux**: Uses cron (`crontab` command) for DAILY/WEEKLY

**Permissions**:
- User-level tasks: No special permissions
- System-level tasks: Administrator/root privileges

**Examples**:
```levython
// Daily task at 3:00 AM
persist.add_scheduled_task(
    "DailyBackup",
    "C:\\Scripts\\backup.bat",
    "DAILY",
    "03:00"
);

// Weekly task (Sunday at midnight)
persist.add_scheduled_task(
    "WeeklyReport",
    "/usr/local/bin/generate_report.sh",
    "WEEKLY",
    "00:00"
);

// Run on system boot
persist.add_scheduled_task(
    "StartupCheck",
    "powershell.exe -File C:\\Scripts\\startup_check.ps1",
    "ON_BOOT"
);

// Run on user logon
persist.add_scheduled_task(
    "UserSync",
    "python /home/user/sync.py",
    "ON_LOGON"
);
```

**Linux Cron Notes**:
- DAILY: Runs at specified time every day (minute hour * * *)
- WEEKLY: Runs at specified time every Sunday (minute hour * * 0)
- ON_BOOT and ON_LOGON require systemd timers (not yet implemented)

**Windows Notes**:
- Uses `/f` flag to force create (overwrites existing task)
- ONCE tasks require a specific date (defaults to current date + time)

---

#### `remove_scheduled_task(name)`

Remove a scheduled task.

**Parameters**:
- `name` (string): Task name

**Returns**: `bool` - `true` if task was found and removed

**Examples**:
```levython
// Remove scheduled task
var removed = persist.remove_scheduled_task("DailyBackup");

if (removed) {
    print("Scheduled task removed");
} else {
    print("Task not found");
}
```

**Platform Implementation**:
- **Windows**: Uses `schtasks /delete` command
- **Linux**: Removes matching cron entry from crontab

---

## Complete Usage Examples

### Example 1: Auto-Start Application on Login

```levython
var os = import("os");
var persist = os.PersistenceHandler;

// Get path to Levython script
var script_path = os.abspath("my_background_app.levy");
var levython_exe = os.which("levython");

if (!levython_exe) {
    print("Error: levython not found in PATH");
    return;
}

var command = levython_exe + " \"" + script_path + "\"";

try {
    var success = persist.add_autostart(
        "MyBackgroundApp",
        command,
        "USER"
    );
    
    if (success) {
        print("Application added to autostart");
        print("It will run automatically on next login");
    }
} catch (e) {
    print("Failed to add autostart: " + e);
}

// Verify it was added
var entries = persist.list_autostart("USER");
var found = false;

for (var entry in entries) {
    if (entry["name"] == "MyBackgroundApp") {
        found = true;
        print("");
        print("Verified autostart entry:");
        print("  Name: " + entry["name"]);
        print("  Command: " + entry["command"]);
        print("  Enabled: " + entry["enabled"]);
        break;
    }
}

if (!found) {
    print("Warning: Entry not found in autostart list");
}
```

### Example 2: Install and Manage System Service

```levython
var os = import("os");
var persist = os.PersistenceHandler;

var service_name = "myapp-monitor";

// Check if running as administrator
if (!os.PrivilegeEscalator.is_elevated()) {
    print("This operation requires administrator privileges");
    
    // Attempt elevation
    var elevated = os.PrivilegeEscalator.request_elevation();
    if (!elevated) {
        print("Failed to elevate privileges");
        return;
    }
}

print("Installing service...");

try {
    // Install service
    var installed = persist.install_service(
        service_name,
        "My Application Monitor",
        "Monitors system resources for My Application",
        "C:\\Program Files\\MyApp\\monitor.exe",
        true  // Auto-start on boot
    );
    
    if (installed) {
        print("Service installed successfully");
    }
    
    // Start service immediately
    print("Starting service...");
    persist.start_service(service_name);
    
    // Wait for service to start
    os.sleep(2);
    
    // Check status
    var status = persist.get_service_status(service_name);
    print("Service status: " + status["status"]);
    
    if (status["status"] == "RUNNING") {
        print("Service is running with PID: " + status["pid"]);
    } else {
        print("Warning: Service not running");
    }
    
} catch (e) {
    print("Error: " + e);
}
```

### Example 3: Scheduled Daily Maintenance Task

```levython
var os = import("os");
var persist = os.PersistenceHandler;

// Create a maintenance script path
var maintenance_script = "C:\\Scripts\\daily_maintenance.bat";

// Schedule to run every day at 2:00 AM
try {
    var scheduled = persist.add_scheduled_task(
        "DailyMaintenance",
        maintenance_script,
        "DAILY",
        "02:00"
    );
    
    if (scheduled) {
        print("Maintenance task scheduled successfully");
        print("Will run daily at 2:00 AM");
    }
} catch (e) {
    print("Failed to schedule task: " + e);
}
```

### Example 4: Cross-Platform Background Worker

```levython
var os = import("os");
var persist = os.PersistenceHandler;

var worker_name = "data-sync-worker";
var worker_script = os.abspath("data_sync_worker.levy");

if (os.name() == "Windows") {
    // Windows: Use scheduled task to run on logon
    var levython_exe = os.which("levython.exe");
    var command = "\"" + levython_exe + "\" \"" + worker_script + "\"";
    
    persist.add_scheduled_task(
        worker_name,
        command,
        "ON_LOGON"
    );
    
    print("Worker scheduled to run on Windows logon");
    
} else {
    // Linux: Use autostart
    var levython_exe = os.which("levython");
    var command = levython_exe + " \"" + worker_script + "\"";
    
    persist.add_autostart(
        worker_name,
        command,
        "USER"
    );
    
    print("Worker added to Linux autostart");
}

print("Background worker persistence configured");
```

---

## Platform-Specific Notes

### Windows

#### Registry Locations
- **User Autostart**: `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run`
- **System Autostart**: `HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run`

#### Service Requirements
- Services must respond to Service Control Manager signals
- Service executable needs specific entry points (ServiceMain, ServiceCtrlHandler)
- For Levython scripts, consider using a service wrapper like NSSM (Non-Sucking Service Manager)

#### Task Scheduler
- Uses `schtasks` command-line utility
- Full COM API support (ITaskService) planned for future versions
- Tasks created with `/f` flag (force, overwrites existing)

#### Permissions
- User-level operations: Standard user
- System-level operations: Administrator privileges required
- Service operations: Always require administrator

### Linux

#### Autostart Locations
- **User**: `~/.config/autostart/` - XDG autostart directory
- **System**: `/etc/xdg/autostart/` - System-wide autostart

#### Desktop Entry Format
```ini
[Desktop Entry]
Type=Application
Name=MyApp
Exec=/usr/bin/myapp
X-GNOME-Autostart-enabled=true
Hidden=false
NoDisplay=false
```

#### Systemd Services
- Unit files: `/etc/systemd/system/`
- Service configuration: Type=simple, Restart=on-failure
- Commands: `systemctl start/stop/restart/enable/disable`

#### Cron
- User crontab: `crontab -e`
- System cron: `/etc/cron.d/`, `/etc/crontab`
- Format: `minute hour day month day_of_week command`

#### Permissions
- User-level: Standard user
- System-level: root privileges (sudo)

### macOS

#### Limited Support
- Autostart: Uses similar XDG directories (untested)
- Services: launchd agents/daemons not yet implemented
- Scheduled Tasks: launchd timers not yet implemented

#### Future Plans
- Support for launchd plist files
- User agents: `~/Library/LaunchAgents/`
- System daemons: `/Library/LaunchDaemons/`

---

## Error Handling

### Common Errors

#### Insufficient Permissions
```levython
try {
    persist.add_autostart("MyApp", "C:\\MyApp\\app.exe", "SYSTEM");
} catch (e) {
    if (e.find("privileges") != -1 || e.find("access") != -1) {
        print("Administrator privileges required");
        
        // Try elevation
        if (os.PrivilegeEscalator.request_elevation()) {
            // Retry operation
            persist.add_autostart("MyApp", "C:\\MyApp\\app.exe", "SYSTEM");
        }
    }
}
```

#### Service Already Exists
```levython
try {
    persist.install_service("myservice", "My Service", "Description", 
                           "C:\\service.exe", true);
} catch (e) {
    if (e.find("already exists") != -1) {
        print("Service exists, uninstalling first...");
        persist.uninstall_service("myservice");
        
        // Retry
        persist.install_service("myservice", "My Service", "Description",
                               "C:\\service.exe", true);
    }
}
```

#### Invalid Path
```levython
var command = "C:\\Program Files\\MyApp\\app.exe";

// Verify executable exists
if (!os.exists(command)) {
    print("Error: Executable not found: " + command);
    return;
}

persist.add_autostart("MyApp", command, "USER");
```

---

## Best Practices

### 1. Check Permissions Before System Operations

```levython
if (location == "SYSTEM" && !os.PrivilegeEscalator.is_elevated()) {
    print("System-level operation requires administrator privileges");
    
    if (os.PrivilegeEscalator.request_elevation()) {
        // Proceed with operation
    } else {
        print("Failed to obtain required privileges");
        return;
    }
}
```

### 2. Use Absolute Paths

```levython
// Convert relative paths to absolute
var script_path = os.abspath("./my_script.levy");
var levython_path = os.which("levython");

var command = levython_path + " \"" + script_path + "\"";
```

### 3. Verify Installation

```levython
// After adding autostart, verify
persist.add_autostart("MyApp", command, "USER");

var entries = persist.list_autostart("USER");
var found = entries.find(function(e) { return e["name"] == "MyApp"; });

if (found) {
    print("Verified: Autostart entry created");
} else {
    print("Warning: Entry not found after creation");
}
```

### 4. Clean Up on Uninstall

```levython
function uninstall_application() {
    print("Removing persistence...");
    
    // Remove autostart entries
    persist.remove_autostart("MyApp", "USER");
    persist.remove_autostart("MyApp", "SYSTEM");
    
    // Remove scheduled tasks
    persist.remove_scheduled_task("MyAppDailyTask");
    
    // Uninstall service
    try {
        persist.stop_service("myapp-service");
        persist.uninstall_service("myapp-service");
    } catch (e) {
        // Service may not exist
    }
    
    print("Persistence removed");
}
```

### 5. Handle Platform Differences

```levython
function setup_persistence() {
    var command = get_application_command();
    
    if (os.name() == "Windows") {
        // Windows: Use scheduled task for advanced control
        persist.add_scheduled_task("MyApp", command, "ON_LOGON");
    } else {
        // Linux/Unix: Use autostart
        persist.add_autostart("MyApp", command, "USER");
    }
}
```

---

## Security Considerations

### 1. Command Injection

Always validate and sanitize commands, especially from user input:

```levython
// BAD: User input directly in command
var user_path = get_user_input();
persist.add_autostart("MyApp", user_path, "USER");  // Vulnerable!

// GOOD: Validate path exists and is safe
var user_path = get_user_input();

if (!os.exists(user_path)) {
    print("Error: Path does not exist");
    return;
}

if (!user_path.ends_with(".exe") && !user_path.ends_with(".levy")) {
    print("Error: Invalid file type");
    return;
}

persist.add_autostart("MyApp", "\"" + user_path + "\"", "USER");
```

### 2. Privilege Escalation

Be cautious with system-level persistence:

```levython
// Only use SYSTEM location when absolutely necessary
// Prefer USER location for user-specific applications

// Document why system-level is needed
if (requires_system_level()) {
    if (!os.PrivilegeEscalator.is_elevated()) {
        print("System-level persistence requires administrator approval");
        
        if (!os.PrivilegeEscalator.request_elevation()) {
            print("Cannot proceed without elevation");
            return;
        }
    }
    
    persist.add_autostart("SystemMonitor", command, "SYSTEM");
}
```

### 3. Service Security

Services run with elevated privileges - ensure executables are secure:

```levython
// Verify service executable integrity
var service_exe = "C:\\Program Files\\MyApp\\service.exe";

// Check file exists
if (!os.exists(service_exe)) {
    print("Error: Service executable not found");
    return;
}

// Check file is in a protected location (Program Files)
if (!service_exe.starts_with("C:\\Program Files")) {
    print("Warning: Service executable not in protected location");
}

// Install service
persist.install_service("myservice", "My Service", "Description",
                       service_exe, true);
```

---

## Troubleshooting

### Autostart Not Working

**Symptoms**: Entry added but application doesn't start on login/boot

**Solutions**:
1. Verify entry exists: `persist.list_autostart("USER")`
2. Check command path is absolute and valid
3. Test command manually: `os.system(command)`
4. Check application logs for startup errors
5. Windows: Check Event Viewer for startup errors
6. Linux: Check `~/.xsession-errors` or journal logs

### Service Won't Start

**Symptoms**: Service installs but fails to start

**Solutions**:
1. Check service status: `persist.get_service_status("myservice")`
2. Verify executable is a proper service (responds to SCM/systemd)
3. Windows: Check Event Viewer → Windows Logs → Application
4. Linux: Check journal logs: `journalctl -u myservice`
5. Verify executable permissions: `chmod +x /path/to/service`

### Scheduled Task Not Running

**Symptoms**: Task scheduled but doesn't execute

**Solutions**:
1. Verify task exists:
   - Windows: `schtasks /query /tn MyTask`
   - Linux: `crontab -l`
2. Check task schedule is correct
3. Verify command path and permissions
4. Windows: Check Task Scheduler history
5. Linux: Check mail for cron output (`/var/mail/username`)

### Permission Denied Errors

**Symptoms**: Operations fail with access denied errors

**Solutions**:
1. Check if operation requires admin: `os.PrivilegeEscalator.is_elevated()`
2. Request elevation: `os.PrivilegeEscalator.request_elevation()`
3. Run Levython as administrator (Windows) or with sudo (Linux)
4. Check file permissions on target directories
5. Windows: Check UAC settings
6. Linux: Verify user is in correct groups (e.g., sudo, wheel)

---

## See Also

- [OS.PersistenceHandler Quick Reference](OS_PERSISTENCEHANDLER_QUICKREF.md)
- [OS.PersistenceHandler Implementation Details](OS_PERSISTENCEHANDLER_IMPLEMENTATION.md)
- [OS.PrivilegeEscalator Module](OS_PRIVILEGEESCALATOR_MODULE.md) - For elevation management
- [OS Module Documentation](OS_MODULE.md) - Complete OS module reference
