
# To see the objects in a particular class in root\CIMv2 and show all their properties:

get-wmiobject -query "select * from Win32_OperatingSystem"  -namespace "root\cimv2" | format-list *

# Next line does the same thing since CIMv2 is the default.

get-wmiobject -query "select * from Win32_OperatingSystem" | format-list *




# To see a variety of computer-related information:

"----------------------------------------------------------"
"   Computer Information "
"----------------------------------------------------------"
get-wmiobject -query "SELECT * FROM Win32_ComputerSystem" |
select-object Name,Domain,Description,Manufacturer,Model, `
NumberOfProcessors,TotalPhysicalMemory,SystemType, `
PrimaryOwnerName,UserName


"----------------------------------------------------------"
"   BIOS Information "
"----------------------------------------------------------"
get-wmiobject -query "SELECT * FROM Win32_BIOS" |
select-object Name,Version,SMBIOSBIOSVersion


"----------------------------------------------------------"
"   CPU Information "
"----------------------------------------------------------"
get-wmiobject -query "SELECT * FROM Win32_Processor" |
select-object Manufacturer,Name,CurrentClockSpeed


"----------------------------------------------------------"
"   Operating System Information "
"----------------------------------------------------------"
get-wmiobject -query "SELECT * FROM Win32_OperatingSystem" | 
select-object Caption,BuildNumber,Version,SerialNumber, `
ServicePackMajorVersion,InstallDate


"----------------------------------------------------------"
"   Name of Built-In Administrator Account "
"----------------------------------------------------------"
get-wmiobject -query "SELECT * FROM Win32_UserAccount" |
where-object {$_.SID -match '-500$'} | 
select-object Name


"----------------------------------------------------------"
"   Installed Hotfixes "
"----------------------------------------------------------"
get-wmiobject -q "SELECT * FROM Win32_QuickFixEngineering" |
select-object HotFixID


"----------------------------------------------------------"
"   Installed Software "
"----------------------------------------------------------" 
Get-WmiObject -Query "select * from win32_product" | 
format-list Vendor,Name,Version,InstallDate

