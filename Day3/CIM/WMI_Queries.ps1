
# To see the objects in a particular class in root\CIMv2 and show all their properties:

Get-CimInstance -Query "select * from Win32_OperatingSystem" -Namespace "root\cimv2" | Select *

# Next line does the same thing since CIMv2 is the default.

Get-CimInstance -Query "select * from Win32_OperatingSystem" | Select *




# To see a variety of computer-related information:

"----------------------------------------------------------"
"   Computer Information "
"----------------------------------------------------------"
get-ciminstance -query "SELECT * FROM Win32_ComputerSystem" |
select-object Name,Domain,Description,Manufacturer,Model, `
NumberOfProcessors,TotalPhysicalMemory,SystemType, `
PrimaryOwnerName,UserName


"----------------------------------------------------------"
"   BIOS Information "
"----------------------------------------------------------"
get-ciminstance -query "SELECT * FROM Win32_BIOS" |
select-object Name,Version,SMBIOSBIOSVersion


"----------------------------------------------------------"
"   CPU Information "
"----------------------------------------------------------"
get-ciminstance -query "SELECT * FROM Win32_Processor" |
select-object Manufacturer,Name,CurrentClockSpeed


"----------------------------------------------------------"
"   Operating System Information "
"----------------------------------------------------------"
get-ciminstance -query "SELECT * FROM Win32_OperatingSystem" | 
select-object Caption,BuildNumber,Version,SerialNumber, `
ServicePackMajorVersion,InstallDate


"----------------------------------------------------------"
"   Name of Built-In Administrator Account "
"----------------------------------------------------------"
get-ciminstance -query "SELECT * FROM Win32_UserAccount" |
where-object {$_.SID -match '-500$'} | 
select-object Name


"----------------------------------------------------------"
"   Installed Hotfixes "
"----------------------------------------------------------"
Get-CimInstance -Query "SELECT * FROM Win32_QuickFixEngineering" 

