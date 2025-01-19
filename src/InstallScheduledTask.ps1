#Set-Content -Path "$env:ProgramFiles(x86)\DylanBudsTray\done.txt" -Value "started script"
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Write-Host "$user"
$action = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument '/c start /min "" powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "$env:ProgramFiles(x86)\DylanBudsTray\buds_tray.ps1"'
$trigger = New-ScheduledTaskTrigger -AtStartup
$trigger.Delay="PT1M"
#$principal = New-ScheduledTaskPrincipal -UserId "BUILTIN\Users" -LogonType Interactive -RunLevel Highest
#$principal = New-ScheduledTaskPrincipal -GroupId "INTERACTIVE" -RunLevel Highest
$principal = New-ScheduledTaskPrincipal -UserId "$user" -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -RunOnlyIfIdle

Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings -TaskName "DylanBudsTrayTask" -Description "Runs DylanBudsTray at startup with a 10-minute delay"

Start-ScheduledTask -TaskName "DylanBudsTrayTask"
#Set-Content -Path "$env:ProgramFiles(x86)\DylanBudsTray\done.txt" -Value "finished script"
