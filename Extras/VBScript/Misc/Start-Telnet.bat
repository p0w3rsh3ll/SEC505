@ECHO OFF
REM *************************************************************************
REM Author: Jason Fossen, Ver: 2.0, Date: 15.Mar.05 (www.ISAscripts.org)
REM
REM The first argument to the script should be the name of the
REM Windows telnet server to which you wish to connect.  You
REM must be a local administrator there, and both the local and
REM remote systems must be Windows XP or later. 
REM
REM The script will first attempt to overwrite the LOGIN.CMD
REM file at the target with the local copy of LOGIN.CMD. If this
REM process fails, the telnet session will be attempted anyway.
REM 
REM The script will verify that NTLM-only authentication is
REM configured at the server, quitting if this cannot be set
REM or confirmed.  Script will enable and start the telnet service
REM for the session, then stop and disable the telnet service
REM afterwards. 
REM 
REM Increase the ping count below (-n) if the telnet service is
REM slow to start at the remote server and you connect too quickly.
REM
REM WARNING: Telnet server is reconfigured to support *only* NTLM afterwards!
REM WARNING: Script attempts to overwrite LOGIN.CMD at target with local copy!
REM    
REM Script provided "AS IS" without warranties or guarantees of any kind.
REM
REM Tools used: SC.EXE, FINDSTR.EXE, TELNET.EXE, TLNTADMN.EXE, and PING.EXE
REM *************************************************************************


SETLOCAL
SET TARGET=%1
IF "%TARGET%"=="/?" SET TARGET=%5
IF "%TARGET%"=="-h" SET TARGET=%5
IF "%TARGET%"=="-help" SET TARGET=%5
IF "%TARGET%"=="/help" SET TARGET=%5
IF "%TARGET%"=="--help" SET TARGET=%5
IF "%TARGET%"=="" GOTO END

ECHO.
ECHO Configuring telnet server at %TARGET% to only support NTLM ...
tlntadmn.exe \\%TARGET% config sec=+ntlm-passwd 1>nul 2>nul || GOTO QUITWHENPLAINTEXTPOSSIBLE
tlntadmn.exe \\%TARGET% config | findstr.exe "Password" 1>nul 2>nul && GOTO QUITWHENPLAINTEXTPOSSIBLE

ECHO Starting telnet service at %TARGET% ...
sc.exe \\%TARGET% config tlntsvr start= demand 1>nul 2>nul
sc.exe \\%TARGET% start tlntsvr 1>nul 2>nul

ECHO Replacing LOGIN.CMD at %TARGET% with the local copy ...
net use V: \\%TARGET%\Admin$ /persistent:no 1>nul 2>nul || GOTO FAILCONTINUE
type %SYSTEMROOT%\System32\LOGIN.CMD > V:\System32\LOGIN.NEW || GOTO FAILCONTINUE
del V:\System32\LOGIN.CMD 1>nul 2>nul || GOTO FAILCONTINUE
rename V:\System32\LOGIN.NEW LOGIN.CMD 1>nul 2>nul || GOTO FAILCONTINUE 
net use V: /delete 1>nul 2>nul

:OPENTELNET
REM ************************************************************************
REM    The following ping command is just to add a pause before continuing;
REM    increase the ping count (-n switch) if it doesn't pause long enough.
REM ************************************************************************
ping.exe -n 4 127.0.0.1 1>nul 2>nul
ECHO Opening telnet session to %TARGET% ...
PAUSE
COLOR 1F
telnet.exe %TARGET%
COLOR
ECHO.
GOTO STOPTELNETSERVER

:QUITWHENPLAINTEXTPOSSIBLE
ECHO.
ECHO WARNING! Either the NTLM-only option was NOT set at %TARGET% or it could not 
ECHO be verified to have been set.  The telnet session was aborted for security.
ECHO Configure %TARGET% to only support NTLM authentication with TLNTADMN.EXE.
ECHO.
GOTO END

:STOPTELNETSERVER
ECHO Stopping telnet service at %TARGET% ...
sc.exe \\%TARGET% stop tlntsvr 1>nul 
ECHO Disabling telnet service at %TARGET% ...
sc.exe \\%TARGET% config tlntsvr start= disabled 1>nul 
sc.exe \\%TARGET% query tlntsvr | findstr.exe "RUNNING" 1>nul && COLOR 4F && ECHO *** Telnet service was NOT stopped! *** && ping.exe -n 4 127.0.0.1 1>nul 2>nul && COLOR
GOTO END

:FAILCONTINUE
ECHO *** Failed to replace LOGIN.CMD, but proceeding with telnet session anyway.
net use V: /delete 1>nul 2>nul
GOTO OPENTELNET

:END
IF "%TARGET%"=="" ECHO.
IF "%TARGET%"=="" ECHO START-TELNET.BAT [target] 
IF "%TARGET%"=="" ECHO.
IF "%TARGET%"=="" ECHO Pass in name or IP of target Windows telnet server as the first argument. 
IF "%TARGET%"=="" ECHO Local and remote machines must be Windows XP or later for script to work.
IF "%TARGET%"=="" ECHO Telnet service will be started, if necessary, then stopped and disabled 
IF "%TARGET%"=="" ECHO after your telnet session is finished. Only NTLM authentication is permitted.
IF "%TARGET%"=="" ECHO NOTE: Telnet server will be reconfigured to support only NTLM authentication!
IF "%TARGET%"=="" ECHO NOTE: LOGIN.CMD script on server will be replaced with the local copy!
IF "%TARGET%"=="" ECHO Telnet session will be attempted anyway if LOGIN.CMD cannot be replaced.
ECHO.
ENDLOCAL


