@ECHO OFF
REM Toggles the ISA Server Firewall Client from enabled to disabled and vice versa.
REM Designed for version 4.0.3439, but should work with later versions too.
REM Download the Firewall Client Tool (fwctool.exe) from Microsoft for free.
REM
REM The Firewall Client Tool (fwctool.exe) must be in the PATH, e.g., C:\Windows\System32\
REM or you can edit this script to include the full path to that tool (KB886993). 
REM Another option is to put this batch script into the same folder as fwctool.exe,
REM create a shortcut to this batch script on the user's desktop or Start menu,
REM configure the shortcut to run the program Minimized, and, if necessary, set the
REM working folder to the folder of the fwctool.exe.  This prevents the CMD shell
REM window from momentarily flashing in/out of the foreground too.
REM
REM SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND. USE AT
REM YOUR OWN RISK.  ( www.ISAscripts.org )

fwctool.exe printconfig | find.exe "Disable:                       Yes" 1>nul 2>nul
 
IF %ERRORLEVEL% == 0 (
    fwctool.exe enable 1>nul 2>nul
) ELSE (
    fwctool.exe disable 1>nul 2>nul
)

