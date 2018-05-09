##############################################################################
#  Script: Show-ComputerInfo.ps1
# Updated: 24.Oct.2017
# Created: 30.May.2007
# Version: 2.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
#    SANS: Course SEC505 - Securing Windows and PowerShell Automation
# Purpose: Demo a sampling of the kinds of information queryable through WMI.
#   Legal: Public domain, no rights reserved.
##############################################################################

"`n"
"----------------------------------------------------------"
"   Computer Information"
"----------------------------------------------------------"
Get-CimInstance -query "SELECT * FROM Win32_ComputerSystem" |
Select-Object Name,Domain,Description,Manufacturer,Model,NumberOfProcessors,`
TotalPhysicalMemory,SystemType,PrimaryOwnerName,UserName


"----------------------------------------------------------"
"   BIOS Information"
"----------------------------------------------------------"
Get-CimInstance -query "SELECT * FROM Win32_BIOS" |
Select-Object Name,Version,SMBIOSBIOSVersion


"----------------------------------------------------------"
"   CPU Information"
"----------------------------------------------------------"
Get-CimInstance -query "SELECT * FROM Win32_Processor" |
Select-Object Manufacturer,Name,CurrentClockSpeed,L2CacheSize


"----------------------------------------------------------"
"   Operating System Information"
"----------------------------------------------------------"
Get-CimInstance -query "SELECT * FROM Win32_OperatingSystem" | 
Select-Object Caption,BuildNumber,Version,SerialNumber,ServicePackMajorVersion,InstallDate


"----------------------------------------------------------"
"   Name of Built-In Administrator Account (Even If Renamed)"
"----------------------------------------------------------"
Get-CimInstance -query "SELECT * FROM Win32_UserAccount" |
Where-Object {$_.SID -match '-500$'} | 
Select-Object Name


"----------------------------------------------------------"
"   Installed Hotfixes"
"----------------------------------------------------------"
Get-CimInstance -query "SELECT * FROM Win32_QuickFixEngineering" |
Select-Object HotFixID

