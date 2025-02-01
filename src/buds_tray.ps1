# This script should be executed with the following:
# PowerShell.exe -ExecutionPolicy Bypass -file '\path\to\buds_tray.ps1'


function Get-InstallPathFromRegistry {
    try {
        $installPath = Get-ItemPropertyValue -Path "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -Name "DYLANBUDSTRAY_PATH" -ErrorAction Stop
    } catch {
        $programFilesX86 = [System.Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
        $installPath = "$programFilesX86\DylanBudsTray" # Default installation path
    }
    return $installPath
}

# Path specific file references
$installPath = Get-InstallPathFromRegistry
$deviceFile = "$installPath\devices.txt"
$iconPath = "$installPath\bt_earbuds2.ico"


# Add assemblies for WPF
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')   
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
[System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration')
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms.ContextMenu')   

function Connect-Device {
    param (
        [string]$DeviceId
    )
    Write-Host "Connecting to Device ID: $DeviceId"
    # Note: bluetooth services: 111e (HFP Voice); 110b (A2DP Music)
    Start-Process "btcom" -ArgumentList "-r -b $DeviceId -s110b" -WindowStyle Hidden -Wait
    Start-Process "btcom" -ArgumentList "-c -b $DeviceId -s110b" -WindowStyle Hidden
}

$contextMenu = New-Object System.Windows.Forms.ContextMenu
$configMenu = New-Object System.Windows.Forms.MenuItem "Configure"
$openConfigFileMenuItem = New-Object System.Windows.Forms.MenuItem "Open devices config file"
$exitMenuItem = New-Object System.Windows.Forms.MenuItem "Exit"

# Read device details from file
if (Test-Path $deviceFile) {
    $devices = Get-Content $deviceFile | ForEach-Object {
        if (-not ($_ -match '^#')) {
			$device = $_ -split ","
			@{
				Name = $device[0]
				Id = $device[1]
			}
        }
    }

    foreach ($device in $devices) {
		Write-Host "Building Menu Item for $($device.Name): Device ID: $($device.Id)"
        $menuItem = New-Object System.Windows.Forms.MenuItem "Connect $($device.Name)"
        $menuItem.Add_Click({
			Connect-Device -DeviceId $device.Id
        }.GetNewClosure())
        $contextMenu.MenuItems.Add($menuItem)
    }
} else {
    Write-Host "Device file not found: $deviceFile"
}

$exitMenuItem.Add_Click({ $notifyIcon.Dispose();[System.Windows.Forms.Application]::Exit() })
$openConfigFileMenuItem.Add_Click({ Start-Process notepad.exe $deviceFile })
$configMenu.MenuItems.Add($openConfigFileMenuItem)
$contextMenu.MenuItems.Add($configMenu)
$contextMenu.MenuItems.Add($exitMenuItem)

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
$notifyIcon.ContextMenu = $contextMenu
$notifyIcon.Text = "Bluetooth Action Tray"
$notifyIcon.Visible = $true

# Use a Garbage collection to reduce Memory RAM
# https://dmitrysotnikov.wordpress.com/2012/02/24/freeing-up-memory-in-powershell-using-garbage-collector/
# https://docs.microsoft.com/fr-fr/dotnet/api/system.gc.collect?view=netframework-4.7.2
[System.GC]::Collect()


[void] [System.Windows.Forms.Application]::Run()
