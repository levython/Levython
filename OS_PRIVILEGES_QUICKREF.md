# OS.PrivilegeEscalator Quick Reference

Quick reference guide for the Levython OS.PrivilegeEscalator module - privilege elevation and management.

## Quick Start

```levy
var os = import("os");
var priv = os.PrivilegeEscalator;

// Check if elevated
if (!priv.is_elevated()) {
    priv.request_elevation("Need admin access");
}

// Get user info
var user = priv.get_user_info();
print("Running as: " + user["username"]);
```

## Function Summary

### Privilege Checking (5 functions)

| Function | Returns | Description |
|----------|---------|-------------|
| `is_elevated()` | bool | Process is elevated |
| `is_admin()` |bool | User is administrator |
| `is_root()` | bool | Running as root/SYSTEM |
| `get_level()` | string | Get privilege level name |
| `can_elevate()` | bool | Can request elevation |

### Elevation Requests (2 functions)

| Function | Returns | Description |
|----------|---------|-------------|
| `request_elevation(reason?)` | bool | Request UAC/sudo elevation |
| `elevate_and_restart(args?)` | void | Restart script elevated |

### User Management (2 functions)

| Function | Returns | Description |
|----------|---------|-------------|
| `get_user_info()` | map | Current user details |
| `impersonate_user(username)` | bool | Impersonate another user |

### Privilege Management (3 functions)

| Function | Returns | Description |
|----------|---------|-------------|
| `check(name)` | bool | Check if privilege exists |
| `enable(name)` | bool | Enable a privilege |
| `drop()` | bool | Drop to normal user |

### Command Execution (1 function)

| Function | Returns | Description |
|----------|---------|-------------|
| `run_as_admin(cmd, args?)` | int | Execute command as admin |

### Token Information (1 function)

| Function | Returns | Description |
|----------|---------|-------------|
| `get_token_info()` | map | Security token details |

## Common Patterns

### Check and Request Elevation

```levy
if (!priv.is_elevated()) {
    if (priv.can_elevate()) {
        priv.request_elevation("Description of why");
    } else {
        print("ERROR: Cannot elevate");
    }
}
```

### Elevate and Restart Script

```levy
if (!priv.is_elevated()) {
    print("Restarting with elevation...");
    priv.elevate_and_restart();
    // Script exits and restarts elevated
}
// Continues here if already elevated
```

### Get Complete User Information

```levy
var user = priv.get_user_info();
print("User: " + user["username"]);
print("UID: " + user["user_id"]);
print("Admin: " + user["is_admin"]);
print("Elevated: " + user["is_elevated"]);
print("Level: " + user["privilege_level"]);
print("Home: " + user["home_directory"]);
```

### Enable Windows Privilege

```levy
// Enable specific privilege (Windows)
if (priv.enable("SeDebugPrivilege")) {
    print("Debug privilege enabled");
    // Can now debug other processes
}
```

### Run Command as Administrator

```levy
var exit_code = priv.run_as_admin("netsh", [
    "advfirewall", "firewall", "add", "rule",
    "name=MyApp", "dir=in", "action=allow"
]);

if (exit_code == 0) {
    print("Firewall rule added successfully");
}
```

### Security Best Practice Pattern

```levy
// Check capabilities
if (!priv.can_elevate()) {
    print("ERROR: Admin access not available");
    return 1;
}

// Request if needed
if (!priv.is_elevated()) {
    if (!priv.request_elevation("System configuration required")) {
        return 1;  // User declined
    }
}

// Perform privileged operations
perform_admin_tasks();

// Drop immediately after
priv.drop_privileges();
```

### Check Token Details (Windows)

```levy
var token = priv.get_token_info();
print("Elevation Type: " + token["elevation_type"]);
print("Integrity: " + token["integrity_name"]);

// Show all privileges
for (var p in token["privileges"]) {
    print(p["name"] + ": " + p["enabled"]);
}
```

### Drop Privileges After Admin Work

```levy
if (priv.is_elevated()) {
    // Do admin work
    modify_system_settings();
    
    // Drop back to normal
    if (priv.drop()) {
        print("Dropped to normal privileges");
    }
}
```

## Privilege Levels

| Level | Description |
|-------|-------------|
| `STANDARD_USER` | Normal user privileges |
| `ELEVATED_USER` | UAC elevated (Windows) |
| `ADMINISTRATOR` | Full admin/root |
| `SYSTEM` | Highest (Windows SYSTEM) |
| `UNKNOWN` | Cannot determine |

## Common Windows Privileges

| Privilege Name | Description |
|----------------|-------------|
| `SeDebugPrivilege` | Debug other processes |
| `SeShutdownPrivilege` | Shutdown/reboot system |
| `SeBackupPrivilege` | Backup files bypass ACLs |
| `SeRestorePrivilege` | Restore files bypass ACLs |
| `SeTakeOwnershipPrivilege` | Take ownership of files |
| `SeSecurityPrivilege` | Manage audit logs |
| `SeSystemtimePrivilege` | Change system time |
| `SeLoadDriverPrivilege` | Load device drivers |

## Platform Differences

### Windows

```levy
// UAC elevation (interactive prompt)
priv.request_elevation();

// Check specific privilege
priv.check("SeDebugPrivilege");

// Enable privilege
priv.enable_privilege("SeBackupPrivilege");

// Get token integrity level
var token = priv.get_token_info();
print(token["integrity_name"]);  // LOW/MEDIUM/HIGH/SYSTEM
```

### Unix/Linux/macOS

```levy
// Requires sudo (no interactive prompt possible)
// User must run: sudo levython script.levy

// Check if root
if (priv.is_root()) {
    print("Running as root");
}

// Check UIDs
var token = priv.get_token_info();
print("Real UID: " + token["real_uid"]);
print("Effective UID: " + token["effective_uid"]);

// Run with sudo
priv.run_as_admin("systemctl", ["restart", "nginx"]);
```

## Error Handling

```levy
try {
    // Request elevation
    if (!priv.request_elevation("Config change required")) {
        print("ERROR: Elevation denied");
        return 1;
    }
    
    // Enable privilege
    if (!priv.enable_privilege("SeBackupPrivilege")) {
        print("WARNING: Could not enable backup privilege");
    }
    
    // Run admin command
    var result = priv.run_as_admin("icacls", ["C:\\", "/grant", "Users:F"]);
    if (result != 0) {
        print("ERROR: Command failed with exit code " + result);
    }
    
} catch (e) {
    print("ERROR: " + e);
    return 1;
}
```

## User Information Map

```levy
var user = priv.get_user_info();
```

**Keys:**
- `username` - String, current user name
- `full_name` - String, full/display name
- `user_id` - Integer, UID (Unix) or RID (Windows)
- `group_id` - Integer, primary GID
- `is_admin` - Boolean, has admin capabilities
- `is_elevated` - Boolean, currently elevated
- `privilege_level` - String, privilege level name
- `home_directory` - String, home directory path
- `groups` - List of strings, group memberships

## Token Information Map

```levy
var token = priv.get_token_info();
```

**Windows Keys:**
- `is_elevated` - Boolean
- `elevation_type` - "DEFAULT" | "FULL" | "LIMITED"
- `integrity_level` - Integer
- `integrity_name` - "LOW" | "MEDIUM" | "HIGH" | "SYSTEM"
- `privileges` - List of maps with `name` and `enabled` keys

**Unix Keys:**
- `real_uid` - Integer
- `effective_uid` - Integer
- `real_gid` - Integer
- `effective_gid` - Integer
- `is_elevated` - Boolean
- `is_setuid` - Boolean

## Security Checklist

- [ ] Check `can_elevate()` before requesting
- [ ] Provide clear elevation reason to users
- [ ] Validate all user inputs before elevated operations
- [ ] Use `drop_privileges()` when admin access no longer needed
- [ ] Never hardcode credentials
- [ ] Log all elevation attempts and privileged operations
- [ ] Sanitize inputs to `run_as_admin()`
- [ ] Handle elevation denials gracefully
- [ ] Test with standard user accounts
- [ ] Document why elevation is required

## Complete Example

```levy
var os = import("os");
var priv = os.PrivilegeEscalator;

function main() {
    // 1. Check current status
    print("Current level: " + priv.get_privilege_level());
    
    // 2. Verify elevation capability
    if (!priv.can_elevate()) {
        print("ERROR: Cannot elevate privileges");
        return 1;
    }
    
    // 3. Request if needed
    if (!priv.is_elevated()) {
        print("Requesting elevation...");
        if (!priv.request_elevation("System config update")) {
            print("User declined elevation");
            return 1;
        }
    }
    
    // 4. Enable specific privileges (Windows)
    if (os.name() == "Windows") {
        priv.enable_privilege("SeBackupPrivilege");
    }
    
    // 5. Perform privileged operations
    print("Performing admin tasks...");
    var result = priv.run_as_admin("your-admin-command", ["args"]);
    
    if (result != 0) {
        print("ERROR: Command failed");
        return result;
    }
    
    // 6. Drop privileges
    print("Dropping privileges...");
    priv.drop_privileges();
    
    print("Complete!");
    return 0;
}

main();
```

## Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| `request_elevation()` returns false | User declined UAC or not admin group member |
| Cannot enable privilege | Privilege not held or insufficient access |
| `run_as_admin()` fails | Check command path and UAC settings |
| Unix elevation not working | Must run script with `sudo` |
| Token info empty | Process token not available |
| Impersonation fails | Need root/SYSTEM and valid username |

## See Also

- [Complete Module Documentation](OS_PRIVILEGEESCALATOR_MODULE.md)
- [Implementation Details](OS_PRIVILEGEESCALATOR_IMPLEMENTATION.md)
- [OS Module Main Documentation](OS_MODULE.md)

---

**Quick Reference:** OS.PrivilegeEscalator v1.0  
**14 Functions** | **Cross-Platform** | **Security-Critical**
