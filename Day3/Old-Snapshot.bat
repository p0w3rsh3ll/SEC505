@ECHO OFF
REM **********************************************************************
REM     Name: SNAPSHOT.BAT 
REM  Version: 3.3
REM     Date: 2.Apr.2013
REM   Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
REM  Purpose: Dumps a vast amount of configuration data for the sake
REM           of auditing and forensics analysis.  Compare snapshot
REM           files created at different times to extract differences.
REM    Usage: Place the script into a directory where it is safe to
REM           create a subdirectory.  A subdirectory will be created
REM           by the script named after the computer, and in that
REM           subdirectory a variety of text files will be created
REM           which contain system configuration data.  Run the script
REM           with administrative privileges.  
REM    Notes: Script can run on Windows 7, Server 2008, or later, 
REM           and certain tools (listed below) must be available too;
REM           but it can be modified to run on Windows XP/2003 also.
REM           Depending on speed of system, script will require about 20
REM           minutes to run, and the output will be 130MB in
REM           size, hence, use NTFS compression or 7-Zip when archiving,
REM           which will reduce the drive space consumed by about 85%.
REM           If you must make the script run faster, disable the file 
REM           hashing at the end of the script (90% reduction in run time) 
REM           but note that this is one of the most useful parts.
REM           This is a starter script, please add more commands as you 
REM           wish; for example, there are forensics tools which can dump
REM           more detailed information in a variety of formats, such 
REM           as MAC times for the filesystem.  
REM    Legal: Public domain.  No rights reserved.  Script provided
REM           "AS IS" with no warranties or guarantees of any kind.
REM **********************************************************************
REM
REM  Tools required for this script to run must be in the PATH:
REM
REM      AUDITPOL.EXE        Built-in or free download from Microsoft.com.
REM      REG.EXE             Built-in or free download from Microsoft.com.
REM
REM      AUTORUNSC.EXE       http://www.microsoft.com/sysinternals/
REM      SHA256DEEP.EXE      http://md5deep.sourceforge.net
REM 
REM **********************************************************************



REM Set FOLDER variable to contain output files.  The format will
REM look like "SERVERNAME-2014-06-05-11-03" (-year-month-day-hour-minute).
FOR /F "TOKENS=1*  EOL=/ DELIMS= "  %%A IN ('DATE.EXE /t') DO SET STARTDATE=%%B
FOR /F "TOKENS=1,2 EOL=/ DELIMS=/ " %%A IN ('DATE.EXE /t') DO SET MM=%%B
FOR /F "TOKENS=1,2 EOL=/ DELIMS=/"  %%A IN ('echo %STARTDATE%') DO SET DD=%%B
FOR /F "TOKENS=2,3 EOL=/ DELIMS=/ " %%A IN ('echo %STARTDATE%') DO SET YYYY=%%B
FOR /F "TOKENS=1,2 EOL=/ DELIMS=:"  %%A IN ('TIME.EXE /t') DO SET HH=%%A
FOR /F "TOKENS=1,2 EOL=/ DELIMS=: " %%A IN ('TIME.EXE /t') DO SET MIN=%%B
SET FOLDER=%COMPUTERNAME%-%YYYY%-%MM%-%DD%-%HH%-%MIN%


REM If this script is run with File Explorer, the present working
REM directory becomes C:\Windows\System32, which is not good.  So
REM test for this, create C:\Temp, and switch there instead.
if %CD:~-7% == ystem32 mkdir %SystemDrive%\Temp 1>nul 2>nul & cd %SystemDrive%\Temp


REM Create folder in the present working directory and switch into it.
mkdir %FOLDER%
cd %FOLDER%


REM Create README.TXT file.
ECHO SYSTEM FORENSICS SNAPSHOT > README.TXT
ECHO Computer: %COMPUTERNAME% >> README.TXT 
ECHO Date: %DATE% >> README.TXT 
ECHO Time: %TIME% >> README.TXT  
ECHO User: %USERNAME%@%USERDOMAIN% >> README.TXT


REM MSINFO32.EXE Report
start /wait msinfo32.exe /report MSINFO32-Report.txt


REM Computer System 
wmic.exe computersystem list full > Computer-Info.txt


REM BIOS
wmic.exe bios list full > BIOS.txt


REM Environment Variables
set > Environment-Variables.txt


REM Users
wmic.exe useraccount list full /format:csv > Users.csv


REM Groups
wmic.exe path win32_group get /value /format:csv > Groups.csv


REM Group Members
wmic.exe path win32_groupuser get /value /format:csv > Group-Members.csv


REM Password And Lockout Policies
net.exe accounts > Password-And-Lockout-Policies.txt


REM Local Audit Policy
auditpol.exe /get /category:* > Audit-Policy.txt


REM SECEDIT Security Policy Export
secedit.exe /export /cfg SecEdit-Security-Policy.txt 1>nul 2>nul


REM Shared Folders
wmic.exe share list full /format:csv > Shared-Folders.csv


REM Networking Configuration
ipconfig.exe /all > Network-IPConfig.txt
netstat.exe -ano > Network-NetStat.txt
route.exe print > Network-Route.txt
nbtstat.exe -n  > Network-NbtStat.txt
netsh.exe winsock show catalog > Network-WinSock.txt
wmic.exe path win32_networkadapterconfiguration get /value /format:csv > Network-NIC.csv


REM Windows Firewall and IPSec Connection Rules
netsh.exe firewall show config verbose = enable  > Network-Firewall.txt
netsh.exe advfirewall show allprofiles  > Network-Firewall-Profiles.txt
netsh.exe advfirewall show global > Network-Firewall-Global-Settings.txt
netsh.exe advfirewall firewall show rule name=all > Network-Firewall-Rules.txt
netsh.exe advfirewall export "Network-Firewall-Export.wfw" 1>nul 2>nul
netsh.exe advfirewall consec show rule name=all > Network-Firewall-IPSec-Rules.txt


REM IPSec Configuration (XP/2003)
netsh.exe ipsec static show all > Network-IPSec-Static.txt
netsh.exe ipsec dynamic show all > Network-IPSec-Dynamic.txt


REM Processes
wmic.exe process list full /format:csv > Processes.csv


REM Drivers
wmic.exe sysdriver list full /format:csv > Drivers.csv


REM Services
wmic.exe service list full /format:csv > Services.csv


REM Registry Exports (Add more as you wish)
reg.exe export hklm\system\CurrentControlSet Registry-CurrentControlSet.txt /y 1>nul 2>nul
reg.exe export hklm\software\microsoft\windows\currentversion Registry-WindowsCurrentVersion.txt /y 1>nul 2>nul


REM Sysinternals AutoRuns
autorunsc.exe -accepteula -a -c 2>nul 1> AutoRuns.txt


REM Hidden Files With Last-Modified Dates
dir %SYSTEMDRIVE%\ /A:H /S /ON /T:W /N /R > FileSystem-Hidden-Files.txt


REM Files With Last-Modified Dates
dir %SYSTEMDRIVE%\ /A:-D /S /ON /T:W /N /R > FileSystem-Files.txt


REM NTFS Permissions And Integrity Labels
REM You might prefer this:  accesschk.exe -r %SYSTEMDRIVE%
icacls.exe %SYSTEMDRIVE% /t /c /q 2>nul > FileSystem-NTFS-Permissions.txt


REM SHA256 File Hashes
REM VERY TIME AND SPACE CONSUMING!
REM Add more paths as you wish of course...
sha256deep.exe -s "c:\*" 2>nul > Hashes-C.txt
sha256deep.exe -s "d:\*" 2>nul > Hashes-D.txt
sha256deep.exe -s -r "%PROGRAMFILES%\*" 2>nul > Hashes-ProgramFiles.txt 
sha256deep.exe -s -r "%SYSTEMROOT%\*" 2>nul > Hashes-SystemRoot.txt



REM ***************************************************
REM   Perform final tasks, such as writing to an event 
REM   log, cleaning up temp files, compressing the
REM   folder into an archive, moving the folder or
REM   archive into a shared folder, etc.
REM ***************************************************

REM Save information about files created to README.TXT.
REM The hash of the readme.txt file itself will be wrong of course.
echo. >> README.TXT
echo. >> README.TXT
echo ---------------------------------------------------------------- >> README.TXT
dir /t:w >> README.TXT
echo. >> README.TXT
echo. >> README.TXT
echo ---------------------------------------------------------------- >> README.TXT
sha256deep.exe -s * 2>nul >> README.TXT


REM Set permissions or read-only bit on files created.
REM     attrib.exe +R *.txt
REM     icacls.exe 


REM Delete any leftover temp files.
REM     del %TEMP%\snapshot-out.txt 1>nul 2>nul


REM Go back up to parent directory.
cd ..


REM Do you want to compress the %FOLDER% into a single zip archive?
REM Do you want to move that archive into a shared folder?
REM This is where you could add these additional commands.

