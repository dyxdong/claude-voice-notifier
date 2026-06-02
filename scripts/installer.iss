; Inno Setup script for Claude Voice Notifier
; Pass MyAppVersion via ISCC /DMyAppVersion="v1.0.6" and AppVersion=/DAppVersion=1.0.6 or similar
#ifndef MyAppVersion
#define MyAppVersion "v1.0.0"
#endif

#ifndef AppVersion
#define AppVersion "1.0.0"
#endif

#ifndef AppPublisher
#define AppPublisher "Claude Voice Notifier"
#endif

#ifndef SourcePath
#define SourcePath "dist\\installer"
#endif

[Setup]
AppName=Claude Voice Notifier
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppVerName=Claude Voice Notifier {#AppVersion}
UninstallDisplayName=Claude Voice Notifier
DefaultDirName={pf}\Claude Voice Notifier
DefaultGroupName=Claude Voice Notifier
DisableDirPage=no
OutputBaseFilename=claude-voice-notifier-windows-x64-{#MyAppVersion}
SetupIconFile={#SourcePath}\app-icon.ico
UninstallDisplayIcon={#SourcePath}\app-icon.ico
Compression=lzma
SolidCompression=yes
ChangesEnvironment=yes

[Files]
Source: "{#SourcePath}\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Check: DirExists('{#SourcePath}')

[Icons]
Name: "{group}\Claude Voice Notifier"; Filename: "{app}\bin\ClaudeVoiceNotifier.exe"; IconFilename: "{app}\app-icon.ico"

[INI]
Filename: "{app}\desktop.ini"; Section: ".ShellClassInfo"; Key: "IconResource"; String: "{app}\app-icon.ico,0"
Filename: "{app}\desktop.ini"; Section: ".ShellClassInfo"; Key: "ConfirmFileOp"; String: "0"
Filename: "{app}\desktop.ini"; Section: ".ShellClassInfo"; Key: "NoSharing"; String: "1"
Filename: "{app}\desktop.ini"; Section: "ViewState"; Key: "Mode"; String: ""
Filename: "{app}\desktop.ini"; Section: "ViewState"; Key: "Vid"; String: ""
Filename: "{app}\desktop.ini"; Section: "ViewState"; Key: "FolderType"; String: "Generic"

[Run]
Filename: "cmd.exe"; Parameters: "/C attrib +s ""{app}"" && attrib +h +s ""{app}\desktop.ini"""; Flags: runhidden waituntilterminated
Filename: "{app}\bin\ClaudeVoiceNotifier.exe"; Description: "Launch Claude Voice Notifier"; Flags: nowait postinstall skipifsilent

; Run post-install PowerShell script as the original user to initialize per-user config and media
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\postinstall.ps1"" ""{app}"""; Flags: runhidden runasoriginaluser waituntilterminated

[UninstallRun]
Filename: "cmd.exe"; Parameters: "/C attrib -h -s ""{app}\desktop.ini"" & attrib -s ""{app}"""; Flags: runhidden waituntilterminated

[UninstallDelete]
Type: files; Name: "{app}\desktop.ini"
Type: dirifempty; Name: "{app}"

[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\bin"; Check: NeedsAddPath('{app}\bin')

[Code]
function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', OrigPath)
  then begin
    Result := True;
    exit;
  end;
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  Path: string;
  AppBinPath: string;
begin
  if CurUninstallStep = usUninstall then
  begin
    AppBinPath := ExpandConstant('{app}\bin');
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', Path) then
    begin
      StringChangeEx(Path, AppBinPath + ';', '', True);
      StringChangeEx(Path, AppBinPath, '', True);
      RegWriteExpandStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', Path);
    end;
  end;
end;

