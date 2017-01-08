@ECHO OFF
REM **************************************************************************
REM Creates a new IIS website in a new site root folder, creates administrative
REM groups, and then sets some NTFS permissions. See /? help or read comments 
REM below for details.  Requires ICACLS.EXE and APPCMD.EXE on Win2008 or later.  
REM Script must be located and run from the parent directory of the subfolder 
REM that will be the root folder of the new web site.  You must be an administrator.
REM
REM SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
REM USE AT YOUR OWN RISK.  Public domain.  ( www.EnclaveConsulting.com ) 
REM
REM Version: 1.0.     Last Updated: 6.Oct.2008   Author: Jason Fossen
REM **************************************************************************


SETLOCAL

REM Detect if the user wants to see help.
SET FQDN=%1
IF "%FQDN%" == ""   GOTO SHOWHELPANDQUIT
IF "%FQDN%" == " "  GOTO SHOWHELPANDQUIT
IF "%FQDN%" == "/?" GOTO SHOWHELPANDQUIT
IF "%FQDN%" == "-h" GOTO SHOWHELPANDQUIT

REM Create the Browsers group for the web site (optional).
REM net.exe localgroup Browsers_%FQDN% /ADD /COMMENT:"IIS website group with Read access."

REM Create the WebMasters group for the site.
net.exe localgroup WebMasters_%FQDN% /ADD /COMMENT:"IIS website group with Full Control access."

REM Create folder for new site in the current directory named after its FQDN.
mkdir %FQDN%

REM Remove Read-Only, System and Hidden attributes from folder, just in case.
attrib.exe -R -H -S %FQDN% /S /D 

REM Set Full-Control NTFS perms on folder for the Administrators group, Local 
REM System, and the new WebMasters group, erasing all other perms.  You must be an Admin!
icacls.exe %FQDN% /inheritance:r /grant:r BUILTIN\Administrators:(OI)(CI)(F) 
icacls.exe %FQDN% /grant "NT AUTHORITY\SYSTEM":(OI)(CI)(F)
icacls.exe %FQDN% /grant WebMasters_%FQDN%:(OI)(CI)(F)

REM Set the Read+Execute NTFS permissions on root folder for IUSR and Network Service.
REM icacls.exe %FQDN% /grant Browsers_%FQDN%:(OI)(CI)(RX) 
icacls.exe %FQDN% /grant "NT AUTHORITY\IUSR":(OI)(CI)(RX) 
icacls.exe %FQDN% /grant "NT AUTHORITY\NETWORK SERVICE":(OI)(CI)(RX) 

REM Create the web site and auto-generate the site ID number; set to require a host header of %FQDN%; use default app pool.  
%WinDir%\system32\inetsrv\appcmd.exe add site /name:%FQDN% /bindings:http/*:80:%FQDN% /physicalPath:%CD%\%FQDN%


GOTO QUIT


:SHOWHELPANDQUIT
ECHO.
ECHO IIS_NEW_WEBSITE.BAT fqdn 
ECHO.  
ECHO     fqdn = The fully qualified domain name of the new web site,
ECHO            e.g., "www.mydomain.com", but without the quotes.
ECHO.  
ECHO     This script runs only on IIS 7.0 and later (not IIS 5.0/6.0).
ECHO.
ECHO     This script will create a new folder named after the FQDN of the
ECHO     web site, create local groups with the FQDN incorporated into their 
ECHO     names, then set NTFS permissions with the ICACLS.EXE tool for these 
ECHO     new groups.  It will then create that site in IIS using APPCMD.EXE.  
ECHO     The intent is to simplify and automate the creation of new IIS web 
ECHO     sites with appropriate permissions.
ECHO.     
ECHO     You must run this script from the parent folder which contains your
ECHO     subfolders that are root folders for your IIS web sites.  You must
ECHO     have ICACLS.EXE in your search PATH.  You must be a member of the 
ECHO     local Administrators group. 
ECHO.     
ECHO     SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
ECHO     USE AT YOUR OWN RISK. Public domain. ( www.EnclaveConsulting.com )
ECHO.     
GOTO QUIT

:QUIT
ENDLOCAL
REM End of Script *************************************************************
