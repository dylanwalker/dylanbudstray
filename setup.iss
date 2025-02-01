[Setup]
AppName=DylanBudsTray
AppVersion=1.0.0
AppVerName=DylanBudsTray
DefaultDirName={commonpf32}\DylanBudsTray
DefaultGroupName=DylanBudsTray
OutputBaseFilename=dylanbudstray
ArchitecturesInstallIn64BitMode=x64compatible
Compression=lzma
SolidCompression=yes
MinVersion=10.0.22000
OutputDir=installer
PrivilegesRequired=admin 

[Files]
Source: "src\buds_tray.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\devices.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\bt_earbuds.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\bt_earbuds2.ico"; DestDir: "{app}"; Flags: ignoreversion


[Run]
//Filename: "{cmd}"; Parameters: "/C schtasks /create /tn ""DylanBudsTray"" /tr ""\""powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\buds_tray.ps1""\"""" /sc onlogon /rl highest /f"; Flags: runhidden
Filename: "schtasks.exe"; Parameters: "/Create /TN ""DylanBudsTray"" /TR ""powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File {app}\buds_tray.ps1"" /SC onlogon /rl highest /f"; Flags: runhidden
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\buds_tray.ps1"""; WorkingDir: {win}; Flags: shellexec runhidden

[UninstallRun]
Filename: "{cmd}"; Parameters: "/C schtasks /delete /tn ""DylanBudsTray"" /f"; Flags: runhidden; RunOnceId: "DeleteDylanBudsTrayTask"

[UninstallDelete]
Type: filesandordirs; Name: "{app}"