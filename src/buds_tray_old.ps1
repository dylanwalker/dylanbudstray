# This script should be executed with the following:
# PowerShell.exe -ExecutionPolicy Bypass -file '\path\to\buds_tray.ps1'

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
    Start-Process "btcom" -ArgumentList "-r -b $DeviceId -s110b" -WindowStyle Hidden -Wait
    Start-Process "btcom" -ArgumentList "-c -b $DeviceId -s110b" -WindowStyle Hidden
}

$contextMenu = New-Object System.Windows.Forms.ContextMenu
$exitMenuItem = New-Object System.Windows.Forms.MenuItem "Exit"

# Read device details from file
$deviceFile = "C:\Program Files (x86)\DylanBudsTray\devices.txt"
if (Test-Path $deviceFile) {
    $devices = Get-Content $deviceFile | ForEach-Object {
        $device = $_ -split ","
        @{
            Name = $device[0]
            Id = $device[1]
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
$contextMenu.MenuItems.Add($exitMenuItem)

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$iconPath = "C:\Program Files (x86)\DylanBudsTray\bt_earbuds2.ico"
$notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
$notifyIcon.ContextMenu = $contextMenu
$notifyIcon.Text = "Bluetooth Action Tray"
$notifyIcon.Visible = $true

# Make PowerShell Disappear
#$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
#$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
#$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)

# Use a Garbage collection to reduce Memory RAM
# https://dmitrysotnikov.wordpress.com/2012/02/24/freeing-up-memory-in-powershell-using-garbage-collector/
# https://docs.microsoft.com/fr-fr/dotnet/api/system.gc.collect?view=netframework-4.7.2
[System.GC]::Collect()

#$appContext = New-Object System.Windows.Forms.ApplicationContext
#[void] [System.Windows.Forms.Application]::Run($appContext)
[void] [System.Windows.Forms.Application]::Run()
