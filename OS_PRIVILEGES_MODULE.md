# OS.PrivilegeEscalator Module Documentation

## Overview

The `OS.PrivilegeEscalator` submodule provides comprehensive privilege elevation capabilities for Levython scripts. It enables scripts to check current privilege levels, request administrative/root access, manage user privileges, and execute commands with elevated permissions across Windows, macOS, and Linux platforms.

## Table of Contents

- [Module Import](#module-import)
- [Privilege Checking](#privilege-checking)
- [Elevation Requests](#elevation-requests)
- [User Management](#user-management)
- [Privilege Management](#privilege-management)
- [Command Execution](#command-execution)
- [Token Information](#token-information)
- [Platform-Specific Behavior](#platform-specific-behavior)
- [Security Considerations](#security-considerations)
- [Complete Function Reference](#complete-function-reference)

## Module Import

```levy
var os = import("os");
var priv = os.PrivilegeEscalator;
```

## Privilege Checking

### is_elevated()

Check if the current process is running with elevated privileges.

**Syntax:**
```levy
var elevated = priv.is_elevated();
```

**Returns:** Boolean indicating if process is elevated

**Platform Behavior:**
- **Windows:** Returns `true` if running with UAC elevation (elevated token)
- **Unix/Linux:** Returns `true` if effective UID is 0 (root)

**Example:**
```levy
if (priv.is_elevated()) {
    print("Running with elevated privileges");
} else {
    print("Running with normal user privileges");
}
```

### is_admin()

Check if the current user is a member of the administrators/sudo group.

**Syntax:**
```levy
var admin = priv.is_admin();
```

**Returns:** Boolean indicating if user has administrator capabilities

**Platform Behavior:**
- **Windows:** Checks if user is in the Administrators group
- **Unix/Linux:** Returns `true` if UID is 0 or user is in sudo/wheel/admin group

**Example:**
```levy
if (priv.is_admin()) {
    print("User can request administrative privileges");
} else {
    print("User does not have administrative capabilities");
}
```

### is_root()

Check if running as the system's highest privilege level.

**Syntax:**
```levy
var root = priv.is_root();
```

**Returns:** Boolean indicating if running as root/SYSTEM

**Platform Behavior:**
- **Windows:** Returns `true` if running as SYSTEM account
- **Unix/Linux:** Returns `true` if effective UID is 0

**Example:**
```levy
if (priv.is_root()) {
    print("Running as SYSTEM/root - highest privileges");
    // Perform system-level operations
}
```

### get_privilege_level()

Get the current privilege level as a descriptive string.

**Syntax:**
```levy
var level = priv.get_privilege_level();
```

**Returns:** String with one of the following values:
- `"STANDARD_USER"` - Normal user privileges
- `"ELEVATED_USER"` - Elevated but not full admin (UAC on Windows)
- `"ADMINISTRATOR"` - Full administrator/root privileges
- `"SYSTEM"` - System-level privileges (Windows SYSTEM account)
- `"UNKNOWN"` - Cannot determine privilege level

**Example:**
```levy
var level = priv.get_privilege_level();
print("Current privilege level: " + level);

if (level == "STANDARD_USER") {
    print("Consider elevating for system operations");
}
```

### can_elevate()

Check if the current user can request privilege elevation.

**Syntax:**
```levy
var can_elevate = priv.can_elevate();
```

**Returns:** Boolean indicating if elevation is possible

**Platform Behavior:**
- **Windows:** Returns `true` if user is in Administrators group (can use UAC)
- **Unix/Linux:** Returns `true` if user is in sudo/wheel/admin group or sudo is available

**Example:**
```levy
if (priv.can_elevate()) {
    print("Elevation is available - can request admin access");
    // Offer to elevate if needed
} else {
    print("Elevation not available - running with current privileges only");
}
```

## Elevation Requests

### request_elevation(reason?)

Request privilege elevation via OS mechanisms (UAC on Windows, sudo prompt on Unix).

**Syntax:**
```levy
var success = priv.request_elevation();
var success = priv.request_elevation(reason);
```

**Parameters:**
- `reason` (optional): String explaining why elevation is needed (default: "Levython script requires elevated privileges")

**Returns:** Boolean indicating if elevation request succeeded

**Platform Behavior:**
- **Windows:** Triggers UAC dialog. Returns `false` if user declines, `true` if accepted
- **Unix/Linux:** Informs user to run with sudo (cannot programmatically prompt)

**Example:**
```levy
if (!priv.is_elevated()) {
    var success = priv.request_elevation("Need admin access to modify system files");
    
    if (success) {
        print("Elevation granted");
    } else {
        print("Elevation denied or cancelled");
        return;
    }
}
```

### elevate_and_restart(args?)

Elevate privileges by restarting the script with administrative access.

**Syntax:**
```levy
priv.elevate_and_restart();
priv.elevate_and_restart([arg1, arg2, ...]);
```

**Parameters:**
- `args` (optional): List of command-line arguments to pass to restarted script

**Returns:** Does not return (current process exits)

**Platform Behavior:**
- **Windows:** Uses ShellExecute with "runas" to trigger UAC and restart
- **Unix/Linux:** Re-executes script with sudo

**Example:**
```levy
if (!priv.is_elevated()) {
    print("Elevating and restarting...");
    priv.elevate_and_restart(["--continued", "true"]);
    // Script exits here and restarts elevated
}

print("Now running with elevated privileges");
```

## User Management

### get_user_info()

Get comprehensive information about the current user.

**Syntax:**
```levy
var user = priv.get_user_info();
```

**Returns:** Map with the following keys:
- `username` - Current username
- `full_name` - Full/display name (if available)
- `user_id` - User ID (UID on Unix, RID on Windows)
- `group_id` - Primary group ID (GID on Unix)
- `is_admin` - Boolean, is administrator/sudo user
- `is_elevated` - Boolean, is currently elevated
- `privilege_level` - String privilege level
- `home_directory` - Home directory path
- `groups` - List of group names user belongs to

**Example:**
```levy
var user = priv.get_user_info();

print("Username: " + user["username"]);
print("User ID: " + user["user_id"]);
print("Admin: " + user["is_admin"]);
print("Elevated: " + user["is_elevated"]);
print("Privilege Level: " + user["privilege_level"]);
print("Home Directory: " + user["home_directory"]);

print("\nGroups:");
for (var group in user["groups"]) {
    print("  - " + group);
}
```

### impersonate_user(username)

Impersonate another user (requires root/SYSTEM privileges).

**Syntax:**
```levy
var success = priv.impersonate_user(username);
```

**Parameters:**
- `username` - Username to impersonate

**Returns:** Boolean indicating success

**Platform Behavior:**
- **Windows:** Not fully implemented (requires credentials and complex token manipulation)
- **Unix/Linux:** Changes effective UID/GID to target user (requires root)

**Requirements:**
- Must be running as root (Unix) or SYSTEM (Windows)
- Target user must exist

**Example:**
```levy
if (priv.is_root()) {
    var success = priv.impersonate_user("testuser");
    
    if (success) {
        var user = priv.get_user_info();
        print("Now running as: " + user["username"]);
    }
}
```

## Privilege Management

### check_privilege(privilege_name)

Check if a specific privilege is enabled.

**Syntax:**
```levy
var has_priv = priv.check_privilege(privilege_name);
```

**Parameters:**
- `privilege_name` - Name of the privilege to check

**Returns:** Boolean indicating if privilege is available and enabled

**Platform Behavior:**
- **Windows:** Checks token privileges (e.g., "SeDebugPrivilege", "SeShutdownPrivilege")
- **Unix/Linux:** Limited support; checks if root for most privileges

**Common Windows Privileges:**
- `"SeDebugPrivilege"` - Debug programs
- `"SeShutdownPrivilege"` - Shutdown system
- `"SeBackupPrivilege"` - Backup files
- `"SeRestorePrivilege"` - Restore files
- `"SeTakeOwnershipPrivilege"` - Take ownership of objects

**Example:**
```levy
if (priv.check_privilege("SeDebugPrivilege")) {
    print("Can debug other processes");
}

if (priv.check_privilege("SeShutdownPrivilege")) {
    print("Can shutdown system");
}
```

### enable_privilege(privilege_name)

Enable a specific privilege for the current process.

**Syntax:**
```levy
var success = priv.enable_privilege(privilege_name);
```

**Parameters:**
- `privilege_name` - Name of the privilege to enable

**Returns:** Boolean indicating if privilege was successfully enabled

**Platform Behavior:**
- **Windows:** Uses AdjustTokenPrivileges to enable the privilege
- **Unix/Linux:** Requires root; most privileges cannot be individually enabled

**Example:**
```levy
// Enable debug privilege before attaching to processes
if (priv.enable_privilege("SeDebugPrivilege")) {
    print("Debug privilege enabled");
    // Can now debug other processes
} else {
    print("Failed to enable debug privilege");
}
```

### drop_privileges()

Drop elevated privileges back to standard user level.

**Syntax:**
```levy
var success = priv.drop_privileges();
```

**Returns:** Boolean indicating if privileges were successfully dropped

**Platform Behavior:**
- **Windows:** Creates a restricted token (complex operation, partially implemented)
- **Unix/Linux:** Drops from root to original UID/GID

**Use Case:** Security best practice - elevate only when needed, then drop back

**Example:**
```levy
if (priv.is_elevated()) {
    // Perform privileged operations
    perform_admin_tasks();
    
    // Drop back to normal user
    if (priv.drop_privileges()) {
        print("Successfully dropped to normal user privileges");
    }
}
```

## Command Execution

### run_as_admin(command, args?)

Execute a command with administrative/root privileges.

**Syntax:**
```levy
var exit_code = priv.run_as_admin(command);
var exit_code = priv.run_as_admin(command, [arg1, arg2, ...]);
```

**Parameters:**
- `command` - Command or executable path to run
- `args` (optional) - List of command-line arguments

**Returns:** Integer exit code from the command

**Platform Behavior:**
- **Windows:** Uses ShellExecute with "runas" to trigger UAC and run command
- **Unix/Linux:** Executes command with sudo

**Example:**
```levy
// Run a system command as administrator
var result = priv.run_as_admin("diskpart", ["/s", "cleanup.txt"]);

if (result == 0) {
    print("Command completed successfully");
} else {
    print("Command failed with exit code: " + result);
}

// Run a script as admin
priv.run_as_admin("python", ["setup.py", "install"]);
```

## Token Information

### get_token_info()

Get detailed information about the process security token (primarily Windows).

**Syntax:**
```levy
var token = priv.get_token_info();
```

**Returns:** Map with token information (platform-specific keys)

**Windows-Specific Keys:**
- `is_elevated` - Boolean, token is elevated
- `elevation_type` - String: "DEFAULT", "FULL", or "LIMITED"
- `integrity_level` - Integer integrity level
- `integrity_name` - String: "LOW", "MEDIUM", "HIGH", or "SYSTEM"
- `privileges` - List of privilege objects with `name` and `enabled` keys

**Unix-Specific Keys:**
- `real_uid` - Real user ID
- `effective_uid` - Effective user ID
- `real_gid` - Real group ID
- `effective_gid` - Effective group ID
- `is_elevated` - Boolean, effective UID is 0
- `is_setuid` - Boolean, real UID differs from effective UID

**Example:**
```levy
var token = priv.get_token_info();

// Windows
if (os.name() == "Windows") {
    print("Elevated: " + token["is_elevated"]);
    print("Elevation Type: " + token["elevation_type"]);
    print("Integrity: " + token["integrity_name"]);
    
    print("\nPrivileges:");
    for (var priv in token["privileges"]) {
        print("  " + priv["name"] + ": " + priv["enabled"]);
    }
}

// Unix/Linux
if (os.name() != "Windows") {
    print("Real UID: " + token["real_uid"]);
    print("Effective UID: " + token["effective_uid"]);
    print("Elevated: " + token["is_elevated"]);
    print("SETUID: " + token["is_setuid"]);
}
```

## Platform-Specific Behavior

### Windows

- Uses **User Account Control (UAC)** for elevation prompts
- **Token-based security model** with integrity levels and privileges
- **SYSTEM account** represents highest privilege level
- Elevation requires user interaction (UAC dialog)
- Supports granular privilege management (SeDebugPrivilege, etc.)

### macOS / Linux

- Uses **sudo** for privilege elevation
- **UID/GID-based permissions** (root is UID 0)
- Cannot programmatically prompt for elevation (must use sudo from command line)
- Privilege checks primarily based on root status
- Group memberships (sudo, wheel, admin) determine elevation capability

## Security Considerations

### Best Practices

1. **Principle of Least Privilege**: Request elevation only when necessary
2. **Verify Before Elevating**: Check `can_elevate()` before requesting
3. **Inform Users**: Provide clear reasons for elevation requests
4. **Drop When Done**: Use `drop_privileges()` after completing admin tasks
5. **Audit Usage**: Log elevation requests and privileged operations

### Security Guidelines

```levy
// Good practice: Check, explain, execute, drop
if (!priv.is_elevated() && needs_admin_access()) {
    if (!priv.can_elevate()) {
        print("ERROR: Administrator access required but not available");
        return 1;
    }
    
    var success = priv.request_elevation("Need to modify system configuration");
    if (!success) {
        print("User declined elevation request");
        return 1;
    }
}

// Perform privileged operations
perform_system_modifications();

// Drop back to normal privileges
priv.drop_privileges();

// Continue with normal operations
```

### Risks

- **Privilege escalation vulnerabilities**: Always validate user input before using in elevated commands
- **Token manipulation**: Be cautious with impersonation and privilege enabling
- **UAC bypass**: Never attempt to bypass security mechanisms
- **Command injection**: Sanitize all inputs to `run_as_admin()`

## Complete Function Reference

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `is_elevated()` | None | Boolean | Check if process is elevated |
| `is_admin()` | None | Boolean | Check if user is administrator |
| `is_root()` | None | Boolean | Check if running as root/SYSTEM |
| `get_privilege_level()` | None | String | Get privilege level name |
| `can_elevate()` | None | Boolean | Check if elevation is possible |
| `request_elevation(reason?)` | reason (optional) | Boolean | Request privilege elevation |
| `elevate_and_restart(args?)` | args (optional) | Void | Elevate and restart script |
| `get_user_info()` | None | Map | Get current user information |
| `impersonate_user(username)` | username | Boolean | Impersonate another user |
| `check_privilege(name)` | privilege_name | Boolean | Check specific privilege |
| `enable_privilege(name)` | privilege_name | Boolean | Enable a privilege |
| `drop_privileges()` | None | Boolean | Drop to normal privileges |
| `run_as_admin(cmd, args?)` | command, args? | Integer | Run command as admin |
| `get_token_info()` | None | Map | Get security token info |

## Examples

### Complete Elevation Workflow

```levy
var os = import("os");
var priv = os.PrivilegeEscalator;

function main() {
    print("=== Privilege Escalation Demo ===\n");
    
    // Check current status
    var user = priv.get_user_info();
    print("User: " + user["username"]);
    print("Privilege Level: " + user["privilege_level"]);
    print("Elevated: " + user["is_elevated"]);
    print("Admin: " + user["is_admin"]);
    
    // Check if we need elevation
    if (!priv.is_elevated()) {
        print("\n[!] Script requires administrative privileges");
        
        if (!priv.can_elevate()) {
            print("[ERROR] Elevation not available for this user");
            return 1;
        }
        
        print("[*] Requesting elevation...");
        var success = priv.request_elevation("Need admin access for system configuration");
        
        if (!success) {
            print("[ERROR] Elevation request denied");
            return 1;
        }
    }
    
    print("\n[✓] Running with elevated privileges");
    
    // Perform administrative tasks
    perform_admin_operations();
    
    // Drop privileges
    print("\n[*] Dropping privileges...");
    if (priv.drop_privileges()) {
        print("[✓] Successfully dropped to normal user");
    }
    
    return 0;
}

function perform_admin_operations() {
    print("\n--- Administrative Operations ---");
    
    // Enable specific privilege
    if (priv.enable_privilege("SeBackupPrivilege")) {
        print("[✓] Backup privilege enabled");
    }
    
    // Run admin commands
    print("[*] Running system cleanup...");
    var result = priv.run_as_admin("cleanmgr", ["/sagerun:1"]);
    print("[*] Cleanup exit code: " + result);
    
    // Check token info
    var token = priv.get_token_info();
    print("[*] Current integrity: " + token["integrity_name"]);
}

main();
```

## See Also

- [OS.PrivilegeEscalator Quick Reference](OS_PRIVILEGEESCALATOR_QUICKREF.md)
- [OS.PrivilegeEscalator Implementation Details](OS_PRIVILEGEESCALATOR_IMPLEMENTATION.md)
- [OS Module Documentation](OS_MODULE.md)
- [Operating System Integration Guide](OS_INTEGRATION.md)

---

**Module:** OS.PrivilegeEscalator  
**Version:** 1.0  
**Platform Support:** Windows, macOS, Linux  
**Security Level:** High - Use with caution
