##############################################################################
#  Script: Show-ComputerInfo.ps1
#    Date: 30.May.2007
# Version: 1.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
#    SANS: Course SEC505 - Securing Windows and PowerShell Automation
# Purpose: Demo a sampling of the kinds of information queryable through WMI.
#   Legal: Public domain, no rights reserved.
##############################################################################

"`n"
"----------------------------------------------------------"
"   Computer Information"
"----------------------------------------------------------"
get-wmiobject -query "SELECT * FROM Win32_ComputerSystem" |
select-object Name,Domain,Description,Manufacturer,Model,NumberOfProcessors,`
TotalPhysicalMemory,SystemType,PrimaryOwnerName,UserName


"----------------------------------------------------------"
"   BIOS Information"
"----------------------------------------------------------"
get-wmiobject -query "SELECT * FROM Win32_BIOS" |
select-object Name,Version,SMBIOSBIOSVersion


"----------------------------------------------------------"
"   CPU Information"
"----------------------------------------------------------"
get-wmiobject -query "SELECT * FROM Win32_Processor" |
select-object Manufacturer,Name,CurrentClockSpeed,L2CacheSize


"----------------------------------------------------------"
"   Operating System Information"
"----------------------------------------------------------"
get-wmiobject -query "SELECT * FROM Win32_OperatingSystem" | 
select-object Caption,BuildNumber,Version,SerialNumber,ServicePackMajorVersion,InstallDate


"----------------------------------------------------------"
"   Name of Built-In Administrator Account (Even If Renamed)"
"----------------------------------------------------------"
get-wmiobject -query "SELECT * FROM Win32_UserAccount" |
where-object {$_.SID -match '-500$'} | 
select-object Name


"----------------------------------------------------------"
"   Installed Hotfixes"
"----------------------------------------------------------"
get-wmiobject -query "SELECT * FROM Win32_QuickFixEngineering" |
select-object HotFixID

