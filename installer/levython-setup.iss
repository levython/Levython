; ==============================================================================
; LEVYTHON - Professional Windows Installer (Inno Setup)
; ==============================================================================
; Built with Inno Setup 6.x (https://jrsoftware.org/isinfo.php)
; 
; Features:
; - Modern Windows 11/10/8/7 UI
; - Auto-detects x64/x86/ARM64 architecture
; - Automatic PATH configuration
; - VS Code extension installation
; - Professional uninstaller
; - File associations (.levy, .ly)
; - Multi-language support
; ==============================================================================

#define MyAppName "Levython"
#define MyAppVersion "1.0.3"
#define MyAppPublisher "Levython Authors"
#define MyAppURL "https://github.com/levython/levython"
#define MyAppExeName "levython.exe"
#define MyAppDescription "High Performance JIT-Compiled Programming Language"

[Setup]
; App Identity
AppId={{B5F8F9A2-6D4E-4C8B-9F3A-2E5D7C9A1B4F}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases

; Directories
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=..\LICENSE
InfoBeforeFile=..\README.md
OutputDir=..\releases
OutputBaseFilename=levython-{#MyAppVersion}-windows-setup

; Modern UI
WizardStyle=modern
WizardSizePercent=120,120
WizardResizable=yes
DisableWelcomePage=no
DisableReadyPage=no
DisableFinishedPage=no

; Compression
Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes
LZMANumBlockThreads=4

; Architecture - Auto-detect and install appropriate binary
ArchitecturesAllowed=x64compatible x86compatible arm64
ArchitecturesInstallIn64BitMode=x64compatible arm64

; Privileges
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog commandline

; Version Info
VersionInfoVersion={#MyAppVersion}.0
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppDescription}
VersionInfoCopyright=Copyright (C) 2024-2026 {#MyAppPublisher}
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}

; Uninstaller
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
CreateUninstallRegKey=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"

[Messages]
WelcomeLabel1=Welcome to [name] Setup
WelcomeLabel2=This will install [name/ver] on your computer.%n%n[name] is a high‑performance programming language with a JIT‑accelerated runtime and a practical standard library.%n%nMotto: Be better than yesterday.%n%nDetected Architecture: {code:GetArchDescription}

[CustomMessages]
english.ArchX64=64-bit (x64)
english.ArchX86=32-bit (x86)
english.ArchARM64=ARM64

[Tasks]
Name: "addtopath"; Description: "Add Levython to system PATH (recommended)"; GroupDescription: "System Configuration:"; Flags: checkedonce
Name: "associatefiles"; Description: "Associate .levy and .ly files with Levython"; GroupDescription: "File Associations:"; Flags: checkedonce
Name: "installvscode"; Description: "Install VS Code extension (syntax highlighting)"; GroupDescription: "Development Tools:"; Flags: checkedonce; Check: IsVSCodeInstalled
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Dirs]
Name: "{app}\examples"
Name: "{app}\vscode-extension"

[Files]
; Main executable - architecture specific
Source: "..\releases\levython-windows-x64.exe"; DestDir: "{app}"; DestName: "levython.exe"; Flags: ignoreversion; Check: Is64BitInstallMode and not IsARM64
Source: "..\releases\levython-windows-x86.exe"; DestDir: "{app}"; DestName: "levython.exe"; Flags: ignoreversion solidbreak; Check: not Is64BitInstallMode
Source: "..\releases\levython-windows-arm64.exe"; DestDir: "{app}"; DestName: "levython.exe"; Flags: ignoreversion solidbreak; Check: IsARM64

; Fallback to single exe if arch-specific not available
Source: "..\levython.exe"; DestDir: "{app}"; DestName: "levython.exe"; Flags: ignoreversion skipifsourcedoesntexist

; Documentation
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\CHANGELOG.md"; DestDir: "{app}"; Flags: ignoreversion isreadme
Source: "..\IMPLEMENTATION_SUMMARY.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\JIT_OPTIMIZATIONS.md"; DestDir: "{app}"; Flags: ignoreversion

; Examples
Source: "..\examples\*"; DestDir: "{app}\examples"; Flags: ignoreversion recursesubdirs createallsubdirs

; VS Code Extension
Source: "..\vscode-levython\*"; DestDir: "{app}\vscode-extension"; Flags: ignoreversion recursesubdirs createallsubdirs

; Installer scripts for updates
Source: "LevythonInstaller.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "Install-Levython.bat"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName} REPL"; Filename: "{app}\{#MyAppExeName}"; Comment: "Levython Interactive Shell"
Name: "{group}\{#MyAppName} Examples"; Filename: "{app}\examples"
Name: "{group}\Documentation"; Filename: "{app}\README.md"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; Comment: "Levython Interactive Shell"

[Registry]
; File Association for .levy files
Root: HKCR; Subkey: ".levy"; ValueType: string; ValueName: ""; ValueData: "LevythonScript"; Flags: uninsdeletekey; Tasks: associatefiles
Root: HKCR; Subkey: ".ly"; ValueType: string; ValueName: ""; ValueData: "LevythonScript"; Flags: uninsdeletekey; Tasks: associatefiles
Root: HKCR; Subkey: "LevythonScript"; ValueType: string; ValueName: ""; ValueData: "Levython Script"; Flags: uninsdeletekey; Tasks: associatefiles
Root: HKCR; Subkey: "LevythonScript\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"; Tasks: associatefiles
Root: HKCR; Subkey: "LevythonScript\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Tasks: associatefiles
Root: HKCR; Subkey: "LevythonScript\shell\edit\command"; ValueType: string; ValueName: ""; ValueData: "notepad.exe ""%1"""; Tasks: associatefiles

; App registration
Root: HKLM; Subkey: "SOFTWARE\Levython"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "SOFTWARE\Levython"; ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"

[Run]
; Post-install verification
Filename: "{app}\{#MyAppExeName}"; Parameters: "--version"; Description: "Verify Levython installation"; Flags: runhidden nowait postinstall skipifsilent

; Install VS Code extension
Filename: "{code:GetVSCodeCmdPath}"; Parameters: "--install-extension ""{app}\vscode-extension"" --force"; StatusMsg: "Installing VS Code extension..."; Flags: runhidden waituntilterminated; Tasks: installvscode; Check: IsVSCodeInstalled

; Open examples folder
Filename: "{app}\examples"; Description: "Open Examples folder"; Flags: postinstall nowait skipifsilent shellexec unchecked

[UninstallRun]
; Clean uninstall - remove from PATH
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""$p=[Environment]::GetEnvironmentVariable('Path','Machine');$np=($p-split';'|?{{$_ -ne '{app}'}}) -join ';';[Environment]::SetEnvironmentVariable('Path',$np,'Machine')"""; Flags: runhidden

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
Type: dirifempty; Name: "{autopf}\{#MyAppName}"

[Code]
var
  ArchitecturePage: TWizardPage;
  ArchLabel: TLabel;

function IsARM64: Boolean;
begin
  Result := (ProcessorArchitecture = paARM64);
end;

function GetArchDescription(Param: String): String;
begin
  if IsARM64 then
    Result := 'ARM64'
  else if Is64BitInstallMode then
    Result := '64-bit (x64)'
  else
    Result := '32-bit (x86)';
end;

function GetVSCodePath: String;
var
  VSCodeExe: String;
begin
  Result := '';
  
  // Check Program Files
  VSCodeExe := ExpandConstant('{autopf}\Microsoft VS Code\Code.exe');
  if FileExists(VSCodeExe) then begin
    Result := VSCodeExe;
    Exit;
  end;
  
  // Check Program Files (x86)
  VSCodeExe := ExpandConstant('{autopf32}\Microsoft VS Code\Code.exe');
  if FileExists(VSCodeExe) then begin
    Result := VSCodeExe;
    Exit;
  end;
  
  // Check user installation
  VSCodeExe := ExpandConstant('{localappdata}\Programs\Microsoft VS Code\Code.exe');
  if FileExists(VSCodeExe) then begin
    Result := VSCodeExe;
    Exit;
  end;
end;

function GetVSCodeCmdPath(Param: String): String;
var
  BasePath: String;
begin
  BasePath := ExtractFilePath(GetVSCodePath);
  if BasePath <> '' then
    Result := BasePath + 'bin\code.cmd'
  else
    Result := '';
end;

function IsVSCodeInstalled: Boolean;
begin
  Result := (GetVSCodePath <> '');
end;

procedure AddToSystemPath(PathToAdd: String);
var
  CurrentPath: String;
  NewPath: String;
begin
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 
      'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 
      'Path', CurrentPath) then
  begin
    // Check if path already exists (case-insensitive)
    if Pos(Uppercase(PathToAdd), Uppercase(CurrentPath)) = 0 then
    begin
      // Ensure no trailing semicolon issues
      if (Length(CurrentPath) > 0) and (CurrentPath[Length(CurrentPath)] <> ';') then
        NewPath := CurrentPath + ';' + PathToAdd
      else
        NewPath := CurrentPath + PathToAdd;
      
      RegWriteStringValue(HKEY_LOCAL_MACHINE, 
        'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 
        'Path', NewPath);
      
      // Notify system of environment change
      // SendMessage will be handled automatically by Inno Setup
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Add to PATH if selected
    if WizardIsTaskSelected('addtopath') then
    begin
      AddToSystemPath(ExpandConstant('{app}'));
    end;
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
var
  ArchStr: String;
begin
  // Update welcome page with architecture info
  if CurPageID = wpWelcome then
  begin
    ArchStr := GetArchDescription('');
    WizardForm.WelcomeLabel2.Caption := 
      'This will install Levython ' + '{#MyAppVersion}' + ' on your computer.' + #13#10 + #13#10 +
      'Levython is a high‑performance programming language with a JIT‑accelerated runtime ' +
      'and a practical standard library.' + #13#10 + #13#10 +
      'Motto: Be better than yesterday.' + #13#10 + #13#10 +
      'Detected Architecture: ' + ArchStr;
  end;
  
  // Custom finish message
  if CurPageID = wpFinished then
  begin
    WizardForm.FinishedLabel.Caption := 
      'Levython has been successfully installed.' + #13#10 + #13#10 +
      'Quick start:' + #13#10 +
      '  levython --version' + #13#10 +
      '  levython hello.levy' + #13#10 + #13#10 +
      'Examples folder:' + #13#10 +
      '  ' + ExpandConstant('{app}\examples') + #13#10 + #13#10 +
      'Documentation:' + #13#10 +
      '  https://levython.github.io/documentation/';
  end;
end;

function InitializeSetup: Boolean;
var
  ExistingVersion: String;
begin
  Result := True;
  
  // Check for existing installation
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Levython', 'Version', ExistingVersion) then
  begin
    if MsgBox('Levython ' + ExistingVersion + ' is already installed.' + #13#10 + #13#10 +
              'Do you want to upgrade to version {#MyAppVersion}?', 
              mbConfirmation, MB_YESNO) = IDNO then
    begin
      Result := False;
    end;
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := '';
  // Could add pre-flight checks here
end;
