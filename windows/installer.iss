; ===========================================================================
; Levython Windows Installer Configuration
; ===========================================================================
;
; Professional installer for Levython programming language.
; Built with Inno Setup 6.x (https://jrsoftware.org/isinfo.php)
;
; Build command: iscc installer.iss
; Output: releases/levython-1.0.1-windows-installer.exe
;
; Copyright (c) 2024-2026 Levython Project
; Licensed under the MIT License
; ===========================================================================

#define MyAppName "Levython"
#define MyAppVersion "1.0.1"
#define MyAppPublisher "Levython Project"
#define MyAppURL "https://github.com/levython/Levython"
#define MyAppExeName "levython.exe"
#define MyAppLPMName "lpm.exe"

[Setup]
; Application Identity
AppId={{8F9A3B2E-4D6C-4E7F-9A1B-2C3D4E5F6A7B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases

; Installation Directories
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes

; Installer Appearance
LicenseFile=..\LICENSE
OutputDir=..\releases
OutputBaseFilename=levython-{#MyAppVersion}-windows-installer
SetupIconFile=..\logo.png
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
WizardImageFile=..\logo.png
WizardSmallImageFile=..\logo.png
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ChangesEnvironment=yes
UninstallDisplayIcon={app}\{#MyAppExeName}
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64

; Modern UI
WizardImageStretch=no
DisableWelcomePage=no
WizardResizable=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "addtopath"; Description: "Add Levython to PATH (Recommended)"; GroupDescription: "System Integration:"; Flags: checkedonce
Name: "addtopathuser"; Description: "Add to PATH for current user only"; GroupDescription: "System Integration:"; Flags: exclusive
Name: "addtopathsystem"; Description: "Add to PATH for all users (requires admin)"; GroupDescription: "System Integration:"; Flags: exclusive unchecked
Name: "fileassoc"; Description: "Associate .levy files with Levython"; GroupDescription: "File Associations:"; Flags: checkedonce

[Files]
; Main executables
Source: "build\levython.exe"; DestDir: "{app}\bin"; Flags: ignoreversion
Source: "build\lpm.exe"; DestDir: "{app}\bin"; Flags: ignoreversion

; Documentation and examples
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\CHANGELOG.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\examples\*"; DestDir: "{app}\examples"; Flags: ignoreversion recursesubdirs
Source: "..\docs\*"; DestDir: "{app}\docs"; Flags: ignoreversion recursesubdirs

; VS Code extension
Source: "..\vscode-levython\*"; DestDir: "{app}\vscode-extension"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\bin\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{group}\Documentation"; Filename: "{app}\docs\index.html"
Name: "{group}\Examples"; Filename: "{app}\examples"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\bin\{#MyAppExeName}"; Tasks: desktopicon

[Registry]
; File association for .levy files
Root: HKA; Subkey: "Software\Classes\.levy"; ValueType: string; ValueName: ""; ValueData: "LevythonFile"; Flags: uninsdeletevalue; Tasks: fileassoc
Root: HKA; Subkey: "Software\Classes\LevythonFile"; ValueType: string; ValueName: ""; ValueData: "Levython Script"; Flags: uninsdeletekey; Tasks: fileassoc
Root: HKA; Subkey: "Software\Classes\LevythonFile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\bin\{#MyAppExeName},0"; Tasks: fileassoc
Root: HKA; Subkey: "Software\Classes\LevythonFile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\bin\{#MyAppExeName}"" ""%1"""; Tasks: fileassoc
Root: HKA; Subkey: "Software\Classes\LevythonFile\shell\edit"; ValueType: string; ValueName: ""; ValueData: "Edit with &Code"; Tasks: fileassoc
Root: HKA; Subkey: "Software\Classes\LevythonFile\shell\edit\command"; ValueType: string; ValueName: ""; ValueData: """code"" ""%1"""; Tasks: fileassoc

; Add to Windows Programs list
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\App Paths\{#MyAppExeName}"; ValueType: string; ValueName: ""; ValueData: "{app}\bin\{#MyAppExeName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\App Paths\{#MyAppExeName}"; ValueType: string; ValueName: "Path"; ValueData: "{app}\bin"

[Code]
const
    EnvironmentKey = 'Environment';
    EnvironmentKeySystem = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';

procedure EnvAddPath(Path: string; IsSystemPath: boolean);
var
    Paths: string;
    RootKey: Integer;
    SubKeyName: string;
begin
    if IsSystemPath then
    begin
        RootKey := HKEY_LOCAL_MACHINE;
        SubKeyName := EnvironmentKeySystem;
    end
    else
    begin
        RootKey := HKEY_CURRENT_USER;
        SubKeyName := EnvironmentKey;
    end;

    if RegQueryStringValue(RootKey, SubKeyName, 'Path', Paths) then
    begin
        if Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths) + ';') = 0 then
        begin
            Paths := Paths + ';' + Path;
            if RegWriteStringValue(RootKey, SubKeyName, 'Path', Paths) then
            begin
                // Notify system of environment change
            end;
        end;
    end
    else
    begin
        RegWriteStringValue(RootKey, SubKeyName, 'Path', Path);
    end;
end;

procedure EnvRemovePath(Path: string);
var
    Paths: string;
    P: Integer;
    RootKey: Integer;
    SubKeyName: string;
begin
    // Try both user and system
    for RootKey := HKEY_CURRENT_USER to HKEY_LOCAL_MACHINE do
    begin
        if RootKey = HKEY_CURRENT_USER then
            SubKeyName := EnvironmentKey
        else
            SubKeyName := EnvironmentKeySystem;

        if RegQueryStringValue(RootKey, SubKeyName, 'Path', Paths) then
        begin
            P := Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths) + ';');
            if P > 0 then
            begin
                Delete(Paths, P, Length(Path) + 1);
                if Copy(Paths, 1, 1) = ';' then
                    Delete(Paths, 1, 1);
                if Copy(Paths, Length(Paths), 1) = ';' then
                    Delete(Paths, Length(Paths), 1);
                RegWriteStringValue(RootKey, SubKeyName, 'Path', Paths);
            end;
        end;
    end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
    AppPath: string;
    IsSystemPath: boolean;
begin
    if CurStep = ssPostInstall then
    begin
        AppPath := ExpandConstant('{app}\bin');
        
        if WizardIsTaskSelected('addtopathsystem') then
        begin
            IsSystemPath := True;
            EnvAddPath(AppPath, IsSystemPath);
        end
        else if WizardIsTaskSelected('addtopathuser') then
        begin
            IsSystemPath := False;
            EnvAddPath(AppPath, IsSystemPath);
        end;
    end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
    AppPath: string;
begin
    if CurUninstallStep = usPostUninstall then
    begin
        AppPath := ExpandConstant('{app}\bin');
        EnvRemovePath(AppPath);
    end;
end;

function InitializeSetup(): Boolean;
var
    ResultCode: Integer;
begin
    Result := True;
    
    // Check if Visual C++ Redistributable is installed (if needed)
    // if not FileExists(ExpandConstant('{sys}\vcruntime140.dll')) then
    // begin
    //     MsgBox('Microsoft Visual C++ Redistributable is required. Please install it from https://aka.ms/vs/17/release/vc_redist.x64.exe', mbInformation, MB_OK);
    // end;
end;

function InitializeUninstall(): Boolean;
begin
    Result := True;
end;

