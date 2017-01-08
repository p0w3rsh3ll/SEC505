#**********************************************************************
#     Name: SNAPSHOT.PS1 
#  Version: 4.0
#     Date: 26.Jan.2015
#   Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
#  Purpose: Dumps a vast amount of configuration data for the sake
#           of auditing and forensics analysis.  Compare snapshot
#           files created at different times to extract differences.
#    Usage: Place the script into a directory where it is safe to
#           create a subdirectory.  A subdirectory will be created
#           by the script named after the computer, and in that
#           subdirectory a variety of files will be created which
#           contain system configuration data.  Run the script
#           with administrative privileges.
#Requires -Version 3.0  
#    Notes: Script can run on Windows 7, Server 2008, or later, 
#           and certain tools (listed below) must be available too.
#           But, importanly, it does require PowerShell 3.0 or later.
#           If you must make the script run faster, disable the file 
#           hashing at the end of the script (90% reduction in run time) 
#           but note that this is one of the most useful parts.
#           This is a starter script, please add more commands as you 
#           wish; for example, there are forensics tools which can dump
#           more detailed information in a variety of formats, such 
#           as MAC times for the filesystem.  
#    Legal: Public domain.  No rights reserved.  Script provided
#           "AS IS" with no warranties or guarantees of any kind.
#**********************************************************************
#
#  Tools required for this script to run must be in the PATH:
#
#      AUDITPOL.EXE        Built-in or free download from Microsoft.com.
#      REG.EXE             Built-in or free download from Microsoft.com.
#
#      AUTORUNSC.EXE       http://www.microsoft.com/sysinternals/
#      SHA256DEEP.EXE      http://md5deep.sourceforge.net
# 
#**********************************************************************

Param ([Switch] $TextFileOutput) 


# Helper function to write output as XML (default) or as TXT (with -TextFileOutput).
# Almost every command below pipes into this function.
function WriteOut ($FileName) 
{
    if ($TextFileOutput){ $Input | Format-List * | Out-File -FilePath ($FileName + ".txt") } 
    else { $Input | Export-Clixml -Path ($FileName + ".xml") } 
}


# Set FOLDER variable to contain output files. The format will look
# like "SERVERNAME-2016-06-05-11-03" (-year-month-day-hour-minute).
$Now = Get-Date
$Folder = $env:COMPUTERNAME + "-" + $Now.Year + "-" + $Now.Month + "-" + $Now.Day + "-" + $Now.Hour + "-" + $Now.Minute


# If this script is run with File Explorer, the present working
# directory becomes C:\Windows\System32, which is not good.  So
# test for this, create C:\Temp, and switch there instead.
if ( $Pwd.Path -like '*ystem32')
{
    mkdir C:\Temp -ErrorAction SilentlyContinue | out-null 
    cd C:\Temp
}


# Create the $Folder in the present working directory and switch into it.
mkdir $Folder | out-null
cd $Folder


# Create README.TXT file in the present directory.
$ReadmeText = @"
SYSTEM FORENSICS SNAPSHOT
Computer: $Env:COMPUTERNAME
Date: $Now
UserName: $env:USERNAME 
UserDomain: $env:USERDOMAIN
"@

$ReadmeText | Out-File -FilePath .\README.TXT -Force



# Computer System 
Get-WmiObject -Class Win32_ComputerSystem | WriteOut -FileName ComputerSystem


# BIOS
Get-WmiObject -Class Win32_BIOS | WriteOut -FileName BIOS


# Environment Variables
dir env:\ | WriteOut -FileName Environment-Variables


# Users
Get-WmiObject -Class Win32_UserAccount | WriteOut -FileName Users


# Groups
Get-WmiObject -Class Win32_Group | WriteOut -FileName Groups


# Group Members
Get-WmiObject -Class Win32_GroupUser | WriteOut -FileName Group-Members


# Password And Lockout Policies
net.exe accounts | Out-File -FilePath Password-And-Lockout-Policies.txt


# Local Audit Policy
auditpol.exe /get /category:* | Out-File -FilePath Audit-Policy.txt


# SECEDIT Security Policy Export
secedit.exe /export /cfg SecEdit-Security-Policy.txt | out-null 


# Shared Folders
Get-SmbShare | WriteOut -FileName Shared-Folders


# Networking Configuration
Get-NetAdapter -IncludeHidden | WriteOut -FileName Network-Adapters
Get-NetIPAddress | WriteOut -FileName Network-IPaddresses
Get-NetTCPConnection -State Listen | Sort LocalPort | WriteOut -FileName Network-TCP-Listening-Ports
Get-NetUDPEndpoint | Sort LocalPort | WriteOut -FileName Network-UDP-Listening-Ports
Get-NetRoute | WriteOut -FileName Network-Route-Table
nbtstat.exe -n  | Out-File -FilePath Network-NbtStat.txt
netsh.exe winsock show catalog | Out-File -FilePath Network-WinSock.txt


# Windows Firewall and IPSec 
Get-NetConnectionProfile | WriteOut -FileName Network-Connection-Profiles
Get-NetFirewallProfile | WriteOut -FileName Network-Firewall-Profiles
Get-NetFirewallRule | WriteOut -FileName Network-Firewall-Rules
Get-NetIPsecRule | WriteOut -FileName Network-IPSec-Rules
netsh.exe advfirewall export Network-Firewall-Export.wfw | out-null 


# Processes
Get-Process -IncludeUserName | WriteOut -FileName Processes


# Drivers
Get-WmiObject -Class Win32_SystemDriver | WriteOut -FileName Drivers


# Services
Get-Service | WriteOut -FileName Services


# Generate an MSINFO32.EXE report, which includes lots of misc info.
msinfo32.exe /report MSINFO32-Report.txt


# Registry Exports (Add more as you wish)
reg.exe export hklm\system\CurrentControlSet Registry-CurrentControlSet.reg /y | out-null 
reg.exe export hklm\software\microsoft\windows\currentversion Registry-WindowsCurrentVersion.reg /y | out-null 


# Hidden Files and Folders 
dir -Path c:\ -Hidden -Recurse -ErrorAction SilentlyContinue | Select-Object FullName,Length,Mode,CreationTime,LastAccessTime,LastWriteTime | Export-Csv -Path FileSystem-Hidden-Files.csv


# Non-Hidden Files and Folders
dir -Path c:\ -Recurse -ErrorAction SilentlyContinue | Select-Object FullName,Length,Mode,CreationTime,LastAccessTime,LastWriteTime | Export-Csv -Path FileSystem-Files.csv


# NTFS Permissions And Integrity Labels
# This file can reach 100's of MB in size, so
# we'll limit this example to just System32:
icacls.exe c:\windows\system32 /t /c /q 2>$null | Out-File -FilePath FileSystem-NTFS-Permissions.txt



##########################################################################################
#
#  The following commands require that various tools be installed and in the PATH, since
#  they are not installed by default.  Uncomment the lines after installing the tools.
#
##########################################################################################


# Sysinternals AutoRuns; not in the PATH by default even when
# installed; get from microsoft.com/sysinternals

#########   autorunsc.exe -accepteula -a -c | Out-File -FilePath AutoRuns.csv



# SHA256 File Hashes
# Takes a long time! Requires lots of space!
# Add more paths as you wish of course, this is just to get started.
# sha256deep.exe is used instead of Get-FileHash because it's faster.

#########   sha256deep.exe -s "c:\*" | Out-File -FilePath Hashes-C.txt
#########   sha256deep.exe -s "d:\*" | Out-File -FilePath Hashes-D.txt
#########   sha256deep.exe -s -r ($env:PROGRAMFILES + "\*") | Out-File -FilePath Hashes-ProgramFiles.txt 
#########   sha256deep.exe -s -r ($env:SYSTEMROOT + "\*") | Out-File -FilePath Hashes-SystemRoot.txt



# Save hashes of the snapshot files to README.TXT.
"`n`n"   | Out-File -Append -FilePath README.TXT
"-" * 50 | Out-File -Append -FilePath README.TXT
dir      | Out-File -Append -FilePath README.TXT
"`n`n"   | Out-File -Append -FilePath README.TXT
"-" * 50 | Out-File -Append -FilePath README.TXT

#########   sha256deep.exe -s * | Out-File -Append -FilePath README.TXT

# But exclude the hash of README.TXT itself, which will be wrong of course.
# Ideally, the README file would be digitally signed now too.
(Get-Content -Path README.TXT) | Select-String -Pattern 'README' -NotMatch | Set-Content -Path README.TXT





##########################################################################################
#
#  Perform final tasks, such as writing to an event log, cleaning up temp files, 
#  compressing the folder into an archive, moving the archive into a shared folder, etc.
#
##########################################################################################


# Delete any leftover temp files?  (del *.tmp) 

# Set read-only bit on files created?  (attrib.exe +R *.txt)

# Go back up to parent directory.
cd ..


