# OS.PrivilegeEscalator Implementation Details

Technical documentation for the Levython OS.PrivilegeEscalator module implementation.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Data Structures](#data-structures)
- [Platform-Specific Implementation](#platform-specific-implementation)
- [State Management](#state-management)
- [Security Model](#security-model)
- [Function Implementations](#function-implementations)
- [Error Handling](#error-handling)
- [Performance Considerations](#performance-considerations)

## Architecture Overview

### Module Structure

```
OS.PrivilegeEscalator
├── Data Structures
│   ├── PrivilegeLevel enum
│   ├── UserInfo struct
│   ├── PrivilegeCheckResult struct
│   ├── TokenInfo struct
│   └── PrivilegeEscalatorState (singleton)
│
├── Privilege Checking (5 functions)
│   ├── is_elevated()
│   ├── is_admin()
│   ├── is_root()
│   ├── get_privilege_level()
│   └── can_elevate()
│
├── Elevation Requests (2 functions)
│   ├── request_elevation()
│   └── elevate_and_restart()
│
├── User Management (2 functions)
│   ├── get_user_info()
│   └── impersonate_user()
│
├── Privilege Management (3 functions)
│   ├── check_privilege()
│   ├── enable_privilege()
│   └── drop_privileges()
│
├── Command Execution (1 function)
│   ├── run_as_admin()
│
└── Token Information (1 function)
    └── get_token_info()
```

## Data Structures

### PrivilegeLevel Enum

```cpp
enum class PrivilegeLevel {
    STANDARD_USER,       // Normal user privileges
    ELEVATED_USER,       // Elevated but not full admin (UAC on Windows)
    ADMINISTRATOR,       // Full administrator/root privileges
    SYSTEM,             // System-level privileges (Windows SYSTEM account)
    UNKNOWN             // Cannot determine privilege level
};
```

**Purpose:** Represents the current privilege level of the process.

**Platform Mapping:**
- Windows: Maps to UAC elevation types and integrity levels
- Unix: Maps to UID-based privilege levels (0 = root, others = user)

### UserInfo Struct

```cpp
struct UserInfo {
    std::string username;        // Current username
    std::string full_name;       // Full name (if available)
    uint32_t user_id;           // User ID (UID on Unix, SID on Windows)
    uint32_t group_id;          // Primary group ID (GID on Unix)
    bool is_admin;              // Is administrator/root
    bool is_elevated;           // Is currently elevated
    PrivilegeLevel level;       // Current privilege level
    std::string home_directory; // Home directory path
    std::vector<std::string> groups; // Group memberships
};
```

**Purpose:** Comprehensive user identity and privilege information.

**Population:**
- **Windows:** Uses GetUserName, GetTokenInformation, LookupAccountSid
- **Unix:** Uses getpwuid, getgrgid, getgrouplist

### PrivilegeCheckResult Struct

```cpp
struct PrivilegeCheckResult {
    bool has_privilege;         // Has the privilege
    std::string privilege_name; // Name of the privilege
    bool enabled;               // Is privilege enabled
    std::string description;    // Privilege description
};
```

**Purpose:** Results from privilege existence and status checks.

### TokenInfo Struct

```cpp
struct TokenInfo {
    bool is_elevated;           // Is elevation token
    bool is_restricted;         // Is restricted token
    bool has_admin_group;       // Has administrators group
    uint32_t integrity_level;   // Integrity level (Windows)
    std::vector<std::string> privileges; // List of privileges
    std::vector<std::string> groups;     // List of groups
};
```

**Purpose:** Abstracted security token information for cross-platform use.

### PrivilegeEscalatorState Struct

```cpp
struct PrivilegeEscalatorState {
    UserInfo current_user;
    bool elevation_attempted;
    bool drop_privileges_possible;
    std::mutex mutex;
    
#ifdef _WIN32
    HANDLE process_token;
    TOKEN_ELEVATION_TYPE elevation_type;
#else
    uid_t original_uid;
    uid_t effective_uid;
    gid_t original_gid;
    gid_t effective_gid;
#endif
    
    void initialize();
    void cleanup();
    void refresh_user_info();
    bool check_is_elevated();
    bool check_is_admin();
    PrivilegeLevel get_privilege_level();
};
```

**Purpose:** Singleton state manager with platform-specific privilege information.

**Thread Safety:** All operations protected by mutex.

## Platform-Specific Implementation

### Windows Implementation

#### UAC Elevation

```cpp
// Trigger UAC prompt
SHELLEXECUTEINFOA sei = { sizeof(sei) };
sei.lpVerb = "runas";          // Request elevation
sei.lpFile = exe_path;
sei.lpParameters = args;
sei.nShow = SW_NORMAL;
sei.fMask = SEE_MASK_NOCLOSEPROCESS;

if (!ShellExecuteExA(&sei)) {
    DWORD error = GetLastError();
    if (error == ERROR_CANCELLED) {
        // User declined UAC prompt
        return false;
    }
}
```

**API Used:** ShellExecuteEx with "runas" verb
**User Experience:** UAC dialog appears, requires user interaction
**Return Behavior:** Returns false if user declines

#### Token Management

```cpp
// Open process token
HANDLE token;
OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY | TOKEN_ADJUST_PRIVILEGES, &token);

// Check elevation status
TOKEN_ELEVATION elevation;
GetTokenInformation(token, TokenElevation, &elevation, sizeof(elevation), &length);
bool is_elevated = (elevation.TokenIsElevated != 0);

// Get elevation type
TOKEN_ELEVATION_TYPE type;
GetTokenInformation(token, TokenElevationType, &type, sizeof(type), &length);
// type: TokenElevationTypeDefault, TokenElevationTypeFull, TokenElevationTypeLimited
```

**Token Types:**
- **Default:** Standard user token
- **Full:** Administrator token (after UAC)
- **Limited:** Restricted admin token (before UAC)

#### Privilege Management

```cpp
// Enable a privilege
LUID privilege_luid;
LookupPrivilegeValueA(nullptr, "SeDebugPrivilege", &privilege_luid);

TOKEN_PRIVILEGES tp;
tp.PrivilegeCount = 1;
tp.Privileges[0].Luid = privilege_luid;
tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

AdjustTokenPrivileges(token, FALSE, &tp, sizeof(tp), nullptr, nullptr);
```

**Common Privileges:**
- SeDebugPrivilege - Debug other processes
- SeBackupPrivilege - Bypass file ACLs for backup
- SeRestorePrivilege - Bypass file ACLs for restore
- SeShutdownPrivilege - Shutdown system

#### Integrity Levels

```cpp
// Get integrity level
TOKEN_MANDATORY_LABEL* label;
GetTokenInformation(token, TokenIntegrityLevel, buffer, size, &length);

DWORD integrity = *GetSidSubAuthority(label->Label.Sid,
                                     *GetSidSubAuthorityCount(label->Label.Sid) - 1);

// Integrity values
// SECURITY_MANDATORY_LOW_RID    (0x1000)
// SECURITY_MANDATORY_MEDIUM_RID (0x2000)
// SECURITY_MANDATORY_HIGH_RID   (0x3000)
// SECURITY_MANDATORY_SYSTEM_RID (0x4000)
```

**Integrity Mapping:**
- **Low:** Sandboxed applications, IE Protected Mode
- **Medium:** Standard user applications
- **High:** Administrator applications
- **System:** System services (LocalSystem)

#### Group Membership

```cpp
// Check Administrators group membership
SID_IDENTIFIER_AUTHORITY nt_authority = SECURITY_NT_AUTHORITY;
PSID admin_group;
AllocateAndInitializeSid(&nt_authority, 2,
                         SECURITY_BUILTIN_DOMAIN_RID,
                         DOMAIN_ALIAS_RID_ADMINS,
                         0, 0, 0, 0, 0, 0, &admin_group);

BOOL is_admin;
CheckTokenMembership(nullptr, admin_group, &is_admin);
FreeSid(admin_group);
```

### Unix/Linux/macOS Implementation

#### UID/GID Checking

```cpp
// Get user IDs
uid_t real_uid = getuid();       // UID of process owner
uid_t effective_uid = geteuid(); // UID for permission checks

// Check if root
bool is_root = (effective_uid == 0);

// Check if elevated (setuid or running as root)
bool is_elevated = (effective_uid == 0) || (real_uid != effective_uid);
```

**UID Concepts:**
- **Real UID:** UID of user who started process
- **Effective UID:** UID used for permission checks
- **Setuid programs:** Real ≠ Effective (e.g., sudo, passwd)

#### User Information

```cpp
// Get user information
struct passwd* pwd = getpwuid(effective_uid);
if (pwd) {
    std::string username = pwd->pw_name;
    std::string full_name = pwd->pw_gecos;
    std::string home_dir = pwd->pw_dir;
    uid_t uid = pwd->pw_uid;
    gid_t gid = pwd->pw_gid;
}
```

**API Used:** getpwuid from `<pwd.h>`

#### Group Membership

```cpp
// Get group list
int ngroups;
getgrouplist(username.c_str(), gid, nullptr, &ngroups);

std::vector<gid_t> groups(ngroups);
getgrouplist(username.c_str(), gid, groups.data(), &ngroups);

// Resolve group names
for (gid_t gid : groups) {
    struct group* grp = getgrgid(gid);
    if (grp) {
        std::string group_name = grp->gr_name;
    }
}
```

**Sudo Group Check:**
```cpp
bool can_sudo = false;
for (const auto& group : groups) {
    if (group == "sudo" || group == "wheel" || group == "admin") {
        can_sudo = true;
        break;
    }
}
```

#### Privilege Elevation

```cpp
// Unix cannot programmatically prompt for elevation
// Users must invoke script with sudo:
// $ sudo levython script.levy

// Check if sudo is available
bool sudo_available = (system("which sudo > /dev/null 2>&1") == 0);
```

**Limitation:** No programmatic UAC-equivalent on Unix systems. Scripts must be run with `sudo` from command line.

#### Drop Privileges

```cpp
// Drop from root to original user
if (geteuid() == 0 && original_uid != 0) {
    // Must drop group first, then user
    setgid(original_gid);
    setuid(original_uid);
    
    // Verify drop succeeded
    if (geteuid() == 0) {
        // Failed to drop
        return false;
    }
}
```

**Order Important:** Set GID before UID (after dropping UID, cannot change GID)

#### User Impersonation

```cpp
// Must be root to impersonate
if (geteuid() != 0) {
    throw std::runtime_error("Requires root");
}

// Get target user info
struct passwd* pwd = getpwnam(username.c_str());
if (!pwd) {
    throw std::runtime_error("User not found");
}

// Switch to user
setgid(pwd->pw_gid);
setuid(pwd->pw_uid);
```

## State Management

### Singleton Pattern

```cpp
static PrivilegeEscalatorState& get_privilege_escalator_state() {
    static PrivilegeEscalatorState state;
    return state;
}
```

**Benefits:**
- Single source of truth for privilege state
- Automatic initialization on first access
- Thread-safe with internal mutex
- Automatic cleanup on program exit

### Initialization

```cpp
void PrivilegeEscalatorState::initialize() {
    std::lock_guard<std::mutex> lock(mutex);
    
#ifdef _WIN32
    // Open process token
    OpenProcessToken(GetCurrentProcess(), 
                     TOKEN_QUERY | TOKEN_ADJUST_PRIVILEGES, 
                     &process_token);
    
    // Get elevation type
    GetTokenInformation(process_token, TokenElevationType,
                       &elevation_type, sizeof(elevation_type), &length);
#else
    // Store original UIDs/GIDs
    original_uid = getuid();
    effective_uid = geteuid();
    original_gid = getgid();
    effective_gid = getegid();
#endif
    
    refresh_user_info();
}
```

**Called:** Automatically on singleton creation

### State Refresh

```cpp
void PrivilegeEscalatorState::refresh_user_info() {
    // Get current user identity
    // Populate UserInfo structure
    // Query group memberships
    // Update privilege level
}
```

**Called:**
- During initialization
- After privilege changes (impersonation, elevation)
- On user request via `get_user_info()`

### Thread Safety

All state access protected by mutex:

```cpp
auto& state = get_privilege_escalator_state();
std::lock_guard<std::mutex> lock(state.mutex);
// Access state fields safely
```

## Security Model

### Principle of Least Privilege

1. **Check before requesting:** Use `can_elevate()` to verify capability
2. **Explain to users:** Provide clear reasons via `request_elevation(reason)`
3. **Minimize elevated duration:** Drop privileges immediately after use
4. **Validate inputs:** Sanitize all data used in elevated contexts

### Input Validation

```cpp
// Example: Sanitize command arguments
Value builtin_os_privilegeescalator_run_as_admin(const std::vector<Value> &args) {
    std::string command = value_to_string(args[0]);
    
    // Validate command path
    if (command.empty() || command.find("..") != std::string::npos) {
        throw std::runtime_error("Invalid command path");
    }
    
    // Validate arguments
    for (const auto& arg : args[1].data.list) {
        std::string arg_str = value_to_string(arg);
        // Check for command injection attempts
        if (arg_str.find(";") != std::string::npos ||
            arg_str.find("&&") != std::string::npos ||
            arg_str.find("|") != std::string::npos) {
            throw std::runtime_error("Invalid argument characters");
        }
    }
    
    // Execute safely
}
```

### UAC Integrity Separation (Windows)

```
┌────────────────────┐
│  SYSTEM            │  Integrity: System (4000)
│  (NT AUTHORITY)    │
└────────────────────┘
         ↓
┌────────────────────┐
│  Administrator     │  Integrity: High (3000)
│  (Elevated)        │  - After UAC elevation
└────────────────────┘
         ↓
┌────────────────────┐
│  Standard User     │  Integrity: Medium (2000)
│  (Limited Admin)   │  - Before UAC elevation
└────────────────────┘
         ↓
┌────────────────────┐
│  Sandboxed App     │  Integrity: Low (1000)
│  (IE Protected)    │
└────────────────────┘
```

### Audit Logging

**Recommendation:** Implement application-level logging for:

```levy
// Log elevation attempts
function log_elevation(username, success, reason) {
    var timestamp = system.timestamp();
    var entry = timestamp + " | " + username + " | " + 
                (success ? "GRANTED" : "DENIED") + " | " + reason;
    append_to_audit_log(entry);
}

// Usage
var user = priv.get_user_info();
var success = priv.request_elevation("System configuration");
log_elevation(user["username"], success, "System configuration");
```

## Function Implementations

### is_elevated()

**Windows:**
```cpp
TOKEN_ELEVATION elevation;
GetTokenInformation(token, TokenElevation, &elevation, 
                   sizeof(elevation), &return_length);
return (elevation.TokenIsElevated != 0);
```

**Unix:**
```cpp
return (geteuid() == 0);
```

### is_admin()

**Windows:**
```cpp
// Check Administrators group membership
PSID admin_group;
AllocateAndInitializeSid(&nt_authority, 2,
                         SECURITY_BUILTIN_DOMAIN_RID,
                         DOMAIN_ALIAS_RID_ADMINS, ...);
CheckTokenMembership(nullptr, admin_group, &is_admin);
return (is_admin != FALSE);
```

**Unix:**
```cpp
// Check root or sudo/wheel/admin group
if (geteuid() == 0) return true;

for (const auto& group : current_user.groups) {
    if (group == "sudo" || group == "wheel" || group == "admin") {
        return true;
    }
}
return false;
```

### request_elevation()

**Windows:**
```cpp
// Get current executable
char exe_path[MAX_PATH];
GetModuleFileNameA(nullptr, exe_path, MAX_PATH);

// Trigger UAC
SHELLEXECUTEINFOA sei = { sizeof(sei) };
sei.lpVerb = "runas";
sei.lpFile = exe_path;
sei.lpParameters = command_line_args;

if (!ShellExecuteExA(&sei)) {
    if (GetLastError() == ERROR_CANCELLED) {
        return false;  // User declined
    }
    throw std::runtime_error("Elevation failed");
}

return true;
```

**Unix:**
```cpp
// Cannot programmatically prompt
std::cerr << "Elevation required: " << reason << std::endl;
std::cerr << "Please run with sudo or as root" << std::endl;
return false;
```

### enable_privilege()

**Windows Only:**
```cpp
// Lookup privilege
LUID luid;
LookupPrivilegeValueA(nullptr, privilege_name.c_str(), &luid);

// Enable it
TOKEN_PRIVILEGES tp;
tp.PrivilegeCount = 1;
tp.Privileges[0].Luid = luid;
tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

AdjustTokenPrivileges(token, FALSE, &tp, sizeof(tp), nullptr, nullptr);

if (GetLastError() == ERROR_NOT_ALL_ASSIGNED) {
    return false;  // Privilege not held
}

return true;
```

**Unix:**
```cpp
// Not supported (would require capabilities)
if (geteuid() != 0) {
    throw std::runtime_error("Requires root");
}
return true;  // Root has all privileges
```

## Error Handling

### Exception Strategy

```cpp
// Validation errors: Throw immediately
if (args.size() != expected) {
    throw std::runtime_error("Invalid argument count");
}

// Platform errors: Return false or throw based on severity
if (!critical_function()) {
    return Value(false);  // Soft failure
}

if (!system_call()) {
    throw std::runtime_error("System call failed: " + error);  // Hard failure
}
```

### Common Error Scenarios

| Scenario | Behavior | Levython Result |
|----------|----------|-----------------|
| User declines UAC | Return false | `request_elevation()` returns `false` |
| Privilege not held | Return false | `enable_privilege()` returns `false` |
| Invalid privilege name | Throw exception | Runtime error |
| Token unavailable | Return false | Functions return `false` or safe defaults |
| Not root (Unix impersonation) | Throw exception | Runtime error |
| Command execution failure | Return exit code | `run_as_admin()` returns non-zero |

## Performance Considerations

### State Caching

```cpp
struct PrivilegeEscalatorState {
    UserInfo current_user;  // Cached user info
    
    // Refresh only when needed
    void refresh_user_info();
};
```

**Benefit:** Avoid repeated system calls for user/group lookups

### Token Reuse

```cpp
#ifdef _WIN32
    HANDLE process_token;  // Opened once, reused for all operations
#endif
```

**Benefit:** Single OpenProcessToken call instead of per-operation

### Lazy Initialization

```cpp
static PrivilegeEscalatorState& get_privilege_escalator_state() {
    static PrivilegeEscalatorState state;  // Initialized on first access
    return state;
}
```

**Benefit:** No initialization cost if module not used

### Mutex Granularity

```cpp
// Fine-grained locking
auto& state = get_privilege_escalator_state();
{
    std::lock_guard<std::mutex> lock(state.mutex);
    // Only hold lock during actual state access
}
// Lock released immediately
```

**Benefit:** Minimize lock contention in multi-threaded environments

## Compilation Requirements

### Windows Headers

```cpp
#include <windows.h>
#include <sddl.h>      // Security Descriptor Definition Language
#include <aclapi.h>    // Access Control List API
#include <userenv.h>   // User environment functions
#include <shellapi.h>  // ShellExecute for UAC

#pragma comment(lib, "advapi32.lib")  // Advanced API (security)
#pragma comment(lib, "userenv.lib")   // User environment
#pragma comment(lib, "shell32.lib")   // Shell functions
```

### Unix Headers

```cpp
#include <unistd.h>    // getuid, geteuid, setuid, etc.
#include <pwd.h>       // User database (getpwuid)
#include <grp.h>       // Group database (getgrgid)
#include <sys/types.h> // uid_t, gid_t types
```

## Testing Considerations

### Test Scenarios

1. **Standard user with no elevation:**
   - `is_elevated()` → false
   - `is_admin()` → false
   - `can_elevate()` → false

2. **Admin user before UAC elevation:**
   - `is_elevated()` → false
   - `is_admin()` → true
   - `can_elevate()` → true
   - `get_privilege_level()` → "ELEVATED_USER" or "STANDARD_USER"

3. **Admin user after UAC elevation:**
   - `is_elevated()` → true
   - `is_admin()` → true
   - `get_privilege_level()` → "ADMINISTRATOR"

4. **Unix root user:**
   - `is_elevated()` → true
   - `is_admin()` → true
   - `is_root()` → true
   - `get_privilege_level()` → "ADMINISTRATOR"

### Security Testing

- Test with malicious input (command injection attempts)
- Verify privilege drops are irreversible
- Test UAC cancellation handling
- Verify token cleanup on errors

## See Also

- [OS.PrivilegeEscalator Module Documentation](OS_PRIVILEGEESCALATOR_MODULE.md)
- [OS.PrivilegeEscalator Quick Reference](OS_PRIVILEGEESCALATOR_QUICKREF.md)
- [Windows Security Documentation](https://docs.microsoft.com/en-us/windows/security/)
- [Unix Privileges and Capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html)

---

**Implementation Version:** 1.0  
**Platform Support:** Windows, macOS, Linux  
**Thread Safety:** Yes (mutex-protected)  
**Performance:** Optimized with state caching
