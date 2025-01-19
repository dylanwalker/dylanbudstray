# This script should be executed with the following:
# PowerShell.exe -ExecutionPolicy Bypass -file '\path\to\buds_tray.ps1'


# Add assemblies for WPF
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')   
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
[System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration')
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms.ContextMenu')   


function Connect-Buds1 {
    Start-Process "btcom" -ArgumentList "-r -b 58:A6:39:91:BB:1F -s110b" -WindowStyle Hidden -Wait
    Start-Process "btcom" -ArgumentList "-c -b 58:A6:39:91:BB:1F -s110b" -WindowStyle Hidden
}

function Connect-Buds2 {
    Start-Process "btcom" -ArgumentList "-r -b 4C:66:A6:B0:AD:31 -s110b" -WindowStyle Hidden -Wait
    Start-Process "btcom" -ArgumentList "-c -b 4C:66:A6:B0:AD:31 -s110b" -WindowStyle Hidden
}

$contextMenu = New-Object System.Windows.Forms.ContextMenu
$connectBuds1MenuItem = New-Object System.Windows.Forms.MenuItem "Connect Buds+"
$connectBuds2MenuItem = New-Object System.Windows.Forms.MenuItem "Connect Buds2"
$exitMenuItem = New-Object System.Windows.Forms.MenuItem "Exit"

$connectBuds1MenuItem.Add_Click({ Connect-Buds1 })
$connectBuds2MenuItem.Add_Click({ Connect-Buds2 })
$exitMenuItem.Add_Click({ $notifyIcon.Dispose();[System.Windows.Forms.Application]::Exit() })

$contextMenu.MenuItems.Add($connectBuds1MenuItem)
$contextMenu.MenuItems.Add($connectBuds2MenuItem)
$contextMenu.MenuItems.Add($exitMenuItem)

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$iconPath = "C:\Program Files (x86)\DylanBudsTray\bt_earbuds2.ico"
$notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
#$notifyIcon.Icon = [System.Drawing.SystemIcons]::Information
$notifyIcon.ContextMenu = $contextMenu
$notifyIcon.Text = "Bluetooth Action Tray"
$notifyIcon.Visible = $true

# Make PowerShell Disappear
#$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
#$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
#$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)

# Use a Garbage colection to reduce Memory RAM
# https://dmitrysotnikov.wordpress.com/2012/02/24/freeing-up-memory-in-powershell-using-garbage-collector/
# https://docs.microsoft.com/fr-fr/dotnet/api/system.gc.collect?view=netframework-4.7.2
[System.GC]::Collect()

#$appContext = New-Object System.Windows.Forms.ApplicationContext
#[void] [System.Windows.Forms.Application]::Run($appContext)
[void] [System.Windows.Forms.Application]::Run()
