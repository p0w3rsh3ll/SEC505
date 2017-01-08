@ECHO OFF
REM **************************************************************************
REM Creates IIS website with new site root folder, IUSR account, administrative
REM groups, and sets proper NTFS permissions. See /? help or read comments 
REM below for details.  Requires XCACLS.EXE from the Windows Support Tools and
REM the ADSUTIL.VBS script from \InetPub\AdminScripts\ in order to work.
REM Script must be located and run from the parent directory of the subfolder 
REM that will be the root folder of the new web site.  You must be an admin.
REM
REM SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
REM USE AT YOUR OWN RISK.  Public domain.  ( www.ISAscripts.org )
REM
REM Version: 1.0.     Last Updated: 6.Sep.2005    Author: Jason Fossen
REM **************************************************************************






SETLOCAL
SET FQDN=%1
IF "%FQDN%" == ""   GOTO SHOWHELPANDQUIT
IF "%FQDN%" == " "  GOTO SHOWHELPANDQUIT
IF "%FQDN%" == "/?" GOTO SHOWHELPANDQUIT
IF "%FQDN%" == "-h" GOTO SHOWHELPANDQUIT

REM Make an IUSR anonymous account for the site.
net.exe user IUSR_%FQDN% "temp-password" /ADD /COMMENT:"Anonymous account for a web site in IIS." /EXPIRES:NEVER /FULLNAME:"IUSR_%FQDN%"

REM Change password to something more difficult to crack.
SET PASSWORD=5U3b~.;p%DATE%$Sqz8x4H%TIME%y%USERNAME%m~#~vIi%FQDN%rP7#rB4!
net.exe user IUSR_%FQDN% "%PASSWORD%"

REM Create the Browsers group for the web site.
net.exe localgroup Browsers_%FQDN% /ADD /COMMENT:"IIS website group with Read access."

REM Put IUSR account into the Browsers group.
net.exe localgroup Browsers_%FQDN% IUSR_%FQDN% /ADD

REM Create the WebMasters group for the site.
net.exe localgroup WebMasters_%FQDN% /ADD /COMMENT:"IIS website group with Full Control access."

REM Add the local Administrator account to the WebMasters group, just in case.
net.exe localgroup WebMasters_%FQDN% Administrator /ADD

REM Create folder for new site in the current directory named after its FQDN.
mkdir %FQDN%

REM Remove Read-Only, System and Hidden attributes from folder, just in case.
attrib.exe -R -H -S %FQDN% /S /D 

REM Set Full-Control NTFS perms on folder for the Administrators group and 
REM Local System, erase all other perms (no /E switch). You must be an Admin!
xcacls.exe %FQDN% /T /G Administrators:F /Y 
xcacls.exe %FQDN% /T /E /G System:F /Y 

REM Add Full-Control NTFS permissions on root folder for the WebMasters group.
xcacls.exe %FQDN% /T /E /G WebMasters_%FQDN%:F /Y 

REM Set Read-Only NTFS permissions on root folder for the Browsers group.
xcacls.exe %FQDN% /T /E /G Browsers_%FQDN%:E /Y 

REM Get the full path to the new web site root folder into a temp file, use
REM that to create the web site object in IIS, then delete the temp file.
DIR /S /B | find.exe "\%FQDN%" | find.exe /v "%FQDN%\" > temp49.txt
FOR /F %%i IN (temp49.txt) DO cscript.exe %SystemRoot%\System32\iisweb.vbs /create %%i "%FQDN%" /b 80 /d %FQDN% > temp51.txt
DEL temp49.txt

REM The FOR command just above saved the output of the IISWEB.VBS script to a
REM temp file (temp51.txt).  Extract the metabase path info from this file. 
REM The data will look like "Metabase Path = W3SVC/1723980055".
find.exe "Metabase Path" temp51.txt > temp52.txt
DEL temp51.txt

REM Try to find the adsutil.vbs script. Assume it's in \System32 if not found,
REM hence, put a copy there if you don't want it in \InetPub\AdminScripts\.
SET PATHTOADSUTIL=%SystemDrive%\InetPub\AdminScripts\adsutil.vbs
IF NOT EXIST %PATHTOADSUTIL% SET PATHTOADSUTIL=%SystemRoot%\System32\adsutil.vbs
IF NOT EXIST %PATHTOADSUTIL% ECHO Could not find the ADSUTIL.VBS script; the correct IUSR account not set in IIS web site.

REM Now use adsutil.vbs script to set the IUSR account for the new site.
REM The metabase key was extracted from the output of iisweb.vbs above.
FOR /F "tokens=2 delims=/" %%i IN (temp52.txt) DO cscript.exe %PATHTOADSUTIL% SET W3SVC/%%i/Root/AnonymousUserName "IUSR_%FQDN%"

REM Setting the password for a local IUSR account is not needed and is a risk; only set for domain accounts.
REM FOR /F "tokens=2 delims=/" %%i IN (temp52.txt) DO cscript.exe %PATHTOADSUTIL% SET W3SVC/%%i/Root/AnonymousUserPass "%PASSWORD%"
DEL temp52.txt 
SET PASSWORD=NotTheRealPassword

GOTO QUIT


:SHOWHELPANDQUIT
ECHO.
ECHO IIS_NEW_WEBSITE.BAT fqdn 
ECHO.  
ECHO     fqdn = The fully qualified domain name of the new web site,
ECHO            e.g., "www.mydomain.com", but without the quotes.
ECHO.  
ECHO     This script will create a new folder named after the FQDN of the
ECHO     web site, create an IUSR account and local groups with the FQDN
ECHO     incorporated into their names, then set NTFS permissions with the
ECHO     XCACLS.EXE tool for these new groups.  It will then create that
ECHO     site in IIS using IISWEB.VBS and set the correct IUSR account for
ECHO     it with ADSUTIL.VBS.  The intent is to simplify and automate the 
ECHO     creation of new IIS web sites with appropriate permissions.
ECHO.     
ECHO     You must run this script from the parent folder which contains your
ECHO     subfolders that are root folders for your IIS web sites.  You must
ECHO     have XCACLS.EXE from the Windows Support Tools in your search PATH.
ECHO     The built-in IISWEB.VBS script must be in its default location,
ECHO     which is %SystemRoot%\System32\iisweb.vbs.  The built-in ADSUTIL.VBS
ECHO     script must either be in its default location, which is %SystemDrive%\
ECHO     InetPub\AdminScripts\adsutil.vbs, or have been copied to the 
ECHO     %SystemRoot%\System32\ folder, which is probably safer anyway.
ECHO     You must be a member of the local Administrators group.  Edit the 
ECHO     script if you want it to create global accounts and groups instead 
ECHO     of local ones, since the script defaults to creating only locals.
ECHO.     
ECHO     SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
ECHO     USE AT YOUR OWN RISK. Public domain. ( www.ISAscripts.org )
ECHO.     
GOTO QUIT

:QUIT
ENDLOCAL
REM End of Script *************************************************************
