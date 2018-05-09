<##############################################################################
.SYNOPSIS
    Creates a folder with files which capture the current OS state.

.DESCRIPTION
    Creates a folder filled with CSV, XML and TXT files which capture
    the current operational state of the computer, such as running
    processes, services, user accounts, audit policies, shared folders,
    networking settings, and more.  These files can be used for threat
    hunting, auditing, compliance, and troubleshooting purposes.  

    The output folder will be named after the local host and the current
    date and time, e.g., .\COMPUTERNAME-Year-Month-Day-Hour-Minute.

    The commands creating the files are simple and can be edited by
    those without advanced scripting skills.  The files produced also
    can be compressed, copied, analyzed and compared without expensive
    forensics or analysis tools, such as Notepad++ or WinMerge.

    Script requires PowerShell 3.0, Windows 7, Server 2008, or later,
    and must be run with administrative privileges.  

    Most commands are built into PowerShell 3.0 and later, but some
    tools will need to be installed first in order to use them, such
    as AUTORUNSC.EXE (http://www.microsoft.com/sysinternals/) and
    SHA256DEEP.EXE (http://md5deep.sourceforge.net), which are not
    required, but very useful for snapshots.  Be aware, though, that
    producing thousands of file hashes may require a long time.  

.PARAMETER OutputParentFolder
    Optional path to the parent folder under which a new subfolder will
    be created to hold the snapshot files.  This is not the path to
    the output folder itself, which will be automatically created, but
    to its parent folder.  Defaults to $PWD, the present directory.
    Write access permission is required to the output folder.

.PARAMETER TextFileOutput
    Forces all output files to be flat TXT files instead of XML.

.PARAMETER Verbose
    Show progress information as the script is running.

.NOTES
    Version: 4.5
    Updated: 26.Oct.2017
     Author: Enclave Consulting LLC (http://www.sans.org/sec505)
      Legal: Public domain, provided "AS IS" without any warranties.

Requires -Version 3.0  
##############################################################################>

[CmdletBinding()]
Param ([String] $OutputParentFolder = ($Pwd.Path), [Switch] $TextFileOutput) 


# Verbose start time:
$StartTime = Get-Date 
Write-Verbose -Message ("Started: " + (Get-Date -Format 'F')) 



#.DESCRIPTION
#   Helper function to write output as XML (default) or as TXT (with -TextFileOutput).
#   Almost every command below pipes into this function.
function WriteOut ($FileName) 
{
    if ($TextFileOutput)
    { 
        Write-Verbose -Message ("Writing to " + ($FileName + ".txt")) 
        $Input | Format-List * | Out-File -Encoding UTF8 -FilePath ($FileName + ".txt") 
    } 
    else 
    { 
        Write-Verbose -Message ("Writing to " + ($FileName + ".xml")) 
        $Input | Export-Clixml -Encoding UTF8 -Path ($FileName + ".xml")
    } 
}



# Confirm that the destination PARENT folder exists:
if (-not (Test-Path -Path $OutputParentFolder -PathType Container))
{
    Write-Error -Message "$OutputParentFolder does not exist or is not accessible, exiting."
    Exit
}



# If this script is run with File Explorer, the present working
# directory becomes C:\Windows\System32, which is not good, so
# disallow $env:SystemRoot or anything underneath it:
if ( $OutputParentFolder -like ($env:SystemRoot + '*') )
{
    Write-Error -Message "Output folder cannot be under $Env:SystemRoot, and script must be run from within a command shell, exiting."
    Exit
}



# Record present directory in order to switch back to it later,
# and attempt to switch into $OutputParentFolder now:
$PresentDirectory = $Pwd
cd $OutputParentFolder
if (-not $?){ Write-Error -Message "Could not switch into $OutputParentFolder, exiting." ; Exit } 



# Set FOLDER variable to contain output files. The format will look
# like "COMPUTERNAME-2018-06-05-11-03" (computername-year-month-day-hour-minute).
$OutputFolder = $env:COMPUTERNAME + "-" + (Get-Date -Format 'yyyy-MM-dd-hh-mm') 
Write-Verbose -Message "Creating $(Join-Path -Path $OutputParentFolder -ChildPath $OutputFolder)" 


# Create the $Folder in the present working directory and switch into it:
mkdir $OutputFolder | out-null
if (-not $?){ Write-Error -Message "Could not create $OutputFolder, exiting." ; Exit } 

cd $OutputFolder

if ($pwd.Path -ne (Join-Path -Path $OutputParentFolder -ChildPath $OutputFolder))
{ Write-Error -Message "Could not switch into $OutputFolder, exiting." ; Exit } 



###############################################################################
#
# Create README.TXT file to identify this computer and snapshot.
# More text will be appended to the end of this file later in this script.
#
###############################################################################

$ReadmeText = @"
*SYSTEM CONFIGURATION SNAPSHOT
*Computer: $env:COMPUTERNAME
*HostName: $(hostname.exe)
*Box-Date: $(Get-Date -Format 'F')
*UTC-Date: $(Get-Date -Format 'U') 
*ZuluDate: $(Get-Date -Format 'u')
*PVersion: $($PSVersionTable.PSVersion.ToString())
*UserName: $env:USERNAME 
*User-Dom: $env:USERDOMAIN
"@

$ReadmeText | Out-File -Encoding UTF8 -FilePath .\README.TXT -Force

if (-not $?)
{ Write-Error -Message "Could not write to README.TXT, exiting." ; Exit } 
else
{ Write-Verbose -Message "Created README.TXT" } 



###############################################################################
# 
# Now run whatever commands you wish to capture operational state data.
# Please add more commands and use additional tools too, always piping
# the output of any command into the WriteOut function (defined above).
#
###############################################################################

# Computer System 
Get-CimInstance -ClassName Win32_ComputerSystem | WriteOut -FileName ComputerSystem


# BIOS
Get-CimInstance -ClassName Win32_BIOS | WriteOut -FileName BIOS


# Environment Variables
dir env:\ | WriteOut -FileName Environment-Variables


# Users
Get-CimInstance -ClassName Win32_UserAccount | WriteOut -FileName Users


# Groups
Get-CimInstance -ClassName Win32_Group | WriteOut -FileName Groups


# Group Members
Get-CimInstance -ClassName Win32_GroupUser | WriteOut -FileName Group-Members


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
Get-DnsClientNrptPolicy -Effective | WriteOut -FileName Name-Resolution-Policy-Table


# Windows Firewall and IPSec 
Get-NetConnectionProfile | WriteOut -FileName Network-Connection-Profiles
Get-NetFirewallProfile | WriteOut -FileName Network-Firewall-Profiles
Get-NetFirewallRule | WriteOut -FileName Network-Firewall-Rules
Get-NetIPsecRule | WriteOut -FileName Network-IPSec-Rules
netsh.exe advfirewall export Network-Firewall-Export.wfw | out-null 


# Processes
Get-Process -IncludeUserName | WriteOut -FileName Processes


# Drivers
Get-CimInstance -ClassName Win32_SystemDriver | WriteOut -FileName Drivers


# DirectX Diagnostics
dxdiag.exe /whql:off /64bit /t dxdiag.txt 


# Services
Get-Service | WriteOut -FileName Services


# Registry Exports (add more as you wish)
Write-Verbose -Message "Writing to registry files: *.reg" 
reg.exe export hklm\system\CurrentControlSet Registry-CurrentControlSet.reg /y | out-null 
reg.exe export hklm\software\microsoft\windows\currentversion Registry-WindowsCurrentVersion.reg /y | out-null 


# Generate an MSINFO32.EXE report, which includes lots of misc info.
Write-Verbose -Message "Writing to MSINFO32-Report.txt" 
msinfo32.exe /report MSINFO32-Report.txt


# Hidden Files and Folders 
dir -Path c:\ -Hidden -Recurse -ErrorAction SilentlyContinue | Select-Object FullName,Length,Mode,CreationTime,LastAccessTime,LastWriteTime | Export-Csv -Path FileSystem-Hidden-Files.csv


# Non-Hidden Files and Folders
dir -Path c:\ -Recurse -ErrorAction SilentlyContinue | Select-Object FullName,Length,Mode,CreationTime,LastAccessTime,LastWriteTime | Export-Csv -Path FileSystem-Files.csv


# NTFS Permissions And Integrity Labels
# This file can reach 100's of MB in size, so
# we'll limit this example to just System32:
icacls.exe c:\windows\system32 /t /c /q 2>$null | Out-File -FilePath FileSystem-NTFS-Permissions.txt



###############################################################################
#
#  The following commands require that various tools be installed and in the 
#  PATH, since they are not installed by default.  Uncomment the lines after 
#  installing the tools.
#
###############################################################################

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



###############################################################################
#
# Record snapshot metadata to README.TXT and Snapshot-File-Hashes.csv:
#
###############################################################################

# Save info about the snapshot output files to README.TXT:
'*Finished: ' + $(Get-Date -Format 'u') | Out-File -Encoding UTF8 -Append -FilePath README.TXT

"-" * 50 | Out-File -Encoding UTF8 -Append -FilePath README.TXT

dir | select Name,Length,LastWriteTime | Out-File -Encoding UTF8 -Append -FilePath README.TXT 



# Save hashes and full paths to the snapshot files to a CSV:
if (Get-Command -Name Get-FileHash -ErrorAction SilentlyContinue)
{
    $hashes = dir -File | Get-FileHash -Algorithm SHA256 -ErrorAction SilentlyContinue 
    $hashes | Export-Csv -Path Snapshot-File-Hashes.csv -Force  #cannot directly pipe
}



###############################################################################
#
#  Perform final tasks, such as writing to an event log, cleaning up temp files, 
#  compressing the folder into an archive, moving the archive into a shared folder,
#  etc. This can also be done in an external wrapper script run as a scheduled task.
#
###############################################################################

# Delete any leftover temp files?  What about the hashes list?  (del *.tmp) 

# Set read-only bit on files created?  (attrib.exe +R *.txt)

# Write to the event log about the snapshot process?  (write-eventlog)  



###############################################################################
#
# THIS COMMAND MUST BE LAST: Go back to the original working directory:
#
###############################################################################

Write-Verbose -Message "Saved files to $(Join-Path -Path $OutputParentFolder -ChildPath $OutputFolder)" 
Write-Verbose -Message ("Finished: " + (Get-Date -Format 'F')) 
$seconds = New-TimeSpan -Start $StartTime -End (Get-Date) | Select -ExpandProperty TotalSeconds
Write-Verbose -Message "Total run time = $seconds seconds"


cd $PresentDirectory


