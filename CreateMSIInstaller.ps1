Import-Module -Name psmsi

# Get the directory of the current script
#$scriptDir = (Get-Location -PSProvider FileSystem).ProviderPath

# Define paths and variables relative to the script location
#$sourceDir = Join-Path -Path $scriptDir -ChildPath "src"
#$installDir = "$env:ProgramFiles(x86)\DylanBudsTray"
#$msiOutput = Join-Path -Path $scriptDir -ChildPath "DylanBudsTrayInstaller.msi"
#$scheduledTaskScript = Join-Path -Path $sourceDir -ChildPath "InstallScheduledTask.ps1"

$file = New-InstallerFile -Source .\test.ps1 -Id 'InstallScheduledTaskId'
$customAction = New-InstallerCustomAction -FileId 'InstallScheduledTaskId' -RunOnInstall -Arguments "-ExecutionPolicy Bypass -NoProfile"

# Create the MSI installer
New-Installer -ProductName "DylanBudsTray" -UpgradeCode "1ddfffd3-252a-4481-81c6-e3db56f9f491" -Content {
	New-InstallerDirectory -PredefinedDirectory "ProgramFilesFolder" -Content {
		New-InstallerDirectory -DirectoryName "DylanBudsTray" -Content {
			New-InstallerFile -Source .\src\buds_tray.ps1
			New-InstallerFile -Source .\src\devices.txt
			New-InstallerFile -Source .\src\bt_earbuds.ico
			New-InstallerFile -Source .\src\bt_earbuds2.ico
			New-InstallerFile -Source .\src\InstallScheduledTask.ps1 #-Id 'InstallScheduledTaskId'
			}
		}
	} -CustomAction $customAction -OutputDirectory . -RequiresElevation -Manufacturer "Dylan Walker"
