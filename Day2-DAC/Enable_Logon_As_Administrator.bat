@ECHO OFF
REM **********************************************************************
REM This batch script enables logon as the Administrator account.
REM You must run it with administrative privileges.
REM Applies to Windows Vista/7/8 and later.
REM **********************************************************************

echo Windows Registry Editor Version 5.00 > %TEMP%\888FFF.reg
echo. >> %TEMP%\888FFF.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList] >> %TEMP%\888FFF.reg
echo "Administrator"=dword:00000001 >> %TEMP%\888FFF.reg
echo. >> %TEMP%\888FFF.reg

regedit.exe /s %TEMP%\888FFF.reg

del %TEMP%\888FFF.reg

net.exe user Administrator /active:yes

 

