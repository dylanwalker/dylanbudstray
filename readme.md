# DylansBudTray
DylanBudsTray is a windows system tray to facilitate bluetooth quick connect, because I use more than one pair of earbuds on multiple devices and got sick of waiting for windows to discover all the bluetooth devices just to click on the one I want to connect. With this tool you can right click on the system tray and select which bluetooth device you want to connect.


### How to Install
I really wanted to make a windows .msi installer for this program, but ended up spending way more time trying to get that working than writing the utility itself. So manual installation instructions follow below:


0) Requirements:
 a) You must install bluetooth command line tools ( https://bluetoothinstaller.com/bluetooth-command-line-tools )
 b) Ensure that you can run powershell scripts


1) Copy all files from .\src into %programfiles(x86)%\DylanBudsTray

2) Create a new task in Task Scheduler with the following:
Triggers
	At startup
	Delay task for: 10 minutes

Action
	Program/Script:
		cmd
	Arguments:
		/c start /min "" powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Program Files (x86)\DylanBudsTray\buds_tray.ps1"
		
		
For the task General->Security opions:
	Run only when the user is logged on
	Run with the highest priveleges
	Hidden
	
### How it works

I use a powershell script `buds_tray.ps1` to build the system tray from Windows Forms. There is an option to configure devices in the tray (simply opens up `devices.txt` from the installed folder). You can use `btdiscovery -s` from the command line to find the Id of the bluetooth device you want to add and name it whatever you want. A click on a device releases and then reconnects the A2DP Music service (110b) which should cause your system to reconnect to all services for that bt device (this works for all my earbud devices, but have not  tested extensively). If you want other services, you can edit the lines in `buds_tray.ps1` that call `btcom` and add whatever bluetooth service you want.
